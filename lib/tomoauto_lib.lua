--- Main tomoauto module.
-- This program automates the alignment of raw tilt series using the programs
-- IMOD, RAPTOR and TOMO3D. 
-- 
-- Dependencies: `COM_file_lib`
--
-- @module tomoauto_lib
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.10
local tomoauto_lib = {}

local tomoauto_directory = os.getenv('TOMOAUTOROOT')
package.path = package.path .. ';' .. tomoauto_directory .. '/lib/?.lua;'

local COM_file_lib    = require 'COM_file_lib'
local os, string = os, string

local function display_help()
   io.write('\nUsage: \n' ..  'tomoauto [OPTIONS] <file> <fidNm>\n' ..
      'Automates the alignment of tilt series and the reconstruction of\n' ..
      'these series into 3D tomograms.\n\n' ..
      '-c, --CTF      \tApplies CTF correction to the aligned stack\n' ..
      '-d, --defocus  \tUses this as estimated defocus for ctfplotter\n' ..
      '-g, --GPU      \tUses GPGPU methods to speed up the reconstruction\n' ..
      '-h, --help     \tPrints this information and exits\n' ..
      '-i, --iter     \tThe number of SIRT iterations to run [default 30]\n' ..
      '-l, --config   \tSources a local config file\n' ..
      '-m, --mode     \tSelect which mode you want to operate\n' ..
      'continued:  \tavailable modes (erase, align, reconstruct).\n' ..  
      '-n, --new      \tUses autofidseed as opposed to RAPTOR.\n' ..
      '-p, --procnum  \tUses <int> processors to speed up tilt\n' ..
      '-s, --SIRT     \tUse SIRT to reconstruct [default WBP]\n' ..
      '-t, --tomo3d   \tUse the TOMO3D to compute reconstruction\n' ..
      '-z, --thickness\tCreate a tomogram with <int> thickness\n')
end

local function run(command)
   local status, exit, signal = os.execute(command)
   if not status or signal ~= 0 then
      error(string.format('\nError: %s failed.\n', command))
   end
   return status, exit, signal
end

local function is_file(filename)
   local file = io.open(filename, 'r')
   if file ~= nil then
      io.close(file)
      return true
   else
      error(string.format('\nError: File %s not found.\n\n', filename))
   end
end

local function scale_RAPTOR_model(input_filename, output_filename)
   local input_file  = assert(io.open(input_filename, 'r'))
   local output_file = assert(io.open(output_filename, 'w'))
   local refcurscale_string = string.format('#refcurscale %5.3f %5.3f %5.3f',
      1.0, 1.0, 1.0)
   for line in input_file:lines('*l') do
      line = string.gsub(line, 'drawmode%s+%d+', 'drawmode\t1\n' ..
         'symbol\t\t0\nsymsize\t\t7')
      line = string.gsub(line, 'symbol%s+circle', refcurscale_string)
      line = string.gsub(line, '^size%s+%d+', '')
      output_file:write(line,'\n')
   end
   input_file:close()
   output_file:close()
   header = nil
end

local function write_log(input_filename)
   local basename = string.sub(input_filename, 1, -4)
   local logfile = assert(io.open(string.format('tomoauto_%s.log', basename),
      'w'))
   local ccderaser_logfile = io.open(string.format('%s_ccderaser.log',
      basename), 'r')
   if ccderaser_logfile then
      local ccderaser_log = ccderaser_logfile:read('*a')
      ccderaser_logfile:close();
      logfile:write(ccderaser_log, '\n')
      ccderaser_log = nil
   end
   local tiltxcorr_logfile = io.open(string.format('%s_tiltxcorr.log',
      basename), 'r')
   if tiltxcorr_logfile then
      local tiltxcorr_log = tiltxcorr_logfile:read('*a')
      tiltxcorr_logfile:close();
      logfile:write(tiltxcorr_log, '\n')
      tiltxcorr_log = nil
   end
   local xftoxg_logfile = io.open(string.format('%s_xftoxg.log', basename), 'r')
   if xftoxg_logfile then
      local xftoxg_log = xftoxg_logfile:read('*a')
      xftoxg_logfile:close()
      logfile:write(xftoxg_log, '\n')
      xftoxg_log = nil
   end
   local prenewstack_logfile = io.open(string.format('%s_prenewstack.log',
      basename), 'r')
   if prenewstack_logfile then
      local prenewstack_log = prenewstack_logfile:read('*a')
      prenewstack_logfile:close()
      logfile:write(prenewstack_log, '\n')
      prenewstack_log = nil
   end
   local autofidseed_logfile = io.open(string.format('%s_autofidseed.log',
      basename), 'r')
   if autofidseed_logfile then
      local autofidseed_log = autofidseed_logfile:read('*a')
      autofidseed_logfile:close()
      logfile:write(autofidseed_log, '\n')
      autofidseed_log = nil
   end
   local RAPTOR_logfile = io.open(string.format('RAPTOR/align/%s_RAPTOR.log',
      basename), 'r')
   if RAPTOR_logfile then
      local RAPTOR_log = RAPTOR_logfile:read('*a')
      RAPTOR_logfile:close()
      logfile:write(RAPTOR_log, '\n')
      RAPTOR_log = nil
   end
   local beadtrack_logfile = io.open(string.format('%s_beadtrack.log',
      basename), 'r')
   if beadtrack_logfile then
      local beadtrack_log = beadtrack_logfile:read('*a')
      beadtrack_logfile:close()
      logfile:write(beadtrack_log, '\n')
      beadtrack_log = nil
   end
   local tiltalign_logfile = io.open(string.format('%s_tiltalign.log',
      basename), 'r')
   if tiltalign_logfile then
      local tiltalign_log = tiltalign_logfile:read('*a')
      tiltalign_logfile:close()
      logfile:write(tiltalign_log, '\n')
      tiltalign_log = nil
   end
   local xfproduct_logfile = io.open(string.format('%s_xfproduct.log',
      basename), 'r')
   if xfproduct_logfile then
      local xfproduct_log = xfproduct_logfile:read('*a')
      xfproduct_logfile:close()
      logfile:write(xfproduct_log, '\n')
      xfproduct_log = nil
   end
   local newstack_logfile = io.open(string.format('%s_newstack.log',
      basename), 'r')
   if newstack_logfile then
      local newstack_log = newstack_logfile:read('*a')
      newstack_logfile:close()
      logfile:write(newstack_log, '\n')
      newstack_log = nil
   end
   local ctfplotter_logfile = io.open(string.format('%s_ctfplotter.log',
      basename), 'r')
   if ctfplotter_logfile then
      local ctfplotter_log = ctfplotter_logfile:read('*a')
      ctfplotter_logfile:close()
      logfile:write(ctfplotter_log, '\n')
      ctfplotter_log = nil
   end
   local ctfphaseflip_logfile = io.open(string.format('%s_ctfphaseflip.log',
      basename), 'r')
   if ctfphaseflip_logfile then
      local ctfphaseflip_log = ctfphaseflip_logfile:read('*a')
      ctfphaseflip_logfile:close()
      logfile:write(ctfphaseflip_log, '\n')
      ctfphaseflip_log = nil
   end
   local xfmodel_logfile = io.open(string.format('%s_xfmodel.log',
      basename), 'r')
   if xfmodel_logfile then
      local xfmodel_log = xfmodel_logfile:read('*a')
      xfmodel_logfile:close()
      logfile:write(xfmodel_log, '\n')
      xfmodel_log = nil
   end
   local gold_ccderaser_logfile = io.open(string.format('%s_gold_ccderaser.log',
      basename), 'r')
   if gold_ccderaser_logfile then
      local gold_ccderaser_log = gold_ccderaser_logfile:read('*a')
      gold_ccderaser_logfile:close()
      logfile:write(gold_ccderaser_log, '\n')
      gold_ccderaser_log = nil
   end
   local tilt_logfile = io.open(string.format('%s_tilt.log', basename), 'r')
   if tilt_logfile then
      local tilt_log = tilt_logfile:read('*a')
      tilt_logfile:close()
      logfile:write(tilt_log, '\n')
      tilt_log = nil
   end
   logfile:close()
end

--- Cleans up on successful or unsuccessful run of tomoauto.
-- This function removes all of the intermediate files from the working
-- directory when tomoauto fails or completes.
-- @param input_filename MRC tilt series to process
-- @param options_table A table object with the option flags from yago
function tomoauto_lib.clean_up(input_filename, options_table)
   local basename                       = string.sub(input_filename, 1, -4)
   local raw_tilt_filename              = basename .. '.rawtlt'
   local ccd_erased_filename            = basename .. '_fixed.st'
   local peak_model_filename            = basename .. '_peak.mod'
   local original_filename              = basename .. '_orig.st'
   local pre_xf_filename                = basename .. '.prexf'
   local pre_xg_filename                = basename .. '.prexg'
   local pre_aligned_filename           = basename .. '.preali'
   local fiducial_text_model_filename   = basename .. '.fid.txt'
   local seed_model_filename            = basename .. '.seed'
   local autofidseed_directory          =             'autofidseed.dir'
   local autofidseed_info               =             'autofidseed.info'
   local fiducial_model_filename        = basename .. '.fid'
   local three_d_model_filename         = basename .. '.3dmod'
   local residual_model_filename        = basename .. '.resid'
   local fiducial_xyz_filename          = basename .. '_fid.xyz'
   local tilt_filename                  = basename .. '.tlt'
   local x_axis_tilt_filename           = basename .. '.xtilt'
   local tilt_xf_filename               = basename .. '.tltxf'
   local fiducial_xf_filename           = basename .. '_fid.xf'
   local xf_filename                    = basename .. '.xf'
   local fiducial_tilt_filename         = basename .. '_fid.tlt'
   local aligned_filename               = basename .. '.ali'
   local defocus_filename               = basename .. '.defocus'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local RAPTOR_directory_name          = basename .. '_RAPTOR'
   local com_filenames                  = basename .. '_*.com'
   local ctfplotter_com_filename        = basename .. '_ctfplotter.com'
   local ctfplotter_check_filename      = basename .. '_ctfplotter.com.check'
   local log_filenames                  = basename .. '_*.log'
   local temporary_filenames            = basename .. '*~'

   write_log(input_filename)
   pcall(os.execute, string.format('rm -rf' .. string.rep(' %s ', 23),
      raw_tilt_filename,
      ccd_erased_filename,
      peak_model_filename,
      pre_xf_filename,
      pre_xg_filename,
      pre_aligned_filename,
      fiducial_text_model_filename,
      seed_model_filename,
      autofidseed_directory,
      autofidseed_info,
      three_d_model_filename,
      residual_model_filename,
      fiducial_xyz_filename,
      x_axis_tilt_filename,
      fiducial_xf_filename,
      fiducial_tilt_filename,
      ctf_corrected_aligned_filename,
      gold_erase_model_filename,
      gold_erase_filename,
      RAPTOR_directory_name,
      com_filenames,
      log_filenames,
      temporary_filename
   ))
   if options_table.m_ ~= "align" then
      pcall(os.execute, string.format('rm -f %s', tilt_xf_filename))
   end
   if options_table.c then
       if options_table.m_ ~= "reconstruct" then
          pcall(os.execute, string.format('mv %s %s', ctfplotter_check_filename,
              ctfplotter_com_filename
          ))
      end
   end
   local original_file = io.open(original_filename, 'r')
   if original_file then
      original_file:close()
      pcall(os.execute, string.format('mv %s %s', original_filename,
           input_filename))
   end
end

--- Main tomoauto function.
-- This function performs the scripting and automation of processing a collected
-- tilt series, it can simply erase hot pixels, align a tilt series or complete
-- the reconstruction.
-- @param input_filename MRC tilt series to process
-- @param fiducial_diameter Size of fiducial markers in nm
-- @param options_table A table object with the option flags from yago
function tomoauto_lib.process(input_filename, fiducial_diameter, options_table)
   if options_table.h then
      display_help()
      return
   end
   if not input_filename then
      io.stderr:write('\nError: Please enter a tilt series.\n\n')
      display_help()
      return
   end
   if not fiducial_diameter then
      io.stderr:write('\nError: Please enter a fiducial size.\n\n')
      display_help()
      return
   end
   -- These are all of the files created and used throughout
   local basename                       = string.sub(input_filename, 1, -4)
   local raw_tilt_filename              = basename .. '.rawtlt'
   local ccd_erased_filename            = basename .. '_fixed.st'
   local ccd_point_model                = basename .. '_peak.mod'
   local original_filename              = basename .. '_orig.st'
   local pre_xf_filename                = basename .. '.prexf'
   local pre_xg_filename                = basename .. '.prexg'
   local pre_aligned_filename           = basename .. '.preali'
   local fiducial_text_model_filename   = basename .. '.fid.txt'
   local seed_model_filename            = basename .. '.seed'
   local fiducial_model_filename        = basename .. '.fid'
   local fiducial_3dmodel_filename      = basename .. '.3dmod'
   local residual_filename              = basename .. '.resid'
   local fiducial_coordinates_filename  = basename .. '_fid.xyz'
   local tilt_filename                  = basename .. '.tlt'
   local x_axis_tilt_filename           = basename .. '.xtilt'
   local tilt_xf_filename               = basename .. '.tltxf'
   local fiducial_xf_filename           = basename .. '_fid.xf'
   local xf_filename                    = basename .. '.xf'
   local fiducial_tilt_filename         = basename .. '_fid.tlt'
   local aligned_filename               = basename .. '.ali'
   local defocus_filename               = basename .. '.defocus'
   local ctf_corrected_aligned_filename = basename .. '_ctfcorr.ali'
   local gold_erase_model_filename      = basename .. '_erase.fid'
   local gold_erase_filename            = basename .. '_erase.ali'
   local reconstruction_filename        = basename .. '_full.rec'
   local RAPTOR_fiducial_model_filename = basename .. '_RAPTOR/IMOD/' ..
      basename .. '.fid.txt'

   -- Here we write all of the needed command files.
   COM_file_lib.write(input_filename, fiducial_diameter, options_table)
   if options_table.m_ ~= "reconstruct" then
      -- We should always remove the Xrays from the image using ccderaser
      run(string.format('submfg %s_ccderaser.com', basename))
      is_file(ccd_erased_filename)
      run(string.format('mv %s %s', input_filename, original_filename))
      run(string.format('mv %s %s', ccd_erased_filename, input_filename)) 

      -- Here we run the Coarse alignment as done in etomo
      run(string.format('submfg %s_tiltxcorr.com', basename)) 
      run(string.format('submfg %s_xftoxg.com', basename)) 
      run(string.format('submfg %s_prenewstack.com', basename))
      is_file(pre_aligned_filename)
      if options_table.r then
         run(string.format('submfg %s_RAPTOR.com', basename))
         is_file(RAPTOR_fiducial_model_filename)
         run(string.format('mv %s .', RAPTOR_fiducial_model_filename))
         scale_RAPTOR_model(fiducial_text_model_filename,
            seed_model_filename)
      else
         run(string.format('submfg %s_autofidseed.com', basename))
      end
      run(string.format('submfg %s_beadtrack.com', basename))
      run(string.format('submfg %s_tiltalign.com', basename))
      run(string.format('submfg %s_xfproduct.com', basename))
      is_file(fiducial_xf_filename)
      run(string.format('cp %s %s', fiducial_xf_filename, xf_filename))
      run(string.format('cp %s %s', tilt_filename, fiducial_tilt_filename))
      run(string.format('submfg %s_newstack.com', basename))
      is_file(aligned_filename)

      -- Ok for the new stuff here we add CTF correction
      -- noise background is now set in the global config file
      if options_table.c then
         run(string.format('submfg %s_ctfplotter.com', basename))
         is_file(defocus_filename)
      end
      if options_table.m_ == 'align' then
         tomoauto_lib.clean_up(input_filename, options_table)
         return
      end
   end
   if options_table.c then
      run(string.format('submfg %s_ctfphaseflip.com', basename))
      is_file(ctf_corrected_aligned_filename)
      run(string.format('mv %s %s', ctf_corrected_aligned_filename,
         aligned_filename))
   end

   -- Now we erase the gold
   run(string.format('submfg %s_xfmodel.com', basename))
   run(string.format('submfg %s_gold_ccderaser.com', basename))
   is_file(gold_erase_filename)
   run(string.format('mv %s %s', gold_erase_filename, aligned_filename))

   -- Finally we compute the reconstruction
   -- Using IMOD to handle the reconstruction
   if not options_table.t then
      -- Using W.B.P
      if not options_table.s then
         reconstruction_filename = basename .. '_full.rec'
         run(string.format('submfg %s_tilt.com', basename))
      -- Using S.I.R.T
      else
         run(string.format('sirtsetup -i 15 tilt.com'))
         run(string.format('processchunks localhost tilt_sirt'))
      end
   -- Using TOMO3D to handle the reconstruction
   else
      reconstruction_filename  = basename .. '_tomo3d.rec'
      run(string.format('./%s_tomo3d.sh', basename))
   end
   is_file(reconstruction_filename)
   tomoauto_lib.clean_up(input_filename, options_table)
end
return tomoauto_lib
