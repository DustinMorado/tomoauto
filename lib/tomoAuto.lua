--[[==========================================================================#
# This is a program to automate the alignment of a raw tilt series, use the   #
# program RAPTOR to make a final alignment, use IMOD to estimate the defocus  #
# and then correct the CTF by appropriate phase flipping, and then finally    #
# using eTomo to create the reconstruction.                                   #
#-----------------------------------------------------------------------------#
# Author: Dustin Morado                                                       #
# Written: February 27th 2014                                                 #
# Contact: Dustin.Morado@uth.tmc.edu                                          #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = image stack file <filename.st>                          #
#            arg[2] = fiducial size in nm <integer>                           #
#            arg[3] = table with option flags from getOpts                    #
#==========================================================================--]]
local tomoAutoDir = os.getenv('TOMOAUTOROOT')
package.path = package.path .. ';' .. tomoAutoDir .. '/lib/?.lua;'
local comWriter = assert(require 'comWriter')
local tomoLib = assert(require 'tomoLib')
local lfs, os, string = lfs, os, string

local tomoAuto = {}

function tomoAuto.reconstruct(stackFile, fidSize, Opts)
local filename = string.sub(stackFile, 1, -4)

assert(lfs.mkdir(filename),'\n\nCould not make root directory\n')
assert(os.execute('mv ' .. stackFile .. ' ' .. filename), 
       '\n\nCould not move stackfile to file directory\n')
assert(lfs.chdir(filename), '\n\nCould not change to file directory\n')

local startDir = lfs.currentdir()
tomoLib.checkFreeSpace(startDir)
local header = tomoLib.readHeader(stackFile, fidSize)
if Opts.d_ then header.defocus = Opts.d_ end
comWriter.write(stackFile, header, Opts.L_)

if not Opts.t then
   if Opts.g then
      local file = io.open('tilt.com', 'a')
      file:write('UseGPU 0\n')
      file:close()
   end

   if Opts.z_ then
      local file = io.open('tilt.com', 'r')
      local contents = file:read('*a')
      contents  = contents:gsub('THICKNESS (%d+)', 'THICKNESS ' 
                  .. tostring(Opts.z_))
      file = io.open('tilt.com', 'w')
      file:write(contents)
      file:close(); file = nil
   end

   if Opts.s then
      local file = io.open('tilt.com', 'a')
      file:write('SUBSETSTART 0 0\n')
      file:close()
   end
end

if header.feiLabel == 'Fei' then
   local tempFile = io.open('temp.com', 'w')
   for line in io.lines('ctfplotter.com') do
      if line:match('ConfigFile') then
         local newline = line:gsub('K2background%/polara%-K2%-2013%.ctg',
            'CCDbackground/polara-CCD-2012.ctg')
         tempFile:write(newline..'\n')
      elseif line:match('FrequencyRangeToFit') then
         local newline = line:gsub('([%d%.]+)%s*([%d%.]+)', '0.1 0.225')
         tempFile:write(newline..'\n')
      else
         tempFile:write(line..'\n')
      end
   end
   assert(os.execute('cp ctfplotter.com ctfplotter.com~ && mv temp.com ctfplotter.com'))
end

io.write('Running IMOD extracttilts for ' .. filename .. '\n')
local rawTiltFile = filename .. '.rawtlt'
assert(tomoLib.runCheck('extracttilts -input ' .. stackFile .. ' -output '
       .. rawTiltFile))
assert(tomoLib.isFile(rawTiltFile), '\n\nCould not extract tilt angles.\n\n')

assert(lfs.mkdir('finalFiles'),
       '\n\nCould not make finalFiles directory\n')
assert(os.execute('cp ' .. stackFile .. ' finalFiles'),
       '\n\nCould not copy files\n')

-- We should always remove the Xrays from the image using ccderaser
io.write('Running ccderaser\n')
assert(tomoLib.runCheck('submfg -s -t ccderaser.com'))
tomoLib.writeLog(filename)
local ccdErasedFile = filename .. '_fixed.st'
local origFile = filename .. '_orig.st'
assert(tomoLib.isFile(ccdErasedFile), '\n\nccderaser failed, see log\n')
assert(os.execute('mv ' .. stackFile .. ' ' .. origFile), 
       '\n\nCould not move file\n')
assert(os.execute('mv ' .. ccdErasedFile .. ' ' .. stackFile),
       '\n\nCould not move file\n')

io.write('Running Coarse Alignment for ' .. stackFile .. '\n')
assert(tomoLib.runCheck('submfg -s -t tiltxcorr.com xftoxg.com newstack.com'))
tomoLib.writeLog(filename)
local preAliFile = filename .. '.preali'
assert(tomoLib.isFile(preAliFile), '\n\ncoarse alignment failed see log\n')

-- Now we run RAPTOR to produce a succesfully aligned stack
tomoLib.checkFreeSpace(startDir)
io.write('Now running RAPTOR (please be patient this may take some time)\n')
assert(tomoLib.runCheck('submfg -s -t raptor1.com'))
tomoLib.writeLog(filename)
local r1AliFile = 'raptor1/align/' .. filename .. '.ali'
local aliFile = filename .. '.ali'
local r1TltFile = 'raptor1/IMOD/' .. filename .. '.tlt'
local tltFile = filename .. '.tlt'
local r1XfFile = 'raptor1/IMOD/' .. filename .. '.xf'
local xfFile = filename .. '.xf'
assert(tomoLib.isFile(r1AliFile), '\n\nRAPTOR alignment failed see log\n')
assert(os.execute('mv ' .. r1AliFile .. ' .'), '\n\nCould not move file\n')
assert(os.execute('mv ' .. r1TltFile .. ' .'), '\n\nCould not move file\n')
assert(os.execute('mv ' .. r1XfFile .. ' .'), '\n\nCould not move file\n')
io.write('RAPTOR alignment for ' .. stackFile .. ' SUCCESSFUL\n')

if not tomoLib.checkAlign(filename, header.nz) then
   io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
   tomoLib.writeLog(filename)
   return 1
end

-- Ok for the new stuff here we add CTF correction
-- noise background is now set in the global config file
local dfcFile = ''
local ali1File = ''
if Opts.c then
   tomoLib.checkFreeSpace(startDir)
   io.write('Now running ctfplotter and ctfphaseflip for CTF correction\n')
   dfcFile = filename .. '.defocus'
   local ctfFile = filename .. '_ctfcorr.ali'

   if Opts.p_ then
      assert(tomoLib.runCheck('submfg -s -t ctfplotter.com'))
      assert(tomoLib.isFile(dfcFile), '\n\nCTFplotter failed see log\n')
      assert(tomoLib.runCheck('splitcorrection ctfcorrection.com'))
      assert(tomoLib.runCheck('processchunks -g -C 0,0,0 -T 600,0 ' 
             .. Opts.p_ .. ' ctfcorrection'))
      assert(tomoLib.isFile(ctfFile), '\n\nCTFcorrection failed see log\n')
      tomoLib.writeLog(filename)
   else
      assert(tomoLib.runCheck('submfg -t ctfplotter.com ctfcorrection.com'))
      assert(tomoLib.isFile(ctfFile), '\n\nCTFcorrection failed see log\n')
      tomoLib.writeLog(filename)
   end

   ali1File = filename .. '_first.ali'
   assert(os.execute('mv ' .. aliFile .. ' ' .. ali1File),
          '\n\nCould not move files\n')
   assert(os.execute('mv ' .. ctfFile .. ' ' .. aliFile),
          '\n\nCould not move files\n')
end

-- Now we use RAPTOR to make a fiducial model to erase the gold in the stack
io.write('Now running RAPTOR to track gold to erase particles\n')
tomoLib.checkFreeSpace(startDir)
assert(tomoLib.runCheck('submfg -t raptor2.com'))
tomoLib.writeLog(filename)
local r2FidFile = 'raptor2/IMOD/' .. filename .. '.fid.txt'
local fidFile = filename .. '_erase.fid'
assert(tomoLib.isFile(r2FidFile), '\n\nCould not make fid model see log.\n')
assert(os.execute('mv ' .. r2FidFile .. ' ' .. fidFile), 
       '\n\nCould not move files\n')

if not tomoLib.checkAlign(filename, header.nz) then
   io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
   tomoLib.writeLog(filename)
   return 1
end

-- Make the erase model more suitable for erasing gold
assert(tomoLib.runCheck('submfg -t model2point.com point2model.com'))
tomoLib.writeLog(filename)
local scatFile = filename .. '_erase.scatter.fid'
local fid1File = fidFile .. '_orig'
assert(tomoLib.isFile(scatFile), '\n\nError making point model see log.\n')
assert(os.execute('mv ' .. fidFile .. ' ' .. fid1File),
       '\n\nCould not move file\n')
assert(os.execute('mv ' .. scatFile .. ' ' ..fidFile),
       '\n\nCould not move file\n')

io.write('Now erasing gold from aligned stack\n')
assert(tomoLib.runCheck('submfg -t gold_ccderaser.com'))
tomoLib.writeLog(filename)
local erAliFile = filename .. '_erase.ali'
assert(tomoLib.isFile(erAliFile), '\n\nCould not erase gold see log.\n')
local ali2File = filename .. '_second.ali'
assert(os.execute('mv ' .. aliFile .. ' ' .. ali2File),
       '\n\nCould not move file.\n')
assert(os.execute('mv ' .. erAliFile .. ' ' .. aliFile),
       '\n\nCould not move file.\n')

io.write('Now running reconstruction, this will take some time.\n')
local recFile = ''
if not Opts.t then
   if not Opts.s then
      recFile = filename .. '_full.rec'
      if Opts.p_ then
         assert(tomoLib.runCheck('splittilt -n ' .. Opts.p_ .. ' tilt.com'))
         assert(tomoLib.runCheck('processchunks -g -C 0,0,0 -T 600,0 '
                .. Opts.p_ .. ' tilt'))
         tomoLib.writeLog(filename)
         assert(tomoLib.isFile(recFile),
                '\n\nError running tilt reconstruction see log.\n')
      else
         assert(tomoLib.runCheck('submfg -s -t tilt.com'))
         tomoLib.writeLog(filename)
         assert(tomoLib.isFile(recFile),
                '\n\nError running tilt reconstruction see log.\n')
      end
   else
      local thds = Opts.p_ or "1"
      assert(tomoLib.runCheck('sirtsetup -n ' .. thds .. ' -i 15 tilt.com'))
      tomoLib.runCheck('processchunks -g -C 0,0,0 -T 600,0 '
                       .. thds .. ' tilt_sirt')
   end
else
   assert(tomoLib.runCheck('newstack -mo 1 ' .. aliFile .. ' ' .. aliFile))
   local z = Opts.z_ or '1200'
   local tomo3dString = 'tomo3d -a ' .. tltFile .. ' -H -i ' .. aliFile
                        .. ' -z '  .. z
   if Opts.s then
      recFile = filename .. '_sirt.rec'
      tomo3dString = tomo3dString .. ' -S -o ' .. recFile
   else
      recFile = filename .. '_tomo3d.rec'
      tomo3dString = tomo3dString .. ' -o ' .. recFile
   end
   assert(tomoLib.runCheck(tomo3dString))
end

io.write('Now running post-processing on reconstruction.\n')
local binFile = filename .. '.bin4'
local binAliFile = aliFile .. '.bin4'
assert(tomoLib.runCheck('clip rotx ' .. recFile .. ' ' .. recFile),
       '\n\nError running clip in post-processing.\n')
assert(tomoLib.runCheck('binvol -binning 4 ' .. recFile .. ' ' .. binFile),
       '\n\nError binning volume.\n')
assert(tomoLib.runCheck('binvol -b 4 -z 1 ' .. aliFile .. ' ' .. binAliFile),
       '\n\nError binning alignment.\n')

io.write('Now computing post-processing filter.\n')
local filtFile = ''
if not Opts.t then
   filtFile = binFile .. '.nad'
   assert(tomoLib.runCheck('chunksetup -p 15 -o 4 nad_eed_3d.com ' 
          .. binFile .. ' ' .. filtFile),
          '\n\nError setting up NAD chunks.\n')
   if Opts.p_ then
      assert(tomoLib.runCheck('processchunks -g -C 0,0,0 -T 600,0 ' 
             .. Opts.p_ .. ' nad_eed_3d'))
      tomoLib.writeLog(filename)
   else
      assert(tomoLib.runCheck('processchunks -g -C 0,0,0 -T 600,0 ' 
             .. 1 .. ' nad_eed_3d'))
      tomoLib.writeLog(filename)
   end
elseif Opts.t and Opts.b then
   filtFile = binFile .. '.bflow'
   if Opts.p_ then 
      local thds = 31
      if tonumber(Opts.p_) < thds then
         thds = Opts.p_
      end
      assert(tomoLib.runCheck('tomobflow -t ' .. thds .. ' ' .. binFile .. ' '
             .. filtFile), '\n\nError running tomobflow.\n')
   else
      assert(tomoLib.runCheck('tomobflow -t 1 ' .. binFile .. ' ' .. filtFile),
             '\n\nError running tomobflow.\n')
   end
else
   filtFile = binFile .. '.eed'
   assert(tomoLib.runCheck('tomoeed -H ' .. binFile .. ' ' .. filtFile),
          '\n\nError running tomoeed.\n')
end

<<<<<<< HEAD
assert(tomoLib.isFile(filtFile), '\n\nError computing filter, see log.\n')
tomoLib.medNfilter(filtFile, 7)
=======
assert(tomoLib.isFile(filename .. '.bin4.' .. fStr),
       '\n\nError computing filter, see log.\n')
tomoLib.medNfilter(filename .. '.bin4.' .. fStr, 7)
>>>>>>> 85edd29ee8d8d360671222eb42bfb9140c42c80c
tomoLib.writeLog(filename)
local filt7File = filtFile .. '7'
assert(tomoLib.isFile(filt7File), '\n\nError computing med7 filter\n')

io.write('Now running file and space cleanup\n')
ctfPlotCom = io.open('ctfplotter.com', 'r')
ctfPlot = ctfPlotCom:read('*a')
ctfPlotCom:close()
ctfNewPlotCom = io.open('ctfplotter.com', 'w')
ctfNewPlot = ctfPlot:gsub('SaveAndExit', '#SaveAndExit')
ctfNewPlot = ctfNewPlot:gsub('AutoFitRangeAndStep', '#AutofitRangeAndStep')
ctfNewPlotCom:write(ctfNewPlot)
ctfNewPlotCom:close()

assert(os.execute('mv ' .. recFile .. ' ' -- reconstruction
                 .. binFile .. ' ' -- for checking
                 .. tltFile .. ' ' -- for ctfplotter.com
                 .. filt7File .. ' ' -- for picking subvols
                 .. ali1File .. ' ' -- for ctfplotter.com
                 .. binAliFile .. ' ' -- for checking
                 .. dfcFile .. ' ' -- for ctfplotter.com
                 .. 'ctfplotter.com tomoAuto.log finalFiles'),
       '\n\nCould not move final files.\n')
assert(os.execute('rm *.com *.log ' .. filename .. '*'),
       '\n\nCould not remove command and log files.\n')
assert(os.execute('rm -rf raptor*'), '\n\nCould not remove raptor files.\n')
assert(os.execute('mv finalFiles/* .'), '\n\nCould not move files.\n')
assert(os.execute('rmdir finalFiles'), '\n\nCould not remove directory.\n')
assert(os.execute('mv ' .. ali1File .. ' ' .. aliFile),
       '\n\nCould not move files.\n')
lfs.chdir('..')
io.write('tomoAuto complete for ' .. stackFile .. '\n')
end
return tomoAuto
