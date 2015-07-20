#!/usr/bin/env talua
--- Takes aligned dose-fractioned sums and produces a tilt series.
--
-- This is a program to take a set of drift-corrected dose-fractioned sum images
-- and creates an MRC tilt-series. It also fixes the header information which is
-- currently erased by Xueming Li's dosefgpu_driftcorr program.
--
-- NOTE: This currently handles a bug in the beta version of SerialEM 3.4
--
-- Dependencies: `MRC_IO_lib`
--
-- @script dose_fractioned_to_stack
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.30

local io, string, table = io, string, table
local MRCIO = require('tomoauto_mrcio')
local Config = require('tomoauto_config')
local Utils = require('tomoauto_utils')
local yalgo = require('yalgo')

local parser = yalgo:new_parser('Make motion corrected tilt-series.')
parser:add_argument({
  name = 'input',
  is_positional = true,
  is_required = true,
  description = 'Input non motion corrected tilt-series from SerialEM',
  meta_value = 'INPUT.st'
})

parser:add_argument({
  name = 'output',
  is_positional = true,
  default_value = 'TOMOAUTO{basename}_driftcorr.st',
  description = 'Output motion corrected tilt-series',
  meta_value = 'OUTPUT.st'
})

parser:add_argument({
  name = 'run_motioncorr',
  long_option = '--MOTIONCORR',
  short_option = '-M',
  description = 'Run MOTIONCORR on non corrected sub-frames if needed',
})

local options = parser:get_arguments()

if not Utils.is_file(options.input) then
  error('ERROR: dose_fractioned_to_stack: Input file does not exist.\n')
end

local input_mrc = MRCIO:new_mrc(options.input)
local output_mrc = MRCIO:new_mrc(options.output)
local log_filename = input_mrc.basename .. '.log'

if not input_mrc.has_mdoc and not Utils.is_file(log_filename) then
  error('ERROR: dose_fractioned_to_stack: No mdoc or log file to make stack.\n')
end

local timestamp_regex = '(%u%l%l%d%d_%d%d%.%d%d%.%d%d%.mrc)$'
local subframes = {}
if input_mrc.has_mdoc then
  local mdoc_file = io.open(input_mrc.mdoc_filename, 'r')
  for line in mdoc_file:lines('*l') do
    if string.match(line, 'SubFramePath') then
      table.insert(subframes, string.match(line, timestamp_regex))
    end
  end

else
   local log_file = io.open(log_filename, 'r')
   for line in log_file:lines('*l') do
      if string.match(line, 'Opened')
--- Takes aligned dose-fractioned sums and produces a tilt-series.
-- Reads the log output by SerialEM in collecting dose-fractioned tilt series
-- and creates a tilt series using the corresponding drift-corrected sums. Then
-- copies the header information from the initial tilt-series that is lost in
-- drift-correction and writes it to the header of the new tilt-series.
-- @param input_filename initial tilt-series collected e.g. 'image.st'
   local temporary_filename   = basename .. '_temp.st'
   local shift                = 0

   local log_file = io.open(log_filename, 'r')
   for line in log_file:lines('*l') do
      local true_start    = string.match(line, 'Opened')
      local mrc_filename  = string.match(line, '[%w%-%_%.]+%.mrc')
      local is_data_loss  = string.find(line, 'This%sRecord[%s%w]+data%sloss')
      local is_low_count  = string.find(line, 'sufficient%scount')
      local tilt_angle    = string.match(line, 'Tilt%s=%s([%-%d%.]+)')
      local is_terminated = string.find(line, 'TERMINATING')

      if true_start then
         MRC_table = {}
         tilt_angle_table = {}
      end

      if mrc_filename then
         local basename   = string.sub(mrc_filename, 1, -5)
         local new_mrc_filename = string.format('%s_driftcorr.mrc', basename)
         table.insert(MRC_table, new_mrc_filename)
      end

      if is_data_loss then
         if #MRC_table ~= #tilt_angle_table then
            table.remove(MRC_table)
         end
      end

      if is_low_count then
         if #MRC_table ~= #tilt_angle_table then
            table.remove(MRC_table)
         end
      end

      if tilt_angle then
         table.insert(tilt_angle_table, tonumber(tilt_angle))
      end

      if is_terminated then
         error(string.format(
            '\nError: Original stack %s terminated so we will too.\n\n',
            input_filename), 0)
      end
   end
   log_file:close()

   if #MRC_table ~= #tilt_angle_table then
      error(string.format(
         '\nError: %s has unequal file and tilt angle references.\n\n',
         log_filename), 0)
   else
      number_of_sections = #MRC_table
   end

   for i = 1, number_of_sections do
      local file = io.open(MRC_table[i], 'r')
      if file ~= nil then
         file:close()
         local last_index = #new_tilt_angle_table
         if last_index == 0 then
            table.insert(new_tilt_angle_table, tilt_angle_table[i])
            table.insert(new_MRC_table, MRC_table[i])
         elseif tilt_angle_table[i] > new_tilt_angle_table[1] then
            table.insert(new_tilt_angle_table, 1, tilt_angle_table[i])
            table.insert(new_MRC_table, 1, MRC_table[i])
         elseif tilt_angle_table[i] < new_tilt_angle_table[last_index] then
            table.insert(new_tilt_angle_table, tilt_angle_table[i])
            table.insert(new_MRC_table, MRC_table[i])
         else
            error(string.format(
               '\nError: %s has unordered or duplicate tilt angles.\n\n',
               log), 0)
         end
      else
         io.stderr:write(string.format(
            'Warning: Dosefgpu_driftcorr did not process %s.\n', MRC_table[i]))
      end
   end
   number_of_sections = #new_MRC_table

   local filelist = io.open(filelist_name, 'w')
   filelist:write(string.format('%d\n', number_of_sections))

   for i = 1, number_of_sections do
      filelist:write(string.format('%s\n0\n', new_MRC_table[i]))
   end
   filelist:close()

   run(string.format('newstack -filei %s %s', filelist_name,
      new_stack_filename), basename)
   is_file(new_stack_filename)

   header          = MRC_IO_lib.get_header(input_filename)
   extended_header = MRC_IO_lib.get_extended_header(input_filename)
   
   --[[
   -- SerialEM beta 3.4 bug work around
   for i = 1, number_of_sections do 
      if math.floor(new_tilt_angle_table[i]) == -2 then
         table.insert(extended_header, i, {})
         for k,v in pairs(extended_header[i - 1]) do
            extended_header[i][k] = v
         end
      end
      extended_header[i].a_tilt = new_tilt_angle_table[i]
   end
   --]]

   local initial_driftcorr_header = MRC_IO_lib.get_header(new_stack_filename)
   local pixel_spacing = header.xlen / header.mx

   header.nx    = initial_driftcorr_header.nx
   header.ny    = initial_driftcorr_header.ny
   header.nz    = number_of_sections

   header.mode  = 2

   header.mx    = initial_driftcorr_header.nx
   header.my    = initial_driftcorr_header.ny
   header.mz    = number_of_sections

   header.xlen  = pixel_spacing * header.mx
   header.ylen  = pixel_spacing * header.my
   header.zlen  = pixel_spacing * header.mz

   header.amin  = initial_driftcorr_header.amin
   header.amax  = initial_driftcorr_header.amax
   header.amean = initial_driftcorr_header.amean

   initial_driftcorr_header = nil

   MRC_IO_lib.set_header(new_stack_filename, temporary_filename,
      header, extended_header)
   run(string.format('mv %s %s', temporary_filename,
         new_stack_filename), basename)
   run(string.format('rm -f %s', filelist_name), basename)
end

if not arg[1] then
   io.write('\nUsage: dose_fraction_to_stack <SerialEM_stack.st>\n\n')
   os.exit(0)
end

local status, err = pcall(dose_fractioned_to_stack, arg[1])
if not status then
   io.stderr:write(err)
   os.exit(1)
else
   os.exit(0)
end
