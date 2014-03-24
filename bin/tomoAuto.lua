#!/usr/bin/env lua
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
# Arguments: arg[1]= image stack file <filename.st>                           #
#            arg[2]= fiducial size in nm <integer>                            #
#==========================================================================--]]

-- We need the struct module to handle reading the binary header
-- We need the lfs module to handle filesystem operations
-- We need to modify Lua's package search path to find the comwriter module
-- We need the comwriter module to write all of our IMOD command files
package.path = package.path .. ';' .. os.getenv('TOMOAUTOROOT') .. '/lib/?.lua'
package.cpath = package.cpath .. ';' .. os.getenv('TOMOAUTOROOT') .. '/lib/?.so'
local comWriter = assert(require 'comWriter')
local struct = assert(require 'struct')
local lfs = assert(require 'lfs')
local tomoOpt = assert(require 'tomoOpt')

--[[==========================================================================#
#                              Local Functions                                #
#==========================================================================--]]

--[[==========================================================================#
#                                  dispHelp                                   #
#-----------------------------------------------------------------------------#
# A function that displays the usage and options of tomoAuto                  #
#==========================================================================--]]
local function dispHelp()
   io.write([[Usage: tomoAuto [-c -g -h -L <config> -p <procnum>]<file.st><fid>
            Automates the alignment of tilt series and the reconstruction of
            these series into 3D tomograms.]])
   io.write('\n\n-c, --CTF\t\tApplies CTF correction to the aligned stack\n')
   io.write('-d, --defocus\t\tUses this as estimated defocus for ctfplotter\n')
   io.write('-g, --GPU\t\tUses GPGPU methods to speed up the reconstruction\n')
   io.write('-h, --help\t\tPrints this information and exits\n')
   io.write('-L, --config\t\tSources a local config file\n')
   io.write('-p, --parallel\t\tUses multiple processors to speed up tilt\n')
   return
end
--[[==========================================================================#
#                             checkFreeSpace                                  #
#-----------------------------------------------------------------------------#
# A function to check that there is enough free space to successfully run     #
# some of the more data heavy IMOD routines                                   #
#==========================================================================--]]
local function checkFreeSpace()
	local file = assert(io.popen('df -h ' .. startDir, 'r'))
	local space = tonumber(string.sub(string.match(file:read('*a'),
                                     '.%d%%'), 1, -2))
	file:close()
	return assert(space <= 98,
                 'Error: Disk usage is at or above 98% please make more space')
end
--[[==========================================================================#
#                               runCheck                                      #
#-----------------------------------------------------------------------------#
# A function to run shell commands and check that they run successfully if    #
# the routine returns a non-zero exit code an error is thrown                 #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = shell command to be run <'string'>                      #
#==========================================================================--]]
local function runCheck(functionString)
	local _,_,exit=os.execute(functionString .. ' 2> /dev/null')
	return assert(exit == 0, 'Error running ' .. functionString)
end
--[[==========================================================================#
#                                 findITP                                     #
#-----------------------------------------------------------------------------#
# A function that reads the image stack binary header file and finds the      #
# image size (nx, ny), the tilt axis rotation angle (tilt_axis) and the pixel #
# size (pixel_size). The fiducial size in pixels is also calculated to be     #
# used in RAPTOR.                                                             #
# The complete header information can be found here:                          #
# http://www.2dx.unibas.ch/documentation/mrc-software/                        #
# fei-extended-mrc-format-not-used-by-2dx                                     #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = image stack file <filename.st>                          #
#            arg[2] = fiducial diameter in nanometers <integer>               #
#==========================================================================--]]
local function findITP(inputFile, fidSize)
	local file = assert(io.open(inputFile, 'rb'))
	local nx = struct.unpack('i4', file:read(4))
	local ny = struct.unpack('i4', file:read(4))
   local nz = struct.unpack('i4', file:read(4))
   file:seek('set', 224)
	local feiLabel = struct.unpack('c3', file:read(3))
   file:seek('set',1064)
	local tiltAxis = struct.unpack('f', file:read(4))
	local pixelSize = struct.unpack('f', file:read(4))

	if feiLabel == 'Fei' then
		pixelSize = pixelSize * 1e9
      tiltAxis = tiltAxis * -1
	else
		pixelSize = pixelSize / 10
	end

	local fidPix = math.floor((fidSize / pixelSize) + 0.5)
	file:close()
	return nx, ny, nz, feiLabel, tiltAxis, pixelSize, fidPix
end
--[[==========================================================================#
#                                 checkAlign                                  #
#-----------------------------------------------------------------------------#
# A function that checks the final alignment to make sure that too many high  #
# tilt sections were not cut by newstack or RAPTOR. If more than 10% of the   #
# original sections are missing, we abort the reconstruction                  #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = number of original sections <integer>                   #
#==========================================================================--]]
local function checkAlign(nz)
   local file = assert(io.open(filename .. '.ali', 'rb'))
   file:seek('set', 8)
   local aliNz = struct.unpack('i4', file:read(4))
   file:close()

   if (aliNz / nz) >= 0.9 then return true else return nil end

end
--[[==========================================================================#
#                                  writeLog                                   #
#-----------------------------------------------------------------------------#
#  A fuction that writes the file tomoAuto.log                                #
#==========================================================================--]]
local function writeLog()
   local log = assert(io.open('tomoAuto.log', 'w'))
   local ccd = assert(io.open('ccderaser.log', 'r'))
   local ccdLog = ccd:read('*a'); ccd:close()
   local tiltxcorr = assert(io.open('tiltxcorr.log', 'r'))
   local tiltxcorrLog = tiltxcorr:read('*a'); tiltxcorr:close()
   local xftoxg = assert(io.open('xftoxg.log', 'r'))
   local xftoxgLog = xftoxg:read('*a'); xftoxg:close()
   local newstack = assert(io.open('newstack.log', 'r'))
   local newstackLog = newstack:read('*a'); newstack:close()
   local raptor1 = assert(io.open('raptor1/align/'
                                  .. filename .. '_RAPTOR.log', 'r'))
   local raptor1Log = raptor1:read('*a'); raptor1:close()
   local raptor2 = assert(io.open('raptor2/align/'
                                  .. filename .. '_RAPTOR.log', 'r'))
   local raptor2Log = raptor2:read('*a'); raptor2:close()
   local model2point = assert(io.open('model2point.log', 'r'))
   local model2pointLog= model2point:read('*a'); model2point:close()
   local point2model = assert(io.open('point2model.log', 'r'))
   local point2modelLog= point2model:read('*a'); point2model:close()
   local ctfplotter = io.open('ctfplotter.log', 'r')

   if ctfplotter then
      local ctfplotterLog = ctfplotter:read('*a'); ctfplotter:close()
   end

   local ctfcorrection = io.open('ctfcorrection.log', 'r')

   if ctfcorrection then
      local ctfcorrectionLog = ctfcorrection:read('*a'); ctfcorrection:close()
   end

   local gold = assert(io.open('gold_ccderaser.log', 'r'))
   local goldLog = gold:read('*a'); gold:close()
   local tilt = io.open('tilt.log', 'r')

   if tilt then tiltLog = tilt:read('*a'); tilt:close() end

   log:write(ccdLog .. '\n' .. tiltxcorrLog .. '\n' .. xftoxgLog .. '\n'
             .. newstackLog .. '\n' .. raptor1Log .. '\n' .. raptor2Log .. '\n'
             .. model2pointLog .. '\n' .. point2modelLog .. '\n')

   if ctfplotterLog then
      log:write(ctfplotterLog .. '\n' .. ctfcorrectionLog .. '\n')
   end

   log:write(goldLog .. '\n')

   if tiltLog then log:write(tiltLog .. '\n') end

   log:close()
end
--[[==========================================================================#
#                                  tomoAuto                                   #
#==========================================================================--]]
shortOptsString = 'cd_ghL_p_z_'
longOptsString = 'CTF, defocus, GPU, help, config, parallel, thickness'
arg, Opts = tomoOpt.get(arg, shortOptsString, longOptsString)

if Opts.h then dispHelp() return 0 end

filename = string.sub(arg[1], 1, -4)
assert(lfs.mkdir(filename))
runCheck('mv ' .. arg[1] .. ' ' .. filename)
assert(lfs.chdir(filename))
startDir = lfs.currentdir()
nx, ny, nz, feiLabel, tiltAxis, pixelSize, fidPix = findITP(arg[1], arg[2])
checkFreeSpace()

io.write('Running IMOD extracttilts for ' .. filename .. '\n')
runCheck('extracttilts -input ' .. arg[1] .. ' -output '
.. filename .. '.rawtlt 2>&1 > /dev/null')

assert(lfs.mkdir('finalFiles'),
       'Error: Failed to make a directory. Check file permissions!')
runCheck('cp ' .. arg[1] .. ' finalFiles')

-- If we are dealing with an FEI file we should use protomo to clean and adjust
-- the values of the image stack. This fixes the compensation done by the FEI
-- software to adjust the data values from unsigned ints to signed ones. This
-- should create a much more realistic histogram of densities.

if feiLabel == 'Fei' then
   io.write('Making TIFF IMAGE copies to be cleaned\n')
   runCheck('mrc2tif ' .. arg[1] .. ' image 2>&1 > /dev/null')
   assert(lfs.mkdir('clean'),
          'Error: Failed to make a directory. Check file permissions!')
   assert(lfs.mkdir('raw'),
          'Error: Failed to make a directory. Check file permissions!')
   runCheck('mv image* raw')
   lfs.chdir('./clean')
   runCheck('tomo-clean.sh 2>&1 > /dev/null')
   io.write('Running concat to create a new stack from the cleaned image\n')
   runCheck('concat -dim 3 image* ' .. filename .. '_clean.st')
   io.write('Formatting the header to the ccp4 format\n')
   runCheck('cutimage -fmt ccp4 ' .. filename .. '_clean.st '
            .. filename .. '_cleanccp4.st')
   io.write('Fixing the header of the file\n')
   runCheck('fixheader -mrc ' .. filename .. '_cleanccp4.st')
   runCheck('mv ' .. filename .. '_cleanccp4.st ..')
   lfs.chdir('..')
   runCheck('rm -r clean raw')
   runCheck('mv ' .. arg[1] .. ' ' .. filename .. '_preclean.st && mv '
            .. filename .. '_cleanccp4.st ' .. arg[1])
end

-- A lot of the IMOD commands require command(COM) files to parse settings
-- correctly. These settings are held in tomoAuto's global config file, but the
-- user can also write local configs to overwrite the global settings on a per
-- job basis. We write these files here:
config = Opts.L_
comWriter.write(arg[1], tiltAxis, nx, ny, pixelSize, config)

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
runCheck('submfg -t ccderaser.com')
runCheck('mv ' .. arg[1] .. ' ' .. filename .. '_orig.st && mv '
         .. filename .. '_fixed.st ' .. arg[1])
io.write('Running Coarse Alignment for ' .. arg[1] .. '\n')
runCheck('submfg -t tiltxcorr.com xftoxg.com newstack.com')

-- Now we run RAPTOR to produce a succesfully aligned stack
io.write('Now running RAPTOR (please be patient this may take some time)\n')
io.write('RAPTOR starting for ' .. arg[1] .. '..........\n')
checkFreeSpace()
runCheck('RAPTOR -execPath /usr/local/RAPTOR3.0/bin -path '
         ..	startDir .. ' -input ' .. filename .. '.preali -output '
         .. startDir .. '/raptor1 -diameter ' .. fidPix)
runCheck('mv ' .. startDir .. '/raptor1/align/'
         .. filename .. '.ali ' .. startDir)
runCheck('mv ' .. startDir .. '/raptor1/IMOD/'
         .. filename .. '.tlt ' .. startDir)
runCheck('mv ' .. startDir .. '/raptor1/IMOD/'
         .. filename .. '.xf ' .. startDir)
io.write('RAPTOR alignment for ' .. arg[1] .. ' SUCCESSFUL\n')
checkFreeSpace()

-- Ok for the new stuff here we add CTF correction
-- noise background is now set in the global config file
if Opts.c then
   io.write('Now running ctfplotter and ctfphaseflip for CTF correction\n')
   checkFreeSpace()

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
      runCheck('submfg -t ctfplotter.com')
      runCheck('splitcorrection ctfcorrection.com')
      runCheck('processchunks -g ' .. Opts.p_ .. ' ctfcorrection')
   else
      runCheck('submfg -t ctfplotter.com ctfcorrection.com')
   end

   runCheck('mv ' .. startDir .. '/' .. filename .. '.ali '
            .. startDir .. '/' .. filename .. '_first.ali')
   runCheck('mv ' .. startDir .. '/' .. filename .. '_ctfcorr.ali '
            .. startDir .. '/' .. filename .. '.ali')
end

-- Now we use RAPTOR to make a fiducial model to erase the gold in the stack
io.write('Now running RAPTOR to track gold to erase particles\n')
io.write('RAPTOR starting for ' .. arg[1] .. '..........\n')
checkFreeSpace()
runCheck('RAPTOR -execPath /usr/local/RAPTOR3.0/bin/ -path '
         .. startDir .. ' -input ' .. filename .. '.ali -output '
         .. startDir .. '/raptor2 -diameter ' .. fidPix ..' -tracking')
runCheck('mv ' .. startDir .. '/raptor2/IMOD/' .. filename .. '.fid.txt '
         .. startDir .. '/' .. filename .. '_erase.fid')

-- Make the erase model more suitable for erasing gold
runCheck('submfg -t model2point.com point2model.com')
runCheck('mv ' .. startDir .. '/' .. filename .. '_erase.fid '
         .. startDir .. '/' .. filename .. '_erase.fid_orig')
runCheck('mv ' .. startDir .. '/'.. filename .. '_erase.scatter.fid '
         .. startDir .. '/' ..filename .. '_erase.fid')
io.write('Fiducial model created for ' .. arg[1] .. ' SUCCESSFUL\n')
io.write('Now erasing gold from aligned stack\n')
runCheck('submfg -t gold_ccderaser.com')
runCheck('mv ' .. startDir .. '/' .. filename .. '.ali '
         .. startDir .. '/' .. filename .. '_second.ali')
runCheck('mv ' .. startDir .. '/' .. filename .. '_erase.ali '
         .. startDir .. '/' .. filename .. '.ali')

if checkAlign(nz) then

   if Opts.p_ then
      runCheck('splittilt -n ' .. Opts.p_ .. ' tilt.com')
      runCheck('processchunks -g ' .. Opts.p_ .. ' tilt')
   else
      runCheck('submfg -t tilt.com')
   end

else
   io.write('Final alignment has cut too many sections! Aborting\n')
end

writeLog()
runCheck('binvol -binning 4 ' .. filename .. '_full.rec '
         .. filename .. '.bin4 2>&1 /dev/null')
runCheck('clip rotx ' .. filename .. '.bin4 ' .. filename .. '.bin4')
runCheck('binvol -binning 4 -zbinning 1 ' .. filename .. '.ali '
         .. filename .. '.ali.bin4 2>&1 /dev/null')

local chunkSize = 10

if Opts.p_ then
   chunkSize = Opts.p_ * 3
end

runCheck('chunksetup -m ' .. chunkSize .. ' -p 15 -o 4 nad_eed_3d.com '
         .. filename .. '.bin4 '
         .. filename .. '.bin4.nad')

if Opts.p_ then
   runCheck('processchunks -g ' .. Opts.p_ .. ' nad_eed_3d')
else
   runCheck('submfg nad_eed_3d-all')
end

io.write('Now running file and space cleanup\n')
ctfPlotCom = io.open('ctfplotter.com', 'r')
ctfPlot = ctfPlotCom:read('*a')
ctfPlotCom:close()
ctfNewPlotCom = io.open('ctfplotter.com', 'w')
ctfNewPlot = ctfPlot:gsub('SaveAndExit', '#SaveAndExit')
ctfNewPlot = ctfNewPlot:gsub('AutoFitRangeAndStep', '#AutofitRangeAndStep')
ctfNewPlotCom:write(ctfNewPlot)
ctfNewPlotCom:close()

runCheck('mv ' .. filename .. '_full.rec ' -- full reconstruction
         .. filename .. '.bin4 ' -- for checking
         .. filename .. '.tlt ' -- for ctfplotter.com
         .. filename .. '.bin4.nad ' -- for checking
         .. filename .. '_first.ali ' -- for ctfplotter.com
         .. filename .. '.ali.bin4 ' -- for checking
         .. filename .. '.defocus ' -- for ctfplotter.com
         .. 'ctfplotter.com tomoAuto.log finalFiles')
runCheck('rm *.com *.log ' .. filename .. '*')
runCheck('rm -rf raptor*')
runCheck('mv finalFiles/* .')
runCheck('rmdir finalFiles')
runCheck('mv ' .. filename .. '_first.ali ' .. filename .. '.ali')
io.write('tomoAuto complete for ' .. arg[1] .. '\n')
