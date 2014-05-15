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
local comWriter = require 'comWriter'
local MRCIOLib  = require 'MRCIOLib'
local tomoLib   = require 'tomoLib'
local lfs, os, string = lfs, os, string

local tomoAuto = {}

local function run(funcString)
   local status, err = pcall(function()
      local success, exit, signal = os.execute(funcString .. '&> /dev/null')
      if (not success) or (signal ~= 0) then 
         error('\nError: ' .. funcString .. ' failed.\n\n', 0)
      else
         return true
      end
   end)
   if not status then
      io.stderr:write(err)
      os.exit(1)
   end
end

function tomoAuto.reconstruct(stackFile, fidNm, Opts)
   -- These are all of the files created and used throughout
   local filename = string.sub(stackFile, 1, -4)
   local rawTiltFile    = filename .. '.rawtlt'
   local ccdErasedFile  = filename .. '_fixed.st'
   local origFile       = filename .. '_orig.st'
   local preAliFile     = filename .. '.preali'
   local aliFile        = filename .. '.ali'
   local aliBin4File    = aliFile .. '.bin4'
   local tltFile        = filename .. '.tlt'
   local rFidFile       = 'raptor1/IMOD/' .. filename .. '.fid.txt'
   local fidFile        = filename .. '.fid'
   local fidTxtFile     = fidFile .. '.txt'
   local fidXfFile      = filename .. '_fid.xf'
   local xfFile         = filename .. '.xf'
   local fidTltFile     = filename .. '_fid.tlt'
   local dfcFile        = filename .. '.defocus'
   local ali1File       = filename .. '_first.ali'
   local ctfFile        = filename .. '_ctfcorr.ali'
   local tltXfFile      = filename .. '.tltxf'
   local erFidFile      = filename .. '_erase.fid'
   local erAliFile      = filename .. '_erase.ali'
   local ali2File       = filename .. '_second.ali'
   local recFile        = filename .. '_full.rec'
   local binFile        = filename .. '.bin4'

   if Opts.h then
      tomoLib.dispHelp()
      os.exit(0)
   end

   -- Multiple times throughout we will check for enough disk space
   tomoLib.checkFreeSpace(lfs.currentdir())

   -- Here we read the MRC file format header
   local header = MRCIOLib.getReqdHeader(stackFile, fidNm)

   if Opts.c then
      if Opts.d_ then 
         header.defocus = Opts.d_
      else
         io.stderr:write('You need to enter an approximate defocus to run \z
            with CTF correction.\n')
         os.exit(1)
      end
   end

   -- Environment setup, make folder with file basename
   local status, err = pcall(lfs.mkdir, filename)
   if not status then
      io.stderr:write(err)
      os.exit(1)
   end
   run(string.format('mv %s %s', stackFile, filename)) 
   if Opts.l_ then
      run(string.format('cp %s %s', Opts.l_, filename))
   end
   status, err = pcall(lfs.chdir, filename)
   if not status then
      io.stderr:write(err)
      os.exit(1)
   end
   local startDir = lfs.currentdir()



   -- Here we write all of the needed command files.
   comWriter.write(stackFile, header, Opts)

   -- Here we extract the tilt angles from the header
   MRCIOLib.getTilts(stackFile, rawTiltFile)
   tomoLib.isFile(rawTiltFile)

   -- We create this directory as a backup for the original stack
   status, err = pcall(lfs.mkdir, 'finalFiles')
   if not status then
      io.stderr:write(err)
      os.exit(1)
   end
   run(string.format('cp %s finalFiles', stackFile))

   -- We should always remove the Xrays from the image using ccderaser
   run('submfg -s ccderaser.com')
   tomoLib.writeLog(filename)
   tomoLib.isFile(ccdErasedFile)
   run(string.format('mv %s %s', stackFile, origFile))
   run(string.format('mv %s %s', ccdErasedFile, stackFile))

   -- Here we run the Coarse alignment as done in etomo
   run('submfg -s tiltxcorr.com xftoxg.com prenewstack.com')
   tomoLib.writeLog(filename)
   tomoLib.isFile(preAliFile)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   tomoLib.checkFreeSpace(startDir)
   run('submfg -s raptor1.com')
   tomoLib.writeLog(filename)
   run(string.format('cp %s .', rFidFile))
   tomoLib.scaleRAPTORModel(fidTxtFile, header, fidFile)
   run('submfg -s tiltalign.com xfproduct.com')
   run(string.format('cp %s %s', fidXfFile, xfFile))
   run(string.format('cp %s %s', tltFile, fidTltFile)) 
   run('submfg -s newstack.com')
   tomoLib.writeLog(filename)
   run(string.format('binvol -b 4 -z 1 %s %s', aliFile, aliBin4File))
   run(string.format('cp %s %s finalFiles', aliFile, aliBin4File))
   tomoLib.checkAlign(aliFile, header.nz)

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   if Opts.c then
      tomoLib.checkFreeSpace(startDir)
      if Opts.p_ then
         run('submfg -s ctfplotter.com')
         tomoLib.isFile(dfcFile)
         run('splitcorrection ctfcorrection.com')
         run(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d ctfcorrection', Opts.p_))
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      else
         run('submfg -s ctfplotter.com ctfcorrection.com')
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      end
      tomoLib.modCTFPlotter()
      run(string.format('cp %s ctfplotter.com finalFiles', dfcFile))
      run(string.format('mv %s %s', aliFile, ali1File))
      run(string.format('mv %s %s', ctfFile, aliFile))
      run(string.format('cp %s finalFiles', aliFile))
   end

   -- Now we erase the gold
   run(string.format('xfmodel -xf %s %s %s', tltXfFile, fidFile, erFidFile))
   run('submfg -s gold_ccderaser.com')
   tomoLib.writeLog(filename)
   tomoLib.isFile(erAliFile)
   run(string.format('mv %s %s', aliFile, ali2File))
   run(string.format('mv %s %s', erAliFile, aliFile))

   -- Finally we compute the reconstruction
   if not Opts.t then      -- Using IMOD to handle the reconstruction.
      if not Opts.s then   -- Using Weighted Back Projection method.
         recFile = filename .. '_full.rec'
         if Opts.p_ then
            run(string.format('splittilt -n %d tilt.com', Opts.p_))
            run(string.format(
               'processchunks -g -C 0,0,0 -T 600,0 %d tilt', Opts.p_))
            tomoLib.writeLog(filename)
         else
            run('submfg -s tilt.com')
            tomoLib.writeLog(filename)
         end
      else                 -- Using S.I.R.T method
         local thds = Opts.p_ or '1'
         run(string.format('sirtsetup -n %d -i 15 tilt.com', thds))
         run(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d tilt_sirt', thds))
      end
   else                    -- Using TOMO3D to handle the reconstruction
      recFile  = filename .. '_tomo3d.rec'
      local z        = Opts.z_ or '1200'
      local iter     = Opts.i_ or '30'
      local thds     = Opts.p_ or '1'
      local t3Str    = string.format(
         ' -a %s -i %s -t %d -z %d', tltFile, aliFile, thds, z)
      if header.mode == 6 then
         run(string.format('newstack -mo 1 %s %s', aliFile, aliFile))
      end
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

      run(t3Str)
   end
   tomoLib.isFile(recFile)
   
   -- We rotate the tomogram around the X-axis by -90 degrees 
   -- this generates a volume perpendicular to the beam without changing the
   -- handedness.
   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   run(string.format('clip rotx %s %s', recFile, recFile))
   run(string.format('binvol -binning 4 %s %s', recFile, binFile))
   run(string.format('mv %s %s tomoAuto.log finalFiles', recFile, binFile))
   run(string.format('rm -rf *.com *.log %s* raptor*', filename))
   run('mv finalFiles/* .')
   run('rmdir finalFiles')
   lfs.chdir('..')

   return 0
end
return tomoAuto
