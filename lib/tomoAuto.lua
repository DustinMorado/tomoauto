--[[===========================================================================#
#                                   tomoauto                                   #
#------------------------------------------------------------------------------#
# This is a program to automate the alignment of a raw tilt series, use the    #
# program RAPTOR to make a final alignment, use IMOD to estimate the defocus   #
# and then correct the CTF by appropriate phase flipping, and then finally     #
# using eTomo to create the reconstruction.                                    #
#------------------------------------------------------------------------------#
# Author:  Dustin Morado                                                       #
# Written: February 27th 2014                                                  #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: input_filename:    image stack filename <string>                  #
#            fiducial_diameter: fiducial diameter in nanometers <integer>      #
#            options_table:     options as returned by yago <table>            #
#===========================================================================--]]
local tomoauto_directory = os.getenv('TOMOAUTOROOT')
package.path = package.path .. ';' .. tomoauto_directory .. '/lib/?.lua;'
local COM_file_writer = require 'COM_file_writer'
local MRC_IO_lib      = require 'MRC_IO_lib'
local tomoauto_lib    = require 'tomoauto_lib'
local os, string = os, string

local tomoauto = {}
--[[===========================================================================#
#                                     run                                      #
#------------------------------------------------------------------------------#
# This is a function that runs IMOD commands in a protected environment.       #
#------------------------------------------------------------------------------#
# Arguments: program:  programn to run <string>                                #
#            basename: Image stack basename <string>                           #
#===========================================================================--]]
local function run(program, basename)
   local success, exit, signal = os.execute(
      string.format(
         '%s 1>> tomoauto_%s.log 2>> tomoauto_%s.err.log',
         program,
         basename,
         basename
      )
   )
   if (not success) or (signal ~= 0) then
      error(
         string.format(
            '\nError: %s failed for %s.\n\n',
            program,
            basename
         ), 0
      )
   else
      return success, exit, signal
   end
end
--[[===========================================================================#
#                                clean_on_fail                                 #
#------------------------------------------------------------------------------#
# This is a function that removes all the generated intermediate files in case #
# tomoauto fails to finish correctly.                                          #
#------------------------------------------------------------------------------#
# Arguments: basename: Image stack filename base <string>                      #
#===========================================================================--]]
local function clean_on_fail(basename)
   run(string.format(
         'mv tomoauto_%s.err.log ..',
         basename
      ),
      basename
   )
   run(string.format(
         'mv tomoauto_IMOD.log ../tomoauto_IMOD_%s.log',
         basename
      ),
      basename
   )
   run(string.format(
         'mv %s_orig.st ../%s.st',
         basename,
         basename
      ),
      basename
   )
   run(string.format(
         'mv final_files_directory_%s ..',
         basename
      ),
      basename
   )
   run(string.format(
         'rm -rf *.com *.log %s* RAPTOR',
         basename
      ),
      basename
   )
   local success, err = lfs.chdir('..')
   if not success then
      error(err, 0)
   end
   run(string.format(
         'rm -rf %s',
         basename
      ),
      basename
   )
end
--[[===========================================================================#
#                                   process                                    #
#------------------------------------------------------------------------------#
# This is the main function of tomoauto which performs the automatic process-  #
# ing of a collected tilt series, it can either simply erase hot pixels, stop  #
# at image alignment or completely reconstruct a tomogram.                     #
#------------------------------------------------------------------------------#
# Arguments: input_filename:    Collected tilt series filename <string>        #
#            fiducial_diameter: fiducial diameter in nanometers <integer>      #
#            options_table:     Options as returned by yago <table>            #
#===========================================================================--]]
function tomoauto.process(input_filename, fiducial_diameter, options_table)
   if not fiducial_diameter then
      error('\nError: Please enter a fiducial size.\n\n', 0)
   end
   -- These are all of the files created and used throughout
   local basename                       = string.sub(input_filename, 1, -4)
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
   local log_file                       = 'tomoauto_' .. basename .. '.log'
   local error_log_file                 = 'tomoauto_' .. basename .. '.err.log'
   local final_files_directory          = 'final_files_' .. basename
   local RAPTOR_fiducial_model_filename = 'RAPTOR/IMOD/' .. basename
                                          .. '.fid.txt'

   -- Multiple times throughout we will check for enough disk space
   tomoauto_lib.check_free_space()

   -- Here we read the MRC file format header
   local header = MRC_IO_lib.get_required_header(
      input_filename,
      fiducial_diameter
   )

   -- If we are applying CTF correction, we make sure we have a defocus.
   -- TODO: Check defocus from header and check if it is sensible
   if options_table.c then
      if options_table.d_ then
         header.defocus = options_table.d_
      elseif not header.defocus then
         error(
            'You need to enter an approximate defocus to run \z
            with CTF correction.\n',
            0
         )
      end
   end

   -- Environment setup, make folder with file basename
   local success, err = lfs.mkdir(basename)
   if not success then
      error(err, 0)
   end

   run(string.format(
         'mv %s %s',
         input_filename,
         basename
      ),
      basename
   )

   if options_table.l_ then
      run(string.format(
            'cp %s %s',
            options_table.l_,
            basename
         ),
         basename
      )
   end

   success, err = lfs.chdir(basename)
   if not success then
      error(err, 0)
   end
   local start_directory = lfs.currentdir()

   run(string.format(
         'touch %s %s',
         log_file,
         error_log_file
      ),
      basename
   )

   -- Here we write all of the needed command files.
   COM_file_writer.write(input_filename, header, options_table)

   -- Here we extract the tilt angles from the header
   MRC_IO_lib.get_tilt_angles(input_filename, raw_tilt_filename)
   tomoauto_lib.is_file(raw_tilt_filename)

   -- We create this directory as a backup for the original stack
   success, err = lfs.mkdir(final_files_directory)
   if not success then
      error(err, 0)
   end

   run(string.format(
         'cp %s %s',
         input_filename,
         final_files_directory
      ),
      basename
   )

   -- We should always remove the Xrays from the image using ccderaser
   run('submfg -s ccderaser.com', basename)

   tomoauto_lib.write_log(basename)
   tomoauto_lib.is_file(ccd_erased_filename)

   run(
      string.format(
         'mv %s %s',
         input_filename,
         original_filename
      ),
      basename
   )

   run(
      string.format(
         'mv %s %s',
         ccd_erased_filename,
         input_filename
      ),
      basename
   )

   if options_table.m_ == 'erase' then
      run(
         string.format(
            'mv %s %s tomoauto*.log %s',
            input_filename,
            original_filename,
            final_files_directory
         ),
         basename
      )

      run(
         string.format(
            'rm -rf *.com *.log %s*',
            basename
         ),
         basename
      )

      run(
         string.format(
            'mv %s/* .',
            final_files_directory
         ),
         basename
      )

      run(
         string.format(
            'rmdir %s',
            final_files_directory
         ),
         basename
      )

      success, err = lfs.chdir('..')
      if not success then
         error(err, 0)
      end
      return true
   end

   -- Here we run the Coarse alignment as done in etomo
   run(
      'submfg -s tiltxcorr.com xftoxg.com prenewstack.com',
      basename
   )
   tomoauto_lib.write_log(basename)
   tomoauto_lib.is_file(pre_aligned_filename)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   tomoauto_lib.check_free_space()
   run('submfg -s RAPTOR.com', basename)
   tomoauto_lib.write_log(basename)

   run(
      string.format(
         'cp %s .',
         RAPTOR_fiducial_model_filename
      ),
      basename
   )

   tomoauto_lib.scale_RAPTOR_model(
      fiducial_text_model_filename,
      header,
      fiducial_model_filename
   )
   run(
      string.format(
         'cp %s %s',
         fiducial_model_filename,
         final_files_directory
      ),
      basename
   )

   run(
      'submfg -s tiltalign.com xfproduct.com',
      basename
   )

   run(
      string.format(
         'cp %s %s',
         fiducial_xf_filename,
         xf_filename
      ),
      basename
   )

   run(
      string.format(
         'cp %s %s',
         tilt_filename,
         final_files_directory
      ),
      basename
   )

   run(
      string.format(
         'cp %s %s',
         tilt_filename,
         fiducial_tilt_filename
      ),
      basename
   )

   run(
      'submfg -s newstack.com',
      basename
   )
   tomoauto_lib.write_log(basename)

   run(
      string.format(
         'binvol -b 4 -z 1 %s %s',
         aligned_filename,
         aligned_bin4_filename
      ),
      basename
   )

   run(
      string.format(
         'cp %s %s %s',
         aligned_filename,
         aligned_bin4_filename,
         final_files_directory
      ),
      basename
   )

   tomoauto_lib.check_alignment(aligned_filename, header.nz)

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   if options_table.c then
      tomoauto_lib.check_free_space()

      run(
         'submfg -s ctfplotter.com',
         basename
      )
      tomoauto_lib.write_log(basename)
      tomoauto_lib.is_file(defocus_filename)

      tomoauto_lib.modify_ctfplotter()

      run(
         string.format(
            'cp %s ctfplotter.com %s',
            defocus_filename,
            final_files_directory
         ),
         basename
      )

      if options_table.m_ == 'align' then
         run(
            string.format(
               'mv tomoauto*.log %s',
               final_files_directory
            ),
            basename
         )

         run(
            string.format(
               'rm -rf *.com *.log %s* RAPTOR',
               basename
            ),
            basename
         )

         run(
            string.format(
               'mv %s/* .',
               final_files_directory
            ),
            basename
         )

         run(
            string.format(
               'rmdir %s',
               final_files_directory
            ),
            basename
         )

         success, err = lfs.chdir('..')
         if not success then
            error(err, 0)
         end
         return true
      end

      if options_table.p_ then
         run(
            'splitcorrection ctfcorrection.com',
            basename
         )

         run(
            string.format(
               'processchunks -g %d ctfcorrection',
               options_table.p_
            ),
            basename
         )
         tomoauto_lib.write_log(basename)
         tomoauto_lib.is_file(ctf_corrected_aligned_filename)
      else
         run(
            'submfg -s ctfcorrection.com',
            basename
         )
         tomoauto_lib.write_log(basename)
         tomoauto_lib.is_file(ctf_corrected_aligned_filename)
      end

      run(
         string.format(
            'mv %s %s',
            aligned_filename,
            first_aligned_filename
         ),
         basename
      )

      run(
         string.format(
            'mv %s %s',
            ctf_corrected_aligned_filename,
            aligned_filename
         ),
         basename
      )

      run(
         string.format(
            'cp %s %s',
            aligned_filename,
            final_files_directory
         ),
         basename
      )
   end

   -- Now we erase the gold
   run(
      string.format(
         'xfmodel -xf %s %s %s',
         tilt_xf_filename,
         fiducial_model_filename,
         gold_erase_model_filename
      ),
      basename
   )

   run(
      'submfg -s gold_ccderaser.com',
      basename
   )
   tomoauto_lib.write_log(basename)
   tomoauto_lib.is_file(gold_erase_filename)

   run(
      string.format(
         'mv %s %s',
         aligned_filename,
         second_aligned_filename
      ),
      basename
   )

   run(
      string.format(
         'mv %s %s',
         gold_erase_filename,
         aligned_filename
      ),
      basename
   )

   -- Finally we compute the reconstruction
   if not options_table.t then -- Using IMOD to handle the reconstruction.
      tomoauto_lib.check_free_space()

      if not options_table.s then -- Using Weighted Back Projection method.
         reconstruction_filename = basename .. '_full.rec'
         if options_table.p_ then
            run(
               string.format(
                  'splittilt -n %d tilt.com',
                  options_table.p_
               ),
               basename
            )

            run(
               string.format(
                  'processchunks -g %d tilt',
                  options_table.p_
               ),
               basename
            )
            tomoauto_lib.write_log(basename)

         else
            run(
               'submfg -s tilt.com',
               basename
            )
            tomoauto_lib.write_log(basename)
         end

      else                 -- Using S.I.R.T method
         local threads = options_table.p_ or '1'
         run(
            string.format(
               'sirtsetup -n %d -i 15 tilt.com',
               threads
            ),
            basename
         )

         run(
            string.format(
               'processchunks -g %d tilt_sirt',
               threads
            ),
            basename
         )
      end

   else -- Using TOMO3D to handle the reconstruction
      reconstruction_filename  = basename .. '_tomo3d.rec'
      local z                  = options_table.z_ or '1200'
      local iterations         = options_table.i_ or '30'
      local threads            = options_table.p_ or '1'
      local tomo3d_string = string.format(
         ' -a %s -i %s -t %d -z %d',
         tilt_filename,
         aligned_filename,
         threads,
         z
      )

      if header.mode == 6 then
         run(
            string.format(
               'newstack -mo 1 %s %s',
               aligned_filename,
               aligned_filename
            ),
            basename
         )
      end

      if options_table.g then
         tomo3d_string = string.format(
            '%s %s',
            'tomo3dhybrid -g 0 ',
            tomo3d_string
         )
      else
         tomo3d_string = string.format(
            '%s %s',
            'tomo3d',
            tomo3d_string
         )
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

      run(
         tomo3d_string,
         basename
      )
   end
   tomoauto_lib.is_file(reconstruction_filename)

   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   run(string.format(
         'binvol -binning 4 %s %s',
         reconstruction_filename,
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'clip rotx %s %s',
         bin4_filename,
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'rm %s~',
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'mv %s %s tomoauto.log %s',
         reconstruction_filename,
         bin4_filename,
         final_files_directory
      ),
      basename
   )

   run(
      string.format(
         'rm -rf *.com *.log %s* raptor*',
         basename
      ),
      basename
   )

   run(
      string.format(
         'mv %s/* .',
         final_files_directory
      ),
      basename
   )

   run(
      string.format(
         'rmdir %s',
         final_files_directory
      ),
      basename
   )

   success, err = lfs.chdir('..')
   if not success then
      error(err, 0)
   end
   return true
end
--[[===========================================================================#
#                                 reconstruct                                  #
#------------------------------------------------------------------------------#
# This a program that just takes an aligned stack and applies CTF correction   #
# and/or computes the reconstruction as specified in the options               #
#------------------------------------------------------------------------------#
# Arguments: input_filename:    aligned tilt-series <string>                   #
#            fiducial_diameter: fiducial diameter in nanometers <integer>      #
#            options_table:     Options as returned by yago <table>            #
#===========================================================================--]]
function tomoauto.reconstruct(input_filename, fiducial_diameter, options_table)
   -- These are all of the files created and used throughout
   local basename                       = string.sub(input_filename, 1, -5)
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
   local log_file                       = 'tomoauto_' .. basename .. '.log'
   local error_log_file                 = 'tomoauto_' .. basename .. '.err.log'
   local final_files_directory          = 'final_files_' .. basename
   local RAPTOR_fiducial_model_filename = 'RAPTOR/IMOD/' .. basename
                                          .. '.fid.txt'

   tomoauto_lib.check_free_space()

   local header = MRC_IO_lib.get_required_header(
      input_filename,
      fiducial_diameter
   )

   if options_table.c then
      if options_table.d_ then
         header.defocus = options_table.d_
      elseif not header.defocus then
         error(
            'You need to enter an approximate defocus to run \z
            with CTF correction.\n',
            0
         )
      end
   end

   local success, err = lfs.mkdir(basename)
   if not success then
      error(err, 0)
   end

   run(
      string.format(
         'mv %s %s',
         input_filename,
         basename
      ),
      basename
   )

   if options_table.l_ then
      run(
         string.format(
            'cp %s %s',
            options_table.l_,
            basename
         ),
         basename
      )
   end

   success, err = lfs.chdir(basename)
   if not success then
      error(err, 0)
   end
   local start_directory = lfs.currentdir()

   run(
      string.format(
         'touch %s %s',
         log_file,
         error_log_file
      )
   )

   -- Here we write all of the needed command files.
   COM_file_writer.write(input_filename, header, options_table)

   -- Here we extract the tilt angles from the header
   MRC_IO_lib.get_tilt_angles(input_filename, raw_tilt_filename)
   tomoauto_lib.is_file(raw_tilt_filename)

   -- We create this directory as a backup for the original stack
   success, err = lfs.mkdir(final_files_directory)
   if not success then
      error(err, 0)
   end

   run(
      string.format(
         'cp %s %s',
         input_filename,
         final_files_directory
      ),
      basename
   )

   if options_table.c then
      tomoauto_lib.check_free_space()

      tomoauto_lib.is_file(defocus_filename)

      if options_table.p_ then
         run(
            'splitcorrection ctfcorrection.com',
            basename
         )

         run(
            string.format(
               'processchunks -g %d ctfcorrection',
               options_table.p_
            ),
            basename
         )
         tomoauto_lib.write_log(basename)
         tomoauto_lib.is_file(ctf_corrected_aligned_filename)

      else
         run(
            'submfg -s ctfcorrection.com',
            basename
         )
         tomoauto_lib.write_log(basename)
         tomoauto_lib.is_file(ctf_corrected_aligned_filename)
      end

      run(
         string.format(
            'mv %s %s',
            aligned_filename,
            first_aligned_filename
         ),
         basename
      )

      run(
         string.format(
            'mv %s %s',
            ctf_corrected_aligned_filename,
            aligned_filename
         ),
         basename
      )

      run(
         string.format(
            'cp %s %s',
            aligned_filename,
            final_files_directory
         ),
         basename
      )
   end

   -- Now we erase the gold
   tomoauto_lib.is_file(tilt_xf_filename)
   tomoauto_lib.is_file(fiducial_model_filename)
   tomoauto_lib.is_file(gold_erase_model_filename)

   run(
      string.format(
         'xfmodel -xf %s %s %s',
         tilt_xf_filename,
         fiducial_model_filename,
         gold_erase_model_filename
      ),
      basename
   )

   run(
      'submfg -s gold_ccderaser.com',
      basename
   )
   tomoauto_lib.write_log(basename)
   tomoauto_lib.is_file(gold_erase_filename)

   run(
      string.format(
         'mv %s %s',
         aligned_filename,
         second_aligned_filename
      ),
      basename
   )

   run(
      string.format(
         'mv %s %s',
         gold_erase_filename,
         aligned_filename
      ),
      basename
   )

   -- Finally we compute the reconstruction
   if not options_table.t then -- Using IMOD to handle the reconstruction.
      tomoauto_lib.check_free_space()

      if not options_table.s then -- Using Weighted Back Projection method.
         reconstruction_filename = basename .. '_full.rec'
         if options_table.p_ then
            run(
               string.format(
                  'splittilt -n %d tilt.com',
                  options_table.p_
               ),
               basename
            )

            run(
               string.format(
                  'processchunks -g %d tilt',
                  options_table.p_
               ),
               basename
            )
            tomoauto_lib.write_log(basename)

         else
            run(
               'submfg -s tilt.com',
               basename
            )
            tomoauto_lib.write_log(basename)
         end

      else                 -- Using S.I.R.T method
         local threads = options_table.p_ or '1'
         run(
            string.format(
               'sirtsetup -n %d -i 15 tilt.com',
               threads
            ),
            basename
         )

         run(
            string.format(
               'processchunks -g %d tilt_sirt',
               threads
            ),
            basename
         )
      end

   else -- Using TOMO3D to handle the reconstruction
      reconstruction_filename  = basename .. '_tomo3d.rec'
      local z                  = options_table.z_ or '1200'
      local iterations         = options_table.i_ or '30'
      local threads            = options_table.p_ or '1'
      local tomo3d_string = string.format(
         ' -a %s -i %s -t %d -z %d',
         tilt_filename,
         aligned_filename,
         threads,
         z
      )

      if header.mode == 6 then
         run(
            string.format(
               'newstack -mo 1 %s %s',
               aligned_filename,
               aligned_filename
            ),
            basename
         )
      end

      if options_table.g then
         tomo3d_string = string.format(
            '%s %s',
            'tomo3dhybrid -g 0 ',
            tomo3d_string
         )
      else
         tomo3d_string = string.format(
            '%s %s',
            'tomo3d',
            tomo3d_string
         )
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

      run(
         tomo3d_string,
         basename
      )
   end
   tomoauto_lib.is_file(reconstruction_filename)

   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   run(string.format(
         'binvol -binning 4 %s %s',
         reconstruction_filename,
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'clip rotx %s %s',
         bin4_filename,
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'rm -f %s~',
         bin4_filename
      ),
      basename
   )

   run(string.format(
         'mv %s %s tomoauto.log %s',
         reconstruction_filename,
         bin4_filename,
         final_files_directory
      ),
      basename
   )

   run(
      string.format(
         'rm -rf *.com *.log %s* raptor*',
         basename
      ),
      basename
   )

   run(
      string.format(
         'mv %s/* .',
         final_files_directory
      ),
      basename
   )

   run(
      string.format(
         'rmdir %s',
         final_files_directory
      ),
      basename
   )

   lfs.chdir('..')
   return true
end
return tomoauto
