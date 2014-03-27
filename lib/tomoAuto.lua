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
local rootDir = os.getenv('TOMOAUTOROOT')
local lfs = assert(require 'lfs')
local comWriter = assert(dofile(rootDir .. '/lib/comWriter.lua'))
local tomoLib = assert(dofile(rootDir .. '/lib/tomoLib.lua'))

local tomoAuto = {}
function tomoAuto.reconstruct(stackFile, fidSize, Opts)

if Opts.h then tomoLib.dispHelp() return 0 end

local filename = string.sub(stackFile, 1, -4)

if lfs.mkdir(filename) then -- successfully created directory
   tomoLib.runCheck('mv ' .. stackFile .. ' ' .. filename)
   assert(lfs.chdir(filename))
else -- either directory exists or permission denied

   if not lfs.chdir(filename) then --
      io.stderr:write('Cannot make start dir. Check Permissions')
      return 1
   end

end

local startDir = lfs.currentdir()
local nx, ny, nz, feiLabel, tiltAxis, pixelSize, fidPix = tomoLib.findITP(stackFile, fidSize)
tomoLib.checkFreeSpace(startDir)

io.write('Running IMOD extracttilts for ' .. filename .. '\n')
tomoLib.runCheck('extracttilts -input ' .. stackFile .. ' -output '
.. filename .. '.rawtlt 2>&1 > /dev/null')

assert(lfs.mkdir('finalFiles'),
       'Error: Failed to make final files directory. Check Permissions!')
tomoLib.runCheck('cp ' .. stackFile .. ' finalFiles')

-- If we are dealing with an FEI file we should use protomo to clean and adjust
-- the values of the image stack. This fixes the compensation done by the FEI
-- software to adjust the data values from unsigned ints to signed ones. This
-- should create a much more realistic histogram of densities.

if feiLabel == 'Fei' then
   io.write('Making TIFF IMAGE copies to be cleaned\n')
   tomoLib.runCheck('mrc2tif ' .. stackFile .. ' image 2>&1 > /dev/null')
   assert(lfs.mkdir('clean'),
          'Error: Failed to make a directory. Check file permissions!')
   assert(lfs.mkdir('raw'),
          'Error: Failed to make a directory. Check file permissions!')
   tomoLib.runCheck('mv image* raw')
   lfs.chdir('./clean')
   tomoLib.runCheck('tomo-clean.sh 2>&1 > /dev/null')
   io.write('Running concat to create a new stack from the cleaned image\n')
   tomoLib.runCheck('concat -dim 3 image* ' .. filename .. '_clean.st')
   io.write('Formatting the header to the ccp4 format\n')
   tomoLib.runCheck('cutimage -fmt ccp4 ' .. filename .. '_clean.st '
            .. filename .. '_cleanccp4.st')
   io.write('Fixing the header of the file\n')
   tomoLib.runCheck('fixheader -mrc ' .. filename .. '_cleanccp4.st')
   tomoLib.runCheck('mv ' .. filename .. '_cleanccp4.st ..')
   lfs.chdir('..')
   tomoLib.runCheck('rm -r clean raw')
   tomoLib.runCheck('mv ' .. stackFile .. ' ' .. filename .. '_preclean.st && mv '
            .. filename .. '_cleanccp4.st ' .. stackFile)
end

-- A lot of the IMOD commands require command(COM) files to parse settings
-- correctly. These settings are held in tomoAuto's global config file, but the
-- user can also write local configs to overwrite the global settings on a per
-- job basis. We write these files here:
--
config = Opts.L_
comWriter.write(stackFile, tiltAxis, nx, ny, pixelSize, config)

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
   file:close()
end

-- We should always remove the Xrays from the image using ccderaser
io.write('Running ccderaser\n')
tomoLib.runCheck('submfg -t ccderaser.com')
tomoLib.writeLog(filename)

tomoLib.runCheck('mv ' .. stackFile .. ' ' .. filename .. '_orig.st && mv '
         .. filename .. '_fixed.st ' .. stackFile)
io.write('Running Coarse Alignment for ' .. stackFile .. '\n')
tomoLib.runCheck('submfg -t tiltxcorr.com xftoxg.com newstack.com')
tomoLib.writeLog(filename)

-- Now we run RAPTOR to produce a succesfully aligned stack
io.write('Now running RAPTOR (please be patient this may take some time)\n')
io.write('RAPTOR starting for ' .. stackFile .. '..........\n')
tomoLib.checkFreeSpace(startDir)
tomoLib.runCheck('RAPTOR -execPath /usr/local/RAPTOR3.0/bin -path '
         ..	startDir .. ' -input ' .. filename .. '.preali -output '
         .. startDir .. '/raptor1 -diameter ' .. fidPix)
tomoLib.runCheck('mv ' .. startDir .. '/raptor1/align/'
         .. filename .. '.ali ' .. startDir)
tomoLib.runCheck('mv ' .. startDir .. '/raptor1/IMOD/'
         .. filename .. '.tlt ' .. startDir)
tomoLib.runCheck('mv ' .. startDir .. '/raptor1/IMOD/'
         .. filename .. '.xf ' .. startDir)
tomoLib.writeLog(filename)
io.write('RAPTOR alignment for ' .. stackFile .. ' SUCCESSFUL\n')

if not tomoLib.checkAlign(filename, nz) then
   io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
   tomoLib.writeLog(filename)
   return 1
end

tomoLib.checkFreeSpace(startDir)

-- Ok for the new stuff here we add CTF correction
-- noise background is now set in the global config file
--
if Opts.c then
   io.write('Now running ctfplotter and ctfphaseflip for CTF correction\n')
   tomoLib.checkFreeSpace(startDir)

   if Opts.d_ then
      local newDefocus = tonumber(Opts.d_) * 1000
      local file = assert(io.open('ctfplotter.com', 'r'))
      local ctfNew = file:read('*a'); file:close()
      ctfNew = ctfNew:gsub('ExpectedDefocus (%d+%.?%d*)', 'ExpectedDefocus '
                           .. newDefocus)
      local file = assert(io.open('ctfplotter.com', 'w'))
      file:write(ctfNew); file:close()
   end

   if Opts.p_ then
      tomoLib.runCheck('submfg -t ctfplotter.com')
      tomoLib.runCheck('splitcorrection ctfcorrection.com')
      tomoLib.runCheck('processchunks -g ' .. Opts.p_ .. ' ctfcorrection')
   else
      tomoLib.runCheck('submfg -t ctfplotter.com ctfcorrection.com')
   end
   tomoLib.writeLog(filename)

   tomoLib.runCheck('mv ' .. startDir .. '/' .. filename .. '.ali '
            .. startDir .. '/' .. filename .. '_first.ali')
   tomoLib.runCheck('mv ' .. startDir .. '/' .. filename .. '_ctfcorr.ali '
            .. startDir .. '/' .. filename .. '.ali')
end

-- Now we use RAPTOR to make a fiducial model to erase the gold in the stack
io.write('Now running RAPTOR to track gold to erase particles\n')
io.write('RAPTOR starting for ' .. stackFile .. '..........\n')
tomoLib.checkFreeSpace(startDir)
tomoLib.runCheck('RAPTOR -execPath /usr/local/RAPTOR3.0/bin/ -path '
         .. startDir .. ' -input ' .. filename .. '.ali -output '
         .. startDir .. '/raptor2 -diameter ' .. fidPix ..' -tracking')
tomoLib.runCheck('mv ' .. startDir .. '/raptor2/IMOD/' .. filename 
         .. '.fid.txt ' .. startDir .. '/' .. filename .. '_erase.fid')

if not tomoLib.checkAlign(filename, nz) then
   io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
   tomoLib.writeLog(filename)
   return 1
end

-- Make the erase model more suitable for erasing gold
tomoLib.runCheck('submfg -t model2point.com point2model.com')
tomoLib.writeLog(filename)

tomoLib.runCheck('mv ' .. startDir .. '/' .. filename .. '_erase.fid '
         .. startDir .. '/' .. filename .. '_erase.fid_orig')
tomoLib.runCheck('mv ' .. startDir .. '/'.. filename .. '_erase.scatter.fid '
         .. startDir .. '/' ..filename .. '_erase.fid')
tomoLib.writeLog(filename)
io.write('Fiducial model created for ' .. stackFile .. ' SUCCESSFUL\n')

io.write('Now erasing gold from aligned stack\n')
tomoLib.runCheck('submfg -t gold_ccderaser.com')
tomoLib.writeLog(filename)

tomoLib.runCheck('mv ' .. startDir .. '/' .. filename .. '.ali '
         .. startDir .. '/' .. filename .. '_second.ali')
tomoLib.runCheck('mv ' .. startDir .. '/' .. filename .. '_erase.ali '
         .. startDir .. '/' .. filename .. '.ali')

if Opts.p_ then
   tomoLib.runCheck('splittilt -n ' .. Opts.p_ .. ' tilt.com')
   tomoLib.runCheck('processchunks -g ' .. Opts.p_ .. ' tilt')
else
   tomoLib.runCheck('submfg -t tilt.com')
end

tomoLib.writeLog(filename)

tomoLib.runCheck('binvol -binning 4 ' .. filename .. '_full.rec '
         .. filename .. '.bin4 2>&1 /dev/null')
tomoLib.runCheck('clip rotx ' .. filename .. '.bin4 ' .. filename .. '.bin4')
tomoLib.runCheck('binvol -binning 4 -zbinning 1 ' .. filename .. '.ali '
         .. filename .. '.ali.bin4 2>&1 /dev/null')

local chunkSize = 10

if Opts.p_ then
   chunkSize = Opts.p_ * 3
end

tomoLib.runCheck('chunksetup -m ' .. chunkSize .. ' -p 15 -o 4 nad_eed_3d.com '
         .. filename .. '.bin4 '
         .. filename .. '.bin4.nad')

if Opts.p_ then
   tomoLib.runCheck('processchunks -g ' .. Opts.p_ .. ' nad_eed_3d')
else
   tomoLib.runCheck('submfg nad_eed_3d-all')
end
tomoLib.writeLog(filename)

io.write('Now running file and space cleanup\n')
ctfPlotCom = io.open('ctfplotter.com', 'r')
ctfPlot = ctfPlotCom:read('*a')
ctfPlotCom:close()
ctfNewPlotCom = io.open('ctfplotter.com', 'w')
ctfNewPlot = ctfPlot:gsub('SaveAndExit', '#SaveAndExit')
ctfNewPlot = ctfNewPlot:gsub('AutoFitRangeAndStep', '#AutofitRangeAndStep')
ctfNewPlotCom:write(ctfNewPlot)
ctfNewPlotCom:close()

tomoLib.runCheck('mv ' .. filename .. '_full.rec ' -- full reconstruction
         .. filename .. '.bin4 ' -- for checking
         .. filename .. '.tlt ' -- for ctfplotter.com
         .. filename .. '.bin4.nad ' -- for checking
         .. filename .. '_first.ali ' -- for ctfplotter.com
         .. filename .. '.ali.bin4 ' -- for checking
         .. filename .. '.defocus ' -- for ctfplotter.com
         .. 'ctfplotter.com tomoAuto.log finalFiles')
tomoLib.runCheck('rm *.com *.log ' .. filename .. '*')
tomoLib.runCheck('rm -rf raptor*')
tomoLib.runCheck('mv finalFiles/* .')
tomoLib.runCheck('rmdir finalFiles')
tomoLib.runCheck('mv ' .. filename .. '_first.ali ' .. filename .. '.ali')
lfs.chdir('..')
io.write('tomoAuto complete for ' .. stackFile .. '\n')
end
return tomoAuto
