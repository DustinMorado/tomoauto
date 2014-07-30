local tomoauto_directory = os.getenv('TOMOAUTOROOT')
package.cpath = package.cpath .. ';' .. tomoauto_directory .. '/lib/?.so;'
package.path  = package.path  .. ';' ..tomoauto_directory .. '/lib/?.lua;'
local MRC_IO_lib = require 'MRC_IO_lib'
local lfs        = require 'lfs'

local tomoauto_lib = {}

--[[==========================================================================#
#                                   is_file                                   #
#-----------------------------------------------------------------------------#
# A function to check if file exists, since older versions of IMOD have a     #
# funny way of handling exit codes in case of errors.                         #
#-----------------------------------------------------------------------------#
# Arguments: filename = filename to check <string>                            #
#==========================================================================--]]
function tomoauto_lib.is_file(filename)
   local file = io.open(filename, 'r')
   if file ~= nil then
      io.close(file)
      return true
   else
      error(
         string.format(
            '\nError: File %s not found.\n\n',
            filename
         ), 0
      )
   end
end

--[[===========================================================================#
#                                     run                                      #
#------------------------------------------------------------------------------#
# This is a function that runs IMOD commands in a protected environment.       #
#------------------------------------------------------------------------------#
# Arguments: program:  programn to run <string>                                #
#            basename: Image stack basename <string>                           #
#===========================================================================--]]
function tomoauto_lib.run(program, basename)

   if not pcall(tomoauto_lib.is_file,
         string.format('tomoauto_%s.log', basename))
   then
      local file = io.open(string.format('tomoauto_%s.log', basename), 'w')
      file:close()
   end

   if not pcall(tomoauto_lib.is_file,
         string.format('tomoauto_%s.err.log', basename)) 
   then
      local file = io.open(string.format('tomoauto_%s.err.log', basename), 'w')
      file:close()
   end

   local success, exit, signal = os.execute(
      string.format(
         '%s 1>> tomoauto_%s.log 2>> tomoauto_%s.err.log',
         program,
         basename,
         basename
      )
   )

   if not success or signal ~= 0 then
      tomoauto_lib.write_log(basename)
      tomoauto_lib.clean_up(basename)
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
#                                   clean_up                                   #
#------------------------------------------------------------------------------#
# This is a function that removes all the generated intermediate files in case #
# tomoauto fails to finish correctly, or when it finishes.                     #
#------------------------------------------------------------------------------#
# Arguments: basename: Image stack filename base <string>                      #
#===========================================================================--]]
function tomoauto_lib.clean_up(basename)
   local image_stack_filename           = basename .. '.st'
   local raw_tilt_filename              = basename .. '.rawtlt'
   local ccd_erased_filename            = basename .. '_fixed.st'
   local peak_model_filename            = basename .. '_peak.mod'
   local original_filename              = basename .. '_orig.st'
   local pre_xf_filename                = basename .. '.prexf'
   local pre_xg_filename                = basename .. '.prexg'
   local pre_aligned_filename           = basename .. '.preali'
   local fiducial_model_fixed_filename  = basename .. '_beadtrack.fid'
   local three_d_model_filename         = basename .. '.3dmod'
   local fiducial_xyz_filename          = basename .. 'fid.xyz'
   local residual_model_filename        = basename .. '.resid'
   local fiducial_text_model_filename   = basename .. '.fid.txt'
   local fiducial_xf_filename           = basename .. '_fid.xf'
   local xf_filename                    = basename .. '.xf'
   local fiducial_tilt_filename         = basename .. '_fid.tlt'
   local defocus_filename               = basename .. '.defocus'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local xtilt_filename                 = basename .. '.xtilt'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local RAPTOR_directory_name          = basename .. '_RAPTOR'
   local com_filenames                  = basename .. '_*.com'
   local log_filenames                  = basename .. '_*.log'
   local temporary_filenames            = basename .. '*~'

   pcall(os.execute, string.format(
         'rm -rf' .. string.rep(' %s ', 22),
         raw_tilt_filename,
         ccd_erased_filename,
         peak_model_filename,
         pre_xf_filename,
         pre_xg_filename,
         pre_aligned_filename,
         fiducial_model_fixed_filename,
         three_d_model_filename,
         fiducial_xyz_filename,
         residual_model_filename,
         fiducial_text_model_filename,
         fiducial_xf_filename,
         xf_filename,
         fiducial_tilt_filename,
         ctf_corrected_aligned_filename,
         xtilt_filename,
         gold_erase_model_filename,
         gold_erase_filename,
         RAPTOR_directory_name,
         com_filenames,
         log_filenames,
         temporary_filenames
      )
   )

   is_original_filename = io.open(original_filename, 'r')
   if is_original_filename then
      is_original_filename:close()
      pcall(os.execute, string.format(
            'mv %s %s',
            original_filename,
            image_stack_filename
         )
      )
   end
end

--[[==========================================================================#
#                                  write_log                                  #
#-----------------------------------------------------------------------------#
#  A fuction that writes the tomoauto log file                                #
#-----------------------------------------------------------------------------#
# Arguments: basename: image file basename <string>                           #
#==========================================================================--]]
function tomoauto_lib.write_log(basename)
   local logfile = assert(
      io.open(
         string.format(
            'tomoauto_%s.log',
            basename
         ),
         'a+'
      )
   )

   local ccderaser_logfile = io.open(
      string.format(
         '%s_ccderaser.log',
         basename
      ),
      'r'
   )
   if ccderaser_logfile then
      local ccderaser_log = ccderaser_logfile:read('*a')
      ccderaser_logfile:close();
      logfile:write(ccderaser_log, '\n')
   end

   local tiltxcorr_logfile = io.open(
      string.format(
         '%s_tiltxcorr.log',
         basename
      ),
      'r'
   )
   if tiltxcorr_logfile then
      local tiltxcorr_log = tiltxcorr_logfile:read('*a')
      tiltxcorr_logfile:close();
      logfile:write(tiltxcorr_log, '\n')
   end

   local xftoxg_logfile = io.open(
      string.format(
         '%s_xftoxg.log',
         basename
      ),
      'r'
   )
   if xftoxg_logfile then
      local xftoxg_log = xftoxg_logfile:read('*a')
      xftoxg_logfile:close()
      logfile:write(xftoxg_log, '\n')
   end

   local prenewstack_logfile = io.open(
      string.format(
         '%s_prenewstack.log',
         basename
      ),
      'r'
   )
   if prenewstack_logfile then
      local prenewstack_log = prenewstack_logfile:read('*a')
      prenewstack_logfile:close()
      logfile:write(prenewstack_log, '\n')
   end

   local RAPTOR_logfile = io.open(
      string.format(
         'RAPTOR/align/%s_RAPTOR.log',
         basename
      ),
      'r'
   )
   if RAPTOR_logfile then
      local RAPTOR_log = RAPTOR_logfile:read('*a')
      RAPTOR_logfile:close()
      logfile:write(RAPTOR_log, '\n')
   end

   local tiltalign_logfile = io.open(
      string.format(
         '%s_tiltalign.log',
         basename
      ),
      'r'
   )
   if tiltalign_logfile then
      local tiltalign_log = tiltalign_logfile:read('*a')
      tiltalign_logfile:close()
      logfile:write(tiltalign_log, '\n')
   end

   local xfproduct_logfile = io.open(
      string.format(
         '%s_xfproduct.com',
         basename
      ),
      'r'
   )
   if xfproduct_logfile then
      local xfproduct_log = xfproduct_logfile:read('*a')
      xfproduct_logfile:close()
      logfile:write(xfproduct_log, '\n')
   end

   local newstack_logfile = io.open(
      string.format(
         '%s_newstack.com',
         basename
      ),
      'r'
   )
   if newstack_logfile then
      local newstack_log = newstack_logfile:read('*a')
      newstack_logfile:close()
      logfile:write(newstack_log, '\n')
   end

   local ctfplotter_logfile = io.open(
      string.format(
         '%s_ctfplotter.log',
         basename
      ),
      'r'
   )
   if ctfplotter_logfile then
      local ctfplotter_log = ctfplotter_logfile:read('*a')
      ctfplotter_logfile:close()
      logfile:write(ctfplotter_log, '\n')
   end

   local ctfphaseflip_logfile = io.open(
      string.format(
         '%s_ctfphaseflip.log',
         basename
      ),
      'r'
   )
   if ctfphaseflip_logfile then
      local ctfphaseflip_log = ctfphaseflip_logfile:read('*a')
      ctfphaseflip_logfile:close()
      logfile:write(ctfphaseflip_log, '\n')
   end

   local gold_ccderaser_logfile = io.open(
      string.format(
         '%s_gold_ccderaser.log',
         basename
      ),
      'r'
   )
   if gold_ccderaser_logfile then
      local gold_ccderaser_log = gold_ccderaser_logfile:read('*a')
      gold_ccderaser_logfile:close()
      logfile:write(gold_ccderaser_log, '\n')
   end

   local tilt_logfile = io.open(
      string.format(
         '%s_tilt.log',
         basename
      ),
      'r'
   )
   if tilt_logfile then
      local tilt_log = tilt_logfile:read('*a')
      tilt_logfile:close()
      logfile:write(tilt_log, '\n')
   end

   logfile:close()
end

--[[==========================================================================#
#                               check_free_space                              #
#-----------------------------------------------------------------------------#
# A function to check that there is enough free space to successfully run     #
# some of the more data heavy IMOD routines                                   #
#==========================================================================--]]
function tomoauto_lib.check_free_space()
   local file = io.popen(
      string.format(
         'df -h %s',
         lfs.currentdir()
         ),
         'r'
      )
   local contents = file:read('*a')
	file:close()
   local space = tonumber(string.match(contents, '(%d+)%%'))
   if space <= 98 then
      return true
   else
      error(string.format(
            '\nError: Disk usage in %s is above 98%%.\n',
            Directory
         ), 0
      )
   end
end

--[[==========================================================================#
#                              scale_RAPTOR_model                             #
#-----------------------------------------------------------------------------#
# A function that fixes the fiducial model generated by RAPTOR in how its     #
# drawn and scaled.                                                           #
#-----------------------------------------------------------------------------#
# Arguments: input_filename  = RAPTOR generated fid model <string>            #
#            header          = Image stack header <table>                     #
#            output_filename = Output file <string>                           #
#==========================================================================--]]
function tomoauto_lib.scale_RAPTOR_model(
   input_filename,
   header,
   output_filename
)
   local input_file  = assert(io.open(input_filename, 'r'))
   local output_file = assert(io.open(output_filename, 'w'))

   local refcurscale_string = string.format(
      '#refcurscale %5.3f %5.3f %5.3f',
      header.xlen / header.mx,
      header.ylen / header.my,
      header.zlen / header.mz
   )

   for line in input_file:lines('*l') do
      line = string.gsub(
         line,
         'drawmode%s+%d+',
         'drawmode\t1\n\z
         symbol\t\t0\n\z
         symsize\t\t7'
      )
      line = string.gsub(
         line,
         'symbol%s+circle',
         refcurscale_string
      )
      line = string.gsub(line, '^size%s+%d+', '')
      output_file:write(line,'\n')
   end
   input_file:close()
   output_file:close()
end

--[[==========================================================================#
#                               check_alignment                               #
#-----------------------------------------------------------------------------#
# A function that checks the final alignment to make sure that too many high  #
# tilt sections were not cut by newstack or RAPTOR. If more than 10% of the   #
# original sections are missing, we abort the reconstruction                  #
#-----------------------------------------------------------------------------#
# Arguments: input_filename: Aligned Image Stack filename  <string>           #
#            original_nz:    Number of original sections <integer>            #
#==========================================================================--]]
function tomoauto_lib.check_alignment(input_filename, original_nz)
   local header = MRC_IO_lib.get_header(input_filename)
   local aligned_nz = header.nz
   header = nil
   local cut_sections = original_nz - aligned_nz
   if (aligned_nz / original_nz) >= 0.9 then
      return true
   else
      error('\nError: RAPTOR has cut too many sections.\n\n',0)
   end
end

--[[===========================================================================#
#                                median_filter                                 #
#------------------------------------------------------------------------------#
# A command that imitates a median filter of N slices.                         #
#------------------------------------------------------------------------------#
# Arguments: input_filename: image filename <string>                           #
#            filter_size:    filter size <integer>                             #
#===========================================================================--]]
function tomoauto_lib.median_filter(input_filename, filter_size)
   
   if not input_filename then
      error('\nError: No input file entered.\n\n', 0)
   elseif not filter_size then
      error('\nError: No filter size entered.\n\n', 0)
   end
   local median_filtered_filename = input_filename .. filter_size

   local header = MRC_IO_lib.get_header(input_filename)
   local nz = header.nz
   header = nil

   local file_list = assert(io.open('filelist.txt', 'w'))
   file_list:write(nz, '\n')

   filter_size = tonumber(filter_size)
   local is_even = (filter_size % 2 == 0) and true or false

   for i = 1, nz do
      average_filename = string.format(
         '%s.avg_%04d',
         input_filename,
         i
      )
      file_list:write(string.format(
         '%s\n0\n',
         average_filename
      ))
      if is_even then
         if i < nz / 2 then
            left_index  = i - ((filter_size / 2) - 1)
            right_index = i +  (filter_size / 2)
            if left_index < 1 then
               local shift = 1 - left_index
               left_index  = left_index  + shift
               right_index = right_index + shift
            end
         else
            left_index  = i -  (filter_size / 2)
            right_index = i + ((filter_size / 2) - 1)
            if right_index > nz then
               local shift = right_index - nz
               left_index  = left_index  - shift
               right_index = right_index - shift
            end
         end
      else
         left_index  = i - math.floor(filter_size / 2)
         right_index = i + math.floor(filter_size / 2)
         if left_index < 1 then
            local shift = 1 - left_index
            left_index  = left_index  + shift
            right_index = right_index + shift
         elseif right_index > nz then
            local shift = right_index - nz
            left_index  = left_index  - shift
            right_index = right_index - shift
         end
      end
      local success, exit, signal = os.execute(
         string.format(
            'xyzproj -z "%d %d" -axis Y %s %s &> /dev/null',
            left_index,
            right_index,
            input_filename,
            average_filename
         )
      )
      if not success or signal ~= 0 then
         os.execute('rm filelist.txt')
         error('\nError: median_filter xyzproj failed.\n\n', 0)
      end
      tomoauto_lib.is_file(average_filename)
   end
   file_list:close()
   file_list = nil
   success, exit, signal = os.execute(
      string.format(
         'newstack -filei filelist.txt %s &> /dev/null',
         median_filtered_filename
      )
   )
   if not success or signal ~= 0 then
      pcall(os.execute,
         string.format(
            'rm filelist.txt %s %s.avg_*', 
            median_filtered_filename,
            input_filename
         )
      )
      error('\nError: median_filter newstack failed.\n\n', 0)
   end
   tomoauto_lib.is_file(median_filtered_filename)
   success, exit, signal = os.execute(
      string.format(
         'rm -f filelist.txt %s.avg_*',
         input_filename
      )
   )
   if not success or signal ~= 0 then
      error('\nError: median_filter cleanup failed.\n\n', 0)
   end
end

return tomoauto_lib
