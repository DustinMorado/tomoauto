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
      end
   end)
   return status, err
end

local function cleanOnFail(filename)
   run(string.format('mv tomoAuto.log finalFiles/tomoAuto_%s.log',
      os.date('%d.%m.%y')))
   run(string.format('rm -rf *.com *.log %s* raptor*',
      filename))
   run(string.format('mv finalFiles/* ..'))
   run(string.format('rmdir finalFiles'))
   lfs.chdir('..')
   run(string.format('rmdir %s'), filename)
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
      return 0
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
         return 1
      end
   end

   -- Environment setup, make folder with file basename
   local status, err = pcall(lfs.mkdir, filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('mv %s %s', stackFile, filename)) 
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   if Opts.l_ then
      status, err = run(string.format('cp %s %s', Opts.l_, filename))
      if not status then
         io.stderr:write(err)
         cleanOnFail(filename)
         return 1
      end
   end
   status, err = pcall(lfs.chdir, filename)
   if not status then
      io.stderr:write(err)
      return 1
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
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s finalFiles', stackFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end

   -- We should always remove the Xrays from the image using ccderaser
   status, err = run('submfg -s ccderaser.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(ccdErasedFile)
   status, err = run(string.format('mv %s %s', stackFile, origFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('mv %s %s', ccdErasedFile, stackFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end

   -- Here we run the Coarse alignment as done in etomo
   status, err = run('submfg -s tiltxcorr.com xftoxg.com prenewstack.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(preAliFile)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   tomoLib.checkFreeSpace(startDir)
   status, err = run('submfg -s raptor1.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   status, err = run(string.format('cp %s .', rFidFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.scaleRAPTORModel(fidTxtFile, header, fidFile)
   status, err = run('submfg -s tiltalign.com xfproduct.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s %s', fidXfFile, xfFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s %s', tltFile, fidTltFile)) 
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('submfg -s newstack.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   status, err = run(string.format('binvol -b 4 -z 1 %s %s',
      aliFile, aliBin4File))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s %s finalFiles',
      aliFile, aliBin4File))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = tomoLib.checkAlign(aliFile, header.nz)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   if Opts.c then
      tomoLib.checkFreeSpace(startDir)
      if Opts.p_ then
         status, err = run('submfg -s ctfplotter.com')
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         tomoLib.isFile(dfcFile)
         status, err = run('splitcorrection ctfcorrection.com')
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         status, err = run(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d ctfcorrection', Opts.p_))
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      else
         status, err = run('submfg -s ctfplotter.com ctfcorrection.com')
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      end
      tomoLib.modCTFPlotter()
      status, err = run(string.format('cp %s ctfplotter.com finalFiles',
         dfcFile))
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('mv %s %s', aliFile, ali1File))
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('mv %s %s', ctfFile, aliFile))
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('cp %s finalFiles', aliFile))
      if not status then
         io.stderr:write(err)
         return 1
      end
   end

   -- Now we erase the gold
   status, err = run(string.format('xfmodel -xf %s %s %s',
      tltXfFile, fidFile, erFidFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('submfg -s gold_ccderaser.com')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(erAliFile)
   status, err = run(string.format('mv %s %s', aliFile, ali2File))
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('mv %s %s', erAliFile, aliFile))
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- Finally we compute the reconstruction
   if not Opts.t then      -- Using IMOD to handle the reconstruction.
      if not Opts.s then   -- Using Weighted Back Projection method.
         recFile = filename .. '_full.rec'
         if Opts.p_ then
            status, err = run(string.format('splittilt -n %d tilt.com',
               Opts.p_))
            if not status then
               io.stderr:write(err)
               cleanOnFail(filename)
               return 1
            end
            status, err = run(string.format(
               'processchunks -g -C 0,0,0 -T 600,0 %d tilt', Opts.p_))
            if not status then
               io.stderr:write(err)
               cleanOnFail(filename)
               return 1
            end
            tomoLib.writeLog(filename)
         else
            status, err = run('submfg -s tilt.com')
            if not status then
               io.stderr:write(err)
               cleanOnFail(filename)
               return 1
            end
            tomoLib.writeLog(filename)
         end
      else                 -- Using S.I.R.T method
         local thds = Opts.p_ or '1'
         status, err = run(string.format('sirtsetup -n %d -i 15 tilt.com',
            thds))
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         status, err = run(string.format(
            'processchunks -g -C 0,0,0 -T 600,0 %d tilt_sirt', thds))
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
      end
   else                    -- Using TOMO3D to handle the reconstruction
      recFile  = filename .. '_tomo3d.rec'
      local z        = Opts.z_ or '1200'
      local iter     = Opts.i_ or '30'
      local thds     = Opts.p_ or '1'
      local t3Str    = string.format(
         ' -a %s -i %s -t %d -z %d', tltFile, aliFile, thds, z)
      if header.mode == 6 then
         status, err = run(string.format('newstack -mo 1 %s %s',
            aliFile, aliFile))
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
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

      status, err = run(t3Str)
      if not status then
         io.stderr:write(err)
         cleanOnFail(filename)
         return 1
      end
   end
   tomoLib.isFile(recFile)
   
   -- We rotate the tomogram around the X-axis by -90 degrees 
   -- this generates a volume perpendicular to the beam without changing the
   -- handedness.
   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   status, err = run(string.format('clip rotx %s %s', recFile, recFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('binvol -binning 4 %s %s',
      recFile, binFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('mv %s %s tomoAuto.log finalFiles',
      recFile, binFile))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('rm -rf *.com *.log %s* raptor*',
      filename))
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('mv finalFiles/* .')
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('rmdir finalFiles')
   if not status then
      io.stderr:write(err)
      return 1
   end
   lfs.chdir('..')

   return 0
end
return tomoAuto
