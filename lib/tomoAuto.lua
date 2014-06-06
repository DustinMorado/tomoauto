--[[===========================================================================#
#                                   tomoauto                                   #
#------------------------------------------------------------------------------#
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
#            arg[3] = table with option flags from getoptions_table                     #
#===========================================================================--]]
local tomoauto_directory = os.getenv('TOMOAUTOROOT')
package.path = package.path .. ';' .. tomoauto_directory .. '/lib/?.lua;'
local comWriter = require 'comWriter'
local MRC_IO_lib  = require 'MRC_IO_lib'
local tomoLib   = require 'tomoLib'
local os, string = os, string

local tomoAuto = {}

--[[===========================================================================#
#                                     run                                      #
#------------------------------------------------------------------------------#
# This is a function that runs IMOD commands in a protected environment.       #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: programn to run <string>                                  #
#            arg[2]: Image stack filename <string>                             #
#===========================================================================--]]
local function run(program, filename)
   local status, err = pcall(function()
      local success, exit, signal = os.execute(string.format(
         '%s 1>> tomoAuto_%s.log 2>> tomoAuto_%s.err.log',
          program, filename, filename))
      if (not success) or (signal ~= 0) then
         error(string.format(
            '\nError: %s failed for %s.\n\n', program, filename), 0)
      end
   end)
   return status, err
end

--[[===========================================================================#
#                                clean_on_fail                                 #
#------------------------------------------------------------------------------#
# This is a function that removes all the generated intermediate files in case #
# tomoauto fails to finish correctly.                                          #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: Image stack filename <string>                             #
#===========================================================================--]]
local function clean_on_fail(filename)
   run(string.format('mv tomoAuto_%s.err.log ..',filename), filename)
   run(string.format(
      'mv tomoAuto_IMOD.log ../tomoAuto_IMOD_%s.log', filename), filename)
   run(string.format('mv %s_orig.st ../%s.st', filename, filename), filename)
   run(string.format('mv final_files_directory_%s ..', filename), filename)
   run(string.format('rm -rf *.com *.log %s* raptor*', filename), filename)
   lfs.chdir('..')
   run(string.format('rm -rf %s', filename), filename)
end

function tomoAuto.reconstruct(filename, fiducial_diameter, options_table)
   -- These are all of the files created and used throughout
   local basename                       = string.sub(filename, 1, -4)
   local raw_tilt_filename              = basename .. '.rawtlt'
   local ccd_erased_filename            = basename .. '_fixed.st'
   local original_filename              = basename .. '_orig.st'
   local pre_aligned_filename           = basename .. '.preali'
   local aligned_filename               = basename .. '.ali'
   local aligned_bin4_filename          = basename .. '.ali.bin4'
   local tilt_filename                  = basename .. '.tlt'
   local fiducial_model_filename        = basename .. '.fid'
   local fiducial_text_model_filename   = basename .. '.fid.txt'
   local fiducial_xf_filename           = basename .. '_fid.xf'
   local xf_filename                    = basename .. '.xf'
   local local_xf_file                  = basename .. 'local.xf'
   local xtilt_filename                 = basename .. '.xtilt'
   local zfac_filename                  = basename .. '.zfac'
   local fiducial_tilt_filename         = basename .. '_fid.tlt'
   local defocus_filename               = basename .. '.defocus'
   local first_aligned_filename         = basename .. '_first.ali'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local tilt_xf_filename               = basename .. '.tltxf'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local second_aligned_filename        = basename .. '_second.ali'
   local reconstruction_filename        = basename .. '_full.rec'
   local bin4_filename                  = basename .. '.bin4'
   local log_file                       = 'tomoAuto_' .. basename .. '.log'
   local error_log_file                 = 'tomoAuto_' .. basename .. '.err.log'
   local final_files_directory          = 'final_files_' .. basename
   local RAPTOR_fiducial_model_filename = 'raptor1/IMOD/' .. basename 
                                          .. '.fid.txt'

   -- If help flag is called display help and then exit
   if options_table.h then
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
   local header = MRC_IO_lib.get_required_header(filename, fiducial_diameter)

   -- If we are applying CTF correction, we make sure we have a defocus.
   -- TODO: Check defocus from header and check if it is sensible
   if options_table.c then
      if options_table.d_ then
         header.defocus = options_table.d_
      elseif not header.defocus then
         io.stderr:write('You need to enter an approximate defocus to run \z
            with CTF correction.\n')
         return 1
      end
   end

   -- Environment setup, make folder with file basename
   status, err = pcall(lfs.mkdir, basename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = pcall(
      os.execute, 
      string.format('mv %s %s', filename, basename)
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   if options_table.l_ then
      status, err = pcall(
         os.execute, 
         string.format('cp %s %s', options_table.l_, basename)
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
   end
   status, err = pcall(lfs.chdir, basename)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = pcall(
      os.execute, 
      string.format('touch %s %s', log_file, error_log_file)
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   local start_directory = lfs.currentdir()

   -- Here we write all of the needed command files.
   comWriter.write(filename, header, options_table)

   -- Here we extract the tilt angles from the header
   MRC_IO_lib.get_tilt_angles(filename, raw_tilt_filename)
   tomoLib.isFile(raw_tilt_filename)

   -- We create this directory as a backup for the original stack
   status, err = pcall(lfs.mkdir, final_files_directory)
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format(
         'cp %s %s', 
         filename, 
         final_files_directory
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- We should always remove the Xrays from the image using ccderaser
   status, err = run('submfg -s ccderaser.com', basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   tomoLib.writeLog(basename)
   tomoLib.isFile(ccd_erased_filename)
   status, err = run(
      string.format('mv %s %s', filename, original_filename), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('mv %s %s', ccd_erased_filename, filename),
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   if options_table.m_ == 'erase' then
      status, err = run(
         string.format(
            'mv %s %s tomoAuto*.log %s',
            filename, 
            original_filename, 
            final_files_directory
         ), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(
         string.format('rm -rf *.com *.log %s*', basename),
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(
         string.format('mv %s/* .', final_files_directory), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(
         string.format('rmdir %s', final_files_directory), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      lfs.chdir('..')
      return 0
   end

   -- Here we run the Coarse alignment as done in etomo
   status, err = run(
      'submfg -s tiltxcorr.com xftoxg.com prenewstack.com',
      basename
   )
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   tomoLib.writeLog(basename)
   tomoLib.isFile(pre_aligned_filename)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   status, err = tomoLib.checkFreeSpace(lfs.currentdir())
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   status, err = run('submfg -s raptor1.com', basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   tomoLib.writeLog(basename)
   status, err = run(
      string.format('cp %s .', RAPTOR_fiducial_model_filename), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   tomoLib.scaleRAPTORModel(
      fiducial_text_model_filename, 
      header, 
      fiducial_model_filename
   )
   status, err = run(
      string.format(
         'cp %s %s', 
         fiducial_model_filename, 
         final_files_directory
      ),
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run('submfg -s tiltalign.com xfproduct.com', basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   status, err = run(
      string.format('cp %s %s', fiducial_xf_filename, xf_filename), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('cp %s %s', tilt_filename, final_files_directory), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('cp %s %s', tilt_filename, fiducial_tilt_filename), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run('submfg -s newstack.com', basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   tomoLib.writeLog(basename)
   status, err = run(string.format('binvol -b 4 -z 1 %s %s',
      aligned_filename, aligned_bin4_filename), basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   status, err = run(
      string.format(
         'cp %s %s %s',
         aligned_filename, 
         aligned_bin4_filename, 
         final_files_directory
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = tomoLib.checkAlign(aligned_filename, header.nz)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   if options_table.c then
      status, err = tomoLib.checkFreeSpace(lfs.currentdir())
      if not status then
         io.stderr:write(err)
         clean_on_fail(basename)
         return 1
      end
      status, err = run('submfg -s ctfplotter.com', basename)
      if not status then
         io.stderr:write(err)
         clean_on_fail(basename)
         return 1
      end
      tomoLib.writeLog(basename)
      tomoLib.isFile(defocus_filename)
      tomoLib.modCTFPlotter()
      status, err = run(
         string.format(
            'cp %s ctfplotter.com %s',
            defocus_filename, 
            final_files_directory
         ), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      if options_table.m_ == 'align' then

         status, err = run(
            string.format(
               'mv tomoAuto*.log %s',
               final_files_directory
            ), 
            basename
         )
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(
            string.format(
               'rm -rf *.com *.log %s* raptor1',
               basename
            ), 
            basename
         )
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(
            string.format('mv %s/* .', final_files_directory), 
            basename
         )
         if not status then
            io.stderr:write(err)
            return 1
         end
         status, err = run(
            string.format('rmdir %s', final_files_directory), 
            basename
         )
         if not status then
            io.stderr:write(err)
            return 1
         end
         lfs.chdir('..')
         return 0
      end

      if options_table.p_ then
         status, err = run('splitcorrection ctfcorrection.com')
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
         status, err = run(
            string.format(
               'processchunks -g %d ctfcorrection', 
               options_table.p_
            ), 
            basename
         )
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
         tomoLib.isFile(ctf_corrected_aligned_filename)
         tomoLib.writeLog(basename)
      else
         status, err = run('submfg -s ctfcorrection.com', basename)
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
         tomoLib.isFile(ctf_corrected_aligned_filename)
         tomoLib.writeLog(basename)
      end
      status, err = run(
         string.format(
            'mv %s %s', 
            aligned_filename, 
            first_aligned_filename
         ), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(
         string.format(
            'mv %s %s', 
            ctf_corrected_aligned_filename, 
            aligned_filename
         ), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
      status, err = run(
         string.format(
            'cp %s %s', 
            aligned_filename, 
            final_files_directory
         ), 
         basename
      )
      if not status then
         io.stderr:write(err)
         return 1
      end
   end

   -- Now we erase the gold
   status, err = run(
      string.format(
         'xfmodel -xf %s %s %s',
         tilt_xf_filename, 
         fiducial_model_filename, 
         gold_erase_model_filename
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   status, err = run('submfg -s gold_ccderaser.com', basename)
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   tomoLib.writeLog(basename)
   tomoLib.isFile(gold_erase_filename)
   status, err = run(
      string.format(
         'mv %s %s', 
         aligned_filename, 
         second_aligned_filename
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format(
         'mv %s %s', 
         gold_erase_filename, 
         aligned_filename
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end

   -- Finally we compute the reconstruction
   if not options_table.t then -- Using IMOD to handle the reconstruction.
      status, err = tomoLib.checkFreeSpace(lfs.currentdir())
      if not status then
         io.stderr:write(err)
         clean_on_fail(basename)
         return 1
      end
      if not options_table.s then -- Using Weighted Back Projection method.
         reconstruction_filename = basename .. '_full.rec'
         if options_table.p_ then
            status, err = run(
               string.format('splittilt -n %d tilt.com', options_table.p_), 
               basename
            )
            if not status then
               io.stderr:write(err)
               clean_on_fail(basename)
               return 1
            end
            status, err = run(
               string.format('processchunks -g %d tilt', options_table.p_), 
               basename
            )
            if not status then
               io.stderr:write(err)
               clean_on_fail(basename)
               return 1
            end
            tomoLib.writeLog(basename)
         else
            status, err = run('submfg -s tilt.com', basename)
            if not status then
               io.stderr:write(err)
               clean_on_fail(basename)
               return 1
            end
            tomoLib.writeLog(basename)
         end
      else                 -- Using S.I.R.T method
         local threads = options_table.p_ or '1'
         status, err = run(
            string.format('sirtsetup -n %d -i 15 tilt.com', threads), 
            basename
         )
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
         status, err = run(
            string.format('processchunks -g %d tilt_sirt', threads), 
            basename
         )
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
      end
   else -- Using TOMO3D to handle the reconstruction
      reconstruction_filename  = basename .. '_tomo3d.rec'
      local z             = options_table.z_ or '1200'
      local iterations    = options_table.i_ or '30'
      local threads       = options_table.p_ or '1'
      local tomo3d_string = string.format(
         ' -a %s -i %s -t %d -z %d', 
         tilt_filename, 
         aligned_filename, 
         threads, 
         z
      )
      if header.mode == 6 then
         status, err = run(
            string.format(
               'newstack -mo 1 %s %s',
               aligned_filename, 
               aligned_filename
            ), 
            basename
         )
         if not status then
            io.stderr:write(err)
            clean_on_fail(basename)
            return 1
         end
      end
      if options_table.g then
         tomo3d_string = 'tomo3dhybrid -g 0 ' .. tomo3d_string
      else
         tomo3d_string = 'tomo3d' .. tomo3d_string
      end
      if options_table.s then
         reconstruction_filename = basename .. '_sirt.rec'
         tomo3d_string = string.format(
            '%s -l %d -S -o %s', 
            tomo3d_string, 
            iterations, 
            reconstruction_filename
         )
      else
         tomo3d_string = string.format(
            '%s -o %s', 
            tomo3d_string, 
            reconstruction_filename
         )
      end

      status, err = run(tomo3d_string)
      if not status then
         io.stderr:write(err)
         clean_on_fail(basename)
         return 1
      end
   end
   tomoLib.isFile(reconstruction_filename)

   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   status, err = run(string.format(
         'binvol -binning 4 %s %s',
         reconstruction_filename, 
         bin4_filename
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      clean_on_fail(basename)
      return 1
   end
   status, err = run(string.format(
         'mv %s %s tomoAuto.log %s',
         reconstruction_filename, 
         bin4_filename, 
         final_files_directory
      ), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('rm -rf *.com *.log %s* raptor*',basename), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('mv %s/* .', final_files_directory), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   status, err = run(
      string.format('rmdir %s', final_files_directory), 
      basename
   )
   if not status then
      io.stderr:write(err)
      return 1
   end
   lfs.chdir('..')
   return 0
end
return tomoAuto
