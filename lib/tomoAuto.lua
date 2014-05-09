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
local MRCIOLib = assert(require 'MRCIOLib') 
local tomoLib = assert(require 'tomoLib')
local lfs, os, string = lfs, os, string

local tomoAuto = {}

function tomoAuto.reconstruct(stackFile, fidNm, Opts)
   -- Environment setup, make folder with file basename
   local filename = string.sub(stackFile, 1, -4)
   assert(lfs.mkdir(filename),'\n\nCould not make root directory\n')
   assert(os.execute(string.format('mv %s %s', stackFile, filename)), 
      '\n\nCould not move stackfile to file directory\n')
   assert(lfs.chdir(filename), '\n\nCould not change to file directory\n')
   local startDir = lfs.currentdir()

   -- Multiple times throughout we will check for enough disk space
   tomoLib.checkFreeSpace(startDir)

   -- Here we read the MRC file format header
   local header = MRCIOLib.getReqdHeader(stackFile, fidNm)
   if Opts.c then
      if Opts.d_ then 
         header.defocus = Opts.d_
      else
         io.stderr:write('You need to enter an approximate defocus to run \
            with CTF correction.\n')
         return 1
      end
   else
      header.defocus = 0
   end

   -- Here we write all of the needed command files.
   comWriter.write(stackFile, header, Opts)

   -- Here we extract the tilt angles from the header
   io.stdout:write(string.format(
   'Running IMOD extracttilts for %s\n', filename))
   local rawTiltFile = filename .. '.rawtlt'
   tomoLib.runCheck(string.format(
      'extracttilts %s %s', stackFile, rawTiltFile))
   assert(tomoLib.isFile(rawTiltFile),
      '\n\nCould not extract tilt angles.\n\n')

   -- We create this directory as a backup for the original stack
   assert(lfs.mkdir('finalFiles'),
       '\n\nCould not make finalFiles directory\n')
   assert(os.execute(string.format('cp %s finalFiles', stackFile)),
       '\n\nCould not copy files\n')

   -- We should always remove the Xrays from the image using ccderaser
   local ccdErasedFile  = filename .. '_fixed.st'
   local origFile       = filename .. '_orig.st'
   io.stdout:write(string.format('Running ccderaser on %s\n', filename))
   tomoLib.runCheck('submfg -s -t ccderaser.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(ccdErasedFile), '\n\nccderaser failed, see log\n')
   assert(os.execute(string.format(
      'mv %s %s', stackFile, origFile)), '\n\nCould not move file\n')
   assert(os.execute(string.format(
      'mv %s %s', ccdErasedFile, stackFile)), '\n\nCould not move file\n')

   -- Here we run the Coarse alignment as done in etomo
   local preAliFile = filename .. '.preali'
   io.stdout:write(string.format('Running Coarse Alignment for %s\n', stackFile))
   tomoLib.runCheck('submfg -s -t tiltxcorr.com xftoxg.com newstack.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(preAliFile), '\n\ncoarse alignment failed see log\n')

   -- Now we run RAPTOR to produce a succesfully aligned stack
   local r1AliFile = 'raptor1/align/' .. filename .. '.ali'
   local aliFile = filename .. '.ali'
   local r1TltFile = 'raptor1/IMOD/' .. filename .. '.tlt'
   local tltFile = filename .. '.tlt'
   local r1XfFile = 'raptor1/IMOD/' .. filename .. '.xf'
   local xfFile = filename .. '.xf'
   tomoLib.checkFreeSpace(startDir)
   io.stdout:write(string.format(
      'Now running RAPTOR for %s (this may take some time)\n', stackFile))
   tomoLib.runCheck('submfg -s -t raptor1.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(r1AliFile), '\n\nRAPTOR alignment failed see log\n')
   assert(os.execute(string.format('mv %s .', r1AliFile)), 
      '\n\nCould not move file\n')
   assert(os.execute(string.format('mv %s .', r1TltFile)),
      '\n\nCould not move file\n')
   assert(os.execute(string.format('mv %s .', r1XfFile)),
      '\n\nCould not move file\n')
   io.stdout:write(string.format(
      'RAPTOR alignment for %s SUCCESSFUL\n', stackFile))
   if not tomoLib.checkAlign(filename, header.nz) then
      io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
      tomoLib.writeLog(filename)
      return 1
   end

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   local dfcFile  = filename .. '.defocus'
   local ali1File = filename .. '_first.ali'
   local ctfFile  = filename .. '_ctfcorr.ali'
   if Opts.c then
      tomoLib.checkFreeSpace(startDir)
      io.stdout:write(string.format(
         'Now processing CTF correction for %s\n', stackFile)) 
      if Opts.p_ then
         tomoLib.runCheck('submfg -s -t ctfplotter.com')
         assert(tomoLib.isFile(dfcFile), '\n\nCTFplotter failed see log\n')
         tomoLib.runCheck('splitcorrection ctfcorrection.com')
         tomoLib.runCheck(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d ctfcorrection', Opts.p_))
         assert(tomoLib.isFile(ctfFile), 
            '\n\nCTFcorrection failed see log\n')
         tomoLib.writeLog(filename)
      else
         tomoLib.runCheck('submfg -t ctfplotter.com ctfcorrection.com')
         assert(tomoLib.isFile(ctfFile), '\n\nCTFcorrection failed see log\n')
         tomoLib.writeLog(filename)
      end
      assert(os.execute(string.format('mv %s %s', aliFile, ali1File)),
         '\n\nCould not move files\n')
      assert(os.execute(string.format('mv %s %s', ctfFile, aliFile)),
         '\n\nCould not move files\n')
   end

   -- Now we use RAPTOR to make a fiducial model to erase the gold in the stack
   local r2FidFile = 'raptor2/IMOD/' .. filename .. '.fid.txt'
   local fidFile = filename .. '_erase.fid'
   io.stdout:write(string.format(
      'Now running RAPTOR to track gold to erase for %s\n',stackFile))
   tomoLib.checkFreeSpace(startDir)
   tomoLib.runCheck('submfg -t raptor2.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(r2FidFile), '\n\nCould not make fid model see log.\n')
   assert(os.execute(string.format('mv %s %s', r2FidFile, fidFile)),
      '\n\nCould not move files\n')
   if not tomoLib.checkAlign(filename, header.nz) then
      io.stderr:write('RAPTOR has cut too many sections. Bad Data!')
      tomoLib.writeLog(filename)
      return 1
   end

   -- Make the erase model more suitable for erasing gold
   local scatFile = filename .. '_erase.scatter.fid'
   local fid1File = fidFile .. '_orig'
   tomoLib.runCheck('submfg -t model2point.com point2model.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(scatFile), '\n\nError making point model see log.\n')
   assert(os.execute(string.format('mv %s %s', fidFile, fid1File)),
      '\n\nCould not move file\n')
   assert(os.execute(string.format('mv %s %s', scatFile, fidFile)),
      '\n\nCould not move file\n')

   -- Now we erase the gold
   local erAliFile = filename .. '_erase.ali'
   local ali2File = filename .. '_second.ali'
   io.stdout:write(string.format(
      'Now erasing gold from aligned stack for %s\n', stackFile))
   tomoLib.runCheck('submfg -t gold_ccderaser.com')
   tomoLib.writeLog(filename)
   assert(tomoLib.isFile(erAliFile), '\n\nCould not erase gold see log.\n')
   assert(os.execute(string.format('mv %s %s', aliFile, ali2File)),
      '\n\nCould not move file.\n')
   assert(os.execute(string.format('mv %s %s', erAliFile, aliFile)),
      '\n\nCould not move file.\n')

   -- Finally we compute the reconstruction
   local recFile = filename .. '_full.rec'
   io.stdout:write(string.format(
      'Now running reconstruction for %s\n', stackFile))
   if not Opts.t then      -- Using IMOD to handle the reconstruction.
      if not Opts.s then   -- Using Weighted Back Projection method.
         recFile = filename .. '_full.rec'
         if Opts.p_ then
            tomoLib.runCheck(string.format(
               'splittilt -n %d tilt.com', Opts.p_))
            tomoLib.runCheck(string.format(
               'processchunks -g -C 0,0,0 -T 600,0 %d tilt', Opts.p_))
            tomoLib.writeLog(filename)
         else
            tomoLib.runCheck('submfg -s -t tilt.com')
            tomoLib.writeLog(filename)
         end
      else                 -- Using S.I.R.T method
         local thds = Opts.p_ or '1'
         tomoLib.runCheck(string.format(
            'sirtsetup -n %d -i 15 tilt.com', thds))
         tomoLib.runCheck(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d tilt_sirt', thds))
      end
   else                    -- Using TOMO3D to handle the reconstruction
      local recFile  = filename .. '_tomo3d.rec'
      local z        = Opts.z_ or '1200'
      local iter     = Opts.i_ or '30'
      local thds     = Opts.p_ or '1'
      local t3Str    = string.format(
         ' -a %s -i %s -t %d -z %d', tltFile, aliFile, thds, z)
      assert(tomoLib.runCheck(string.format(
         'newstack -mo 1 %s %s', aliFile, aliFile)))
      if Opts.g then
         t3Str = 'tomo3dhybrid -g 0 ' .. t3Str
      else
         t3Str = 'tomo3d' .. t3Str
      end
      if Opts.s then 
         recFile = filename .. '_sirt.rec'
         t3Str   = string.format('%s -l %d -S -o %s', t3Str, iter, recFile)
      else
         t3Str   = string.format('%s -o %s', t3Str, recFile)
      end
      tomoLib.runCheck(tomo3dString)
   end
   assert(tomoLib.isFile(recFile),
      '\n\nError running tilt reconstruction see log.\n')
   
   -- We rotate the tomogram around the X-axis by -90 degrees 
   -- this generates a volume perpendicular to the beam without changing the
   -- handedness.
   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   local binFile = filename .. '.bin4'
   local binAliFile = aliFile .. '.bin4'
   io.stdout:write('Now running post-processing on reconstruction.\n')
   assert(tomoLib.runCheck(string.format(
      'clip rotx %s %s', recFile, recFile)), 
      '\n\nError rotating tomographic volume.\n')
   assert(tomoLib.runCheck(string.format(
      'binvol -binning 4 %s %s', recFile, binFile)),
       '\n\nError binning tomographic volume.\n')
   assert(tomoLib.runCheck(string.format(
      'binvol -b 4 -z 1 %s %s', aliFile, binAliFile)),
      '\n\nError binning final alignment.\n')

   -- Now we cleanup the folder of the intermediates
   -- We also have to fix the ctfplotter com file for inspection.
   io.stdout:write('Now running file and space cleanup\n')
   ctfPlotCom = io.open('ctfplotter.com', 'r')
   ctfPlot = ctfPlotCom:read('*a')
   ctfPlotCom:close()
   ctfNewPlotCom = io.open('ctfplotter.com', 'w')
   ctfNewPlot = ctfPlot:gsub('SaveAndExit', '#SaveAndExit')
   ctfNewPlot = ctfNewPlot:gsub('AutoFitRangeAndStep', '#AutofitRangeAndStep')
   ctfNewPlotCom:write(ctfNewPlot)
   ctfNewPlotCom:close()

   assert(os.execute(string.format(
      'mv %s %s %s %s %s %s ctfplotter.com tomoAuto.log finalFiles',
      recFile, binFile, tltFile, ali1File, binAliFile, dfcFile)),
      '\n\nCould not move final files.\n')
   assert(os.execute('rm *.com *.log ' .. filename .. '*'),
      '\n\nCould not remove command and log files.\n')
   assert(os.execute('rm -rf raptor*'),
      '\n\nCould not remove raptor files.\n')
   assert(os.execute('mv finalFiles/* .'),
      '\n\nCould not move files.\n')
   assert(os.execute('rmdir finalFiles'),
      '\n\nCould not remove directory.\n')
   assert(os.execute(string.format('mv %s %s', ali1File, aliFile)),
      '\n\nCould not move files.\n')
   lfs.chdir('..')
   io.stdout:write(string.format(
      'tomoAuto complete for %s\n', stackFile))

   return 0
end
return tomoAuto
