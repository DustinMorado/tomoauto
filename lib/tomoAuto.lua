--[[===========================================================================#
# This is a program to automate the alignment of a raw tilt series, use the    #
# program RAPTOR to make a final alignment, use IMOD to estimate the defocus   #
# and then correct the CTF by appropriate phase flipping, and then finally     #
# using eTomo to create the reconstruction.                                    #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: February 27th 2014                                                  #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: arg[1] = image stack file <filename.st>                           #
#            arg[2] = fiducial size in nm <integer>                            #
#            arg[3] = table with option flags from getOpts                     #
#===========================================================================--]]
local tomoAutoDir = os.getenv('TOMOAUTOROOT')
package.path = package.path .. ';' .. tomoAutoDir .. '/lib/?.lua;'
local comWriter = require 'comWriter'
local MRCIOLib  = require 'MRCIOLib'
local tomoLib   = require 'tomoLib'
local lfs, os, string = lfs, os, string

local tomoAuto = {}

local function run(funcString,filename)
   local status, err = pcall(function()
      local success, exit, signal = os.execute(string.format(
         '%s 1>> tomoAuto_%s.log 2>> tomoAuto_%s.err.log',
          funcString, filename, filename))
      if (not success) or (signal ~= 0) then
         error(string.format(
            '\nError: %s failed for %s.\n\n', funcString, filename), 0)
      end
   end)
   return status, err
end

local function cleanOnFail(filename)
   run(string.format('mv tomoAuto_%s.err.log ..',filename), filename)
   run(string.format(
      'mv tomoAuto_IMOD.log ../tomoAuto_IMOD_%s.log', filename), filename)
   run(string.format('mv %s_orig.st ../%s.st', filename, filename), filename)
   run(string.format('mv finalFiles_%s ..', filename), filename)
   run(string.format('rm -rf *.com *.log %s* raptor*', filename), filename)
   lfs.chdir('..')
   run(string.format('rm -rf %s', filename), filename)
end

function tomoAuto.reconstruct(stackFile, fidNm, Opts)
   -- These are all of the files created and used throughout
   local filename       = string.sub(stackFile, 1, -4)
   local rawTiltFile    = filename .. '.rawtlt'
   local ccdErasedFile  = filename .. '_fixed.st'
   local origFile       = filename .. '_orig.st'
   local preAliFile     = filename .. '.preali'
   local aliFile        = filename .. '.ali'
   local aliBin4File    = aliFile  .. '.bin4'
   local tltFile        = filename .. '.tlt'
   local fidFile        = filename .. '.fid'
   local fidTxtFile     = fidFile  .. '.txt'
   local fidXfFile      = filename .. '_fid.xf'
   local xfFile         = filename .. '.xf'
   local localFile      = filename .. 'local.xf'
   local xTiltFile      = filename .. '.xtilt'
   local zFacFile       = filename .. '.zfac'
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
   local logFile        = 'tomoAuto_'     .. filename .. '.log'
   local errLogFile     = 'tomoAuto_'     .. filename .. '.err.log'
   local finalFiles     = 'finalFiles_'   .. filename
   local rFidFile       = 'raptor1/IMOD/' .. filename .. '.fid.txt'

   -- If help flag is called display help and then exit
   if Opts.h then
      tomoLib.dispHelp()
      return 0
   end

   -- Multiple times throughout we will check for enough disk space
   local status, err = tomoLib.checkFreeSpace(lfs.currentdir())
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- Here we read the MRC file format header
   local header = MRCIOLib.getReqdHeader(stackFile, fidNm)

   -- If we are applying CTF correction, we make sure we have a defocus.
   -- TODO: Check defocus from header and check if it is sensible
   if Opts.c then
      if Opts.d_ then
         header.defocus = Opts.d_
      elseif not header.defocus then
         io.stderr:write('You need to enter an approximate defocus to run \z
            with CTF correction.\n')
         return 1
      end
   end

   -- Environment setup, make folder with file basename
   status, err = pcall(lfs.mkdir, filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = pcall(os.execute, string.format(
      'mv %s %s', stackFile, filename))
   if not status then
      io.stderr:write(err)
      return 1
   end
   if Opts.l_ then
      status, err = pcall(os.execute, string.format(
         'cp %s %s', Opts.l_, filename))
      if not status then
         io.stderr:write(err)
         return 1
      end
   end
   status, err = pcall(lfs.chdir, filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = pcall(os.execute, string.format(
      'touch %s %s', logFile, errLogFile))
   if not status then
      io.stderr:write(err)
      return 1
   end
   local startDir = lfs.currentdir()

   -- Here we write all of the needed command files.
   comWriter.write(stackFile, header, Opts)

   -- Here we extract the tilt angles from the header
   -- TODO: Handle the new DoseFractionations which have tilt angle info
   --       in an mdoc file.
   MRCIOLib.getTilts(stackFile, rawTiltFile)
   tomoLib.isFile(rawTiltFile)

   -- We create this directory as a backup for the original stack
   status, err = pcall(lfs.mkdir, finalFiles)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('cp %s %s', stackFile, finalFiles), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- We should always remove the Xrays from the image using ccderaser
   status, err = run('submfg -s ccderaser.com', filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(ccdErasedFile)
   status, err = run(string.format('mv %s %s', stackFile, origFile), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('mv %s %s', ccdErasedFile, stackFile),
      filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   if Opts.m_ == 'erase' then
      status, err = run(string.format('mv %s %s tomoAuto*.log %s',
         stackFile, origFile, finalFiles), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('rm -rf *.com *.log %s*', filename),
         filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('mv %s/* .', finalFiles), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('rmdir %s', finalFiles), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      lfs.chdir('..')
      return 0
   end

   -- Here we run the Coarse alignment as done in etomo
   status, err = run('submfg -s tiltxcorr.com xftoxg.com prenewstack.com',
      filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(preAliFile)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   status, err = tomoLib.checkFreeSpace(lfs.currentdir())
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('submfg -s raptor1.com', filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   status, err = run(string.format('cp %s .', rFidFile), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   tomoLib.scaleRAPTORModel(fidTxtFile, header, fidFile)
   status, err = run(string.format('cp %s %s', fidFile, finalFiles),
      filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run('submfg -s tiltalign.com xfproduct.com', filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s %s', fidXfFile, xfFile), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('cp %s %s', tltFile, finalFiles), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('cp %s %s', tltFile, fidTltFile), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run('submfg -s newstack.com', filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   status, err = run(string.format('binvol -b 4 -z 1 %s %s',
      aliFile, aliBin4File), filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('cp %s %s %s',
      aliFile, aliBin4File, finalFiles), filename)
   if not status then
      io.stderr:write(err)
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
      status, err = tomoLib.checkFreeSpace(lfs.currentdir())
      if not status then
         io.stderr:write(err)
         cleanOnFail(filename)
         return 1
      end
      status, err = run('submfg -s ctfplotter.com', filename)
      if not status then
         io.stderr:write(err)
         cleanOnFail(filename)
         return 1
      end
      tomoLib.writeLog(filename)
      tomoLib.isFile(dfcFile)
      tomoLib.modCTFPlotter()
      status, err = run(string.format('cp %s ctfplotter.com %s',
         dfcFile, finalFiles), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      if Opts.m_ == 'align' then

         status, err = run(string.format('mv tomoAuto*.log %s',
            finalFiles), filename)
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(string.format('rm -rf *.com *.log %s* raptor1',
            filename), filename)
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(string.format('mv %s/* .', finalFiles), filename)
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(string.format('rmdir %s', finalFiles), filename)
         if not status then
            io.stderr:write(err)
            return 1
         end
         lfs.chdir('..')
         return 0
      end

      if Opts.p_ then
         status, err = run('splitcorrection ctfcorrection.com')
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         status, err = run(string.format(
            'processchunks -g %d ctfcorrection', Opts.p_), filename)
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      else
         status, err = run('submfg -s ctfcorrection.com', filename)
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         tomoLib.isFile(ctfFile)
         tomoLib.writeLog(filename)
      end
      status, err = run(string.format('mv %s %s', aliFile, ali1File), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('mv %s %s', ctfFile, aliFile), filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(string.format('cp %s %s', aliFile, finalFiles),
         filename)
      if not status then
         io.stderr:write(err)
         return 1
      end
   end

   -- Now we erase the gold
   status, err = run(string.format('xfmodel -xf %s %s %s',
      tltXfFile, fidFile, erFidFile), filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run('submfg -s gold_ccderaser.com', filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   tomoLib.writeLog(filename)
   tomoLib.isFile(erAliFile)
   status, err = run(string.format('mv %s %s', aliFile, ali2File), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('mv %s %s', erAliFile, aliFile), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- Finally we compute the reconstruction
   if not Opts.t then      -- Using IMOD to handle the reconstruction.
      status, err = tomoLib.checkFreeSpace(lfs.currentdir())
      if not status then
         io.stderr:write(err)
         cleanOnFail(filename)
         return 1
      end
      if not Opts.s then   -- Using Weighted Back Projection method.
         recFile = filename .. '_full.rec'
         if Opts.p_ then
            status, err = run(string.format('splittilt -n %d tilt.com',
               Opts.p_), filename)
            if not status then
               io.stderr:write(err)
               cleanOnFail(filename)
               return 1
            end
            status, err = run(string.format(
               'processchunks -g %d tilt', Opts.p_), filename)
            if not status then
               io.stderr:write(err)
               cleanOnFail(filename)
               return 1
            end
            tomoLib.writeLog(filename)
         else
            status, err = run('submfg -s tilt.com', filename)
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
            thds), filename)
         if not status then
            io.stderr:write(err)
            cleanOnFail(filename)
            return 1
         end
         status, err = run(string.format(
            'processchunks -g %d tilt_sirt', thds), filename)
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
            aliFile, aliFile), filename)
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
   status, err = run(string.format('clip rotx %s %s', recFile, recFile),
      filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('binvol -binning 4 %s %s',
      recFile, binFile), filename)
   if not status then
      io.stderr:write(err)
      cleanOnFail(filename)
      return 1
   end
   status, err = run(string.format('mv %s %s tomoAuto.log %s',
      recFile, binFile, finalFiles), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('rm -rf *.com *.log %s* raptor*',
      filename), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('mv %s/* .', finalFiles), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(string.format('rmdir %s', finalFiles), filename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   lfs.chdir('..')
   return 0
end
return tomoAuto
