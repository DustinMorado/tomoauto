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
local COM_file_lib    = require 'COM_file_lib'
local MRC_IO_lib      = require 'MRC_IO_lib'
local tomoauto_lib    = require 'tomoauto_lib'
local os, string = os, string

local tomoauto = {}
--[[==========================================================================#
#                                 display_help                                #
#-----------------------------------------------------------------------------#
# A function that displays the usage and options of tomoAuto                  #
#==========================================================================--]]
local function display_help()
   io.write(
   '\nUsage: \n\z
   tomoAuto [OPTIONS] <file> <fidNm>\n\z
   Automates the alignment of tilt series and the reconstruction of\n\z
   these series into 3D tomograms.\n\n\z
   -c, --CTF      \tApplies CTF correction to the aligned stack\n\z
   -d, --defocus  \tUses this as estimated defocus for ctfplotter\n\z
   -g, --GPU      \tUses GPGPU methods to speed up the reconstruction\n\z
   -h, --help     \tPrints this information and exits\n\z
   -i, --iter     \tThe number of SIRT iterations to run [default 30]\n\z
   -l, --config   \tSources a local config file\n\z
   -m, --mode     \tSelect which mode you want to operate\n\z
      continued:  \tavailable modes (erase, align, reconstruct).\n\z  
   -p, --procnum  \tUses <int> processors to speed up tilt\n\z
   -s, --SIRT     \tUse SIRT to reconstruct [default WBP]\n\z
   -t, --tomo3d   \tUse the TOMO3D to compute reconstruction\n\z
   -z, --thickness\tCreate a tomogram with <int> thickness\n'
   )
   return true
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

   if options_table.h then
      display_help()
      return true
   end

   if not input_filename then
      display_help()
      return true
   end

   if not fiducial_diameter then
      io.stderr:write('\nError: Please enter a fiducial size.\n\n')
      display_help()
      return true
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
   local fiducial_model_fixed_filename  = basename .. '_beadtrack.fid'
   local fiducial_text_model_filename   = basename .. '.fid.txt'
   local fiducial_xf_filename           = basename .. '_fid.xf'
   local xf_filename                    = basename .. '.xf'
   local fiducial_tilt_filename         = basename .. '_fid.tlt'
   local defocus_filename               = basename .. '.defocus'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local tilt_xf_filename               = basename .. '.tltxf'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local reconstruction_filename        = basename .. '_full.rec'
   local bin4_filename                  = basename .. '.bin4'
   local log_file                       = 'tomoauto_' .. basename .. '.log'
   local error_log_file                 = 'tomoauto_' .. basename .. '.err.log'
   local RAPTOR_fiducial_model_filename = basename .. '_RAPTOR/IMOD/' 
                                          .. basename .. '.fid.txt'

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
         io.stderr:write(
            string.format(
               '%s %s\n',
               'You need to enter an approximate defocus to run',
               'with CTF correction.'
            )
         )
         display_help()
         return true
      end
   end

   tomoauto_lib.run(string.format(
         'touch %s %s',
         log_file,
         error_log_file
      ),
      basename
   )

   -- Here we write all of the needed command files.
   COM_file_lib.write(input_filename, header, options_table)

   -- Here we extract the tilt angles from the header
   MRC_IO_lib.get_tilt_angles(input_filename, raw_tilt_filename)
   tomoauto_lib.is_file(raw_tilt_filename)

   -- We should always remove the Xrays from the image using ccderaser
   tomoauto_lib.run(
      string.format(
         'submfg -s %s_ccderaser.com',
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(ccd_erased_filename)

   tomoauto_lib.run(
      string.format(
         'mv %s %s',
         input_filename,
         original_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'mv %s %s',
         ccd_erased_filename,
         input_filename
      ),
      basename
   )

   if options_table.m_ == 'erase' then
      tomoauto_lib.run(
         string.format(
            'rm -rf %s*.com %s*.log',
            basename,
            basename
         ),
         basename
      )
      return true
   end

   -- Here we run the Coarse alignment as done in etomo
   tomoauto_lib.run(
      string.format(
         'submfg -s %s_tiltxcorr.com %s_xftoxg.com %s_prenewstack.com',
         basename,
         basename,
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(pre_aligned_filename)

   -- Now we run RAPTOR to produce a succesfully aligned stack
   tomoauto_lib.check_free_space()
   tomoauto_lib.run(
      string.format(
         'submfg -s %s_RAPTOR.com',
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(RAPTOR_fiducial_model_filename)

   tomoauto_lib.run(
      string.format(
         'mv %s .',
         RAPTOR_fiducial_model_filename
      ),
      basename
   )

   tomoauto_lib.scale_RAPTOR_model(
      fiducial_text_model_filename,
      header,
      fiducial_model_filename
   )

   tomoauto_lib.run(
      string.format(
         'submfg -s %s_beadtrack.com',
         basename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'mv %s %s',
         fiducial_model_fixed_filename,
         fiducial_model_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'submfg -s %s_tiltalign.com %s_xfproduct.com',
         basename,
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(fiducial_xf_filename)

   tomoauto_lib.run(
      string.format(
         'cp %s %s',
         fiducial_xf_filename,
         xf_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'cp %s %s',
         tilt_filename,
         fiducial_tilt_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'submfg -s %s_newstack.com',
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(aligned_filename)

   tomoauto_lib.run(
      string.format(
         'binvol -b 4 -z 1 %s %s',
         aligned_filename,
         aligned_bin4_filename
      ),
      basename
   )

   tomoauto_lib.check_alignment(aligned_filename, header.nz)

   -- Ok for the new stuff here we add CTF correction
   -- noise background is now set in the global config file
   if options_table.c then
      tomoauto_lib.check_free_space()

      tomoauto_lib.run(
         string.format(
            'submfg -s %s_ctfplotter.com',
            basename
         ),
         basename
      )
      tomoauto_lib.is_file(defocus_filename)

      if options_table.m_ == 'align' then
         tomoauto_lib.clean_up(basename)
         if options_table.c then
            COM_file_lib.write_final_ctfplotter(input_filename, header)
         end
         return true
      end

      tomoauto_lib.run(
         string.format(
            'submfg -s %s_ctfphaseflip.com',
            basename
         ),
         basename
      )
      tomoauto_lib.is_file(ctf_corrected_aligned_filename)

      tomoauto_lib.run(
         string.format(
            'mv %s %s',
            ctf_corrected_aligned_filename,
            aligned_filename
         ),
         basename
      )
   
   else
      if options_table.m_ == 'align' then
         tomoauto_lib.clean_up(basename)
      end
      return true
   end

   -- Now we erase the gold
   tomoauto_lib.run(
      string.format(
         'xfmodel -xf %s %s %s',
         tilt_xf_filename,
         fiducial_model_filename,
         gold_erase_model_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'submfg -s %s_gold_ccderaser.com',
         basename
      ),
      basename
   )
   tomoauto_lib.is_file(gold_erase_filename)

   tomoauto_lib.run(
      string.format(
         'mv %s %s',
         gold_erase_filename,
         aligned_filename
      ),
      basename
   )

   -- Finally we compute the reconstruction
   tomoauto_lib.check_free_space()
   if not options_table.t then -- Using IMOD to handle the reconstruction.

      if not options_table.s then -- Using Weighted Back Projection method.
         reconstruction_filename = basename .. '_full.rec'
         tomoauto_lib.run(
            string.format(
               'submfg -s %s_tilt.com',
               basename
            ),
            basename
         )
      else                 -- Using S.I.R.T method
         tomoauto_lib.run(
            string.format(
               'sirtsetup -i 15 tilt.com'
            ),
            basename
         )
         tomoauto_lib.run(
            string.format(
               'processchunks localhost tilt_sirt'
            ),
            basename
         )
      end

   else -- Using TOMO3D to handle the reconstruction
      reconstruction_filename  = basename .. '_tomo3d.rec'
      local z                  = options_table.z_ or '1200'
      local iterations         = options_table.i_ or '30'
      local hamming_filter     = 0.35
      local tomo3d_string = string.format(
         ' -a %s -i %s -m %f -z %d',
         tilt_filename,
         aligned_filename,
         hamming_filter,
         z
      )

      if header.mode == 6 then
         tomoauto_lib.run(
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

      tomoauto_lib.run(
         tomo3d_string,
         basename
      )
   end
   tomoauto_lib.is_file(reconstruction_filename)

   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   tomoauto_lib.run(string.format(
         'binvol -binning 4 %s %s',
         reconstruction_filename,
         bin4_filename
      ),
      basename
   )

   tomoauto_lib.run(string.format(
         'clip rotx %s %s',
         bin4_filename,
         bin4_filename
      ),
      basename
   )

   tomoauto_lib.clean_up(basename)
   if options_table.c then
      COM_file_lib.write_final_ctfplotter(input_filename, header)
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
   local basename                       = string.sub(input_filename, 1, -4)
   local aligned_filename               = basename .. '.ali'
   local aligned_bin4_filename          = basename .. '.ali.bin4'
   local tilt_filename                  = basename .. '.tlt'
   local fiducial_model_filename        = basename .. '.fid'
   local defocus_filename               = basename .. '.defocus'
   local first_aligned_filename         = basename .. '_first.ali'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local tilt_xf_filename               = basename .. '.tltxf'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local reconstruction_filename        = basename .. '_full.rec'
   local bin4_filename                  = basename .. '.bin4'
   local log_file                       = 'tomoauto_' .. basename .. '.log'
   local error_log_file                 = 'tomoauto_' .. basename .. '.err.log'

   if options_table.h then
      display_help()
      return true
   end

   tomoauto_lib.check_free_space()

   local header = MRC_IO_lib.get_required_header(
      input_filename,
      fiducial_diameter
   )

   tomoauto_lib.run(
      string.format(
         'touch %s %s',
         log_file,
         error_log_file
      ),
      basename
   )

   -- Here we write all of the needed command files.
   COM_file_lib.write_reconstruction(
      input_filename,
      header,
      options_table
   )

   if options_table.c then
      tomoauto_lib.is_file(defocus_filename)
      tomoauto_lib.run(
         string.format(
            'submfg -s %s_ctfphaseflip.com',
            basename
         ),
         basename
      )
      tomoauto_lib.is_file(ctf_corrected_aligned_filename)

      tomoauto_lib.run(
         string.format(
            'mv %s %s',
            ctf_corrected_aligned_filename,
            aligned_filename
         ),
         basename
      )
   end

   -- Now we erase the gold
   tomoauto_lib.is_file(tilt_xf_filename)
   tomoauto_lib.is_file(fiducial_model_filename)

   tomoauto_lib.run(
      string.format(
         'xfmodel -xf %s %s %s',
         tilt_xf_filename,
         fiducial_model_filename,
         gold_erase_model_filename
      ),
      basename
   )
   tomoauto_lib.is_file(gold_erase_model_filename)

   tomoauto_lib.run(
      string.format(
         'submfg -s %s_gold_ccderaser.com',
          basename
      ),
      basename
   )
   tomoauto_lib.is_file(gold_erase_filename)

   tomoauto_lib.run(
      string.format(
         'mv %s %s',
         gold_erase_filename,
         aligned_filename
      ),
      basename
   )

   tomoauto_lib.run(
      string.format(
         'binvol -binning 4 -zbinning 1 %s %s',
         aligned_filename,
         aligned_bin4_filename
      )
   )

   -- Finally we compute the reconstruction
   tomoauto_lib.check_free_space()
   if not options_table.t then -- Using IMOD to handle the reconstruction.

      if not options_table.s then -- Using Weighted Back Projection method.
         reconstruction_filename = basename .. '_full.rec'
         tomoauto_lib.run(
            string.format(
               'submfg -s %s_tilt.com',
               basename
            ),
            basename
         )

      else                 -- Using S.I.R.T method
         tomoauto_lib.run(
            string.format(
               'sirtsetup -i 15 tilt.com'
            ),
            basename
         )

         tomoauto_lib.run(
            string.format(
               'processchunks localhost tilt_sirt'
            ),
            basename
         )
      end

   else -- Using TOMO3D to handle the reconstruction
      reconstruction_filename  = basename .. '_tomo3d.rec'
      local z                  = options_table.z_ or '1200'
      local iterations         = options_table.i_ or '30'
      local tomo3d_string = string.format(
         ' -a %s -i %s -z %d',
         tilt_filename,
         aligned_filename,
         z
      )

      if header.mode == 6 then
         tomoauto_lib.run(
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

      tomoauto_lib.run(
         tomo3d_string,
         basename
      )
   end
   tomoauto_lib.is_file(reconstruction_filename)

   -- We bin the tomogram by a factor of 4 to make visualization faster
   -- We bin the alignment by 4 as well to check the alignment quality
   tomoauto_lib.run(string.format(
         'binvol -binning 4 %s %s',
         reconstruction_filename,
         bin4_filename
      ),
      basename
   )

   tomoauto_lib.run(string.format(
         'clip rotx %s %s',
         bin4_filename,
         bin4_filename
      ),
      basename
   )

   tomoauto_lib.clean_up(basename)
   return true
end

return tomoauto
