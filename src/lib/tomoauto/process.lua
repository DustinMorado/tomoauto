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

--- Cleans up on successful or unsuccessful run of tomoauto.
-- This function removes all of the intermediate files from the working
-- directory when tomoauto fails or completes.
-- @param input_filename MRC tilt series to process
-- @param options_table A table object with the option flags from yago
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
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
