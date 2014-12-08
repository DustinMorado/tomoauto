#!/usr/bin/env talua
--- Aligns dose-fractioned images.
--
-- This is a program to align dose-fractioned images and produce a sum. It uses
-- IMOD to align the stack, and is a fork of a script by Chen Xu. This is useful
-- when dosefgpu_driftcorr fails to align a stack.
--
-- @script align_dose_fractioned
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.10

local io, os, string = io, os, string
local struct = require 'struct'

-- xfalign options
local reduce_by_binning = 2
local pre_filter_option = '0.01 0.02 0 0.3'

-- xftoxg options
local number_to_fit = 0

-- newstack options
local mode_to_output  = 2
local float_densities = 2

-- xyzproj options
local axis_to_tilt_around = 'Y'

local function write_xfalign(input_filename)
   local basename = string.sub(input_filename, 1, -5)
   local command_filename = string.format('%s_xfalign.com', basename)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format('$xfalign -StandardInput\n\n'))
   command_file:write(string.format('InputImageFile %s\n\n', input_filename))
   command_file:write(string.format('OutputTransformFile %s.xf\n\n', basename))
   command_file:write(string.format('ReduceByBinning %s\n\n', 
      reduce_by_binning))
   command_file:write(string.format('PreCrossCorrelation\n\n'))
   command_file:write(string.format('XcorrFilter %s\n\n', pre_filter_option))
   command_file:close()
end

local function write_xftoxg(input_filename)
   local basename = string.sub(input_filename, 1, -5)
   local command_filename = string.format('%s_xftoxg.com', basename)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format('$xftoxg -StandardInput\n\n'))
   command_file:write(string.format('InputFile %s.xf\n\n', basename))
   command_file:write(string.format('GOutputFile %s.xg\n\n', basename))
   command_file:write(string.format('NumberToFit %s\n\n', number_to_fit))
   command_file:close()
end

local function write_newstack(input_filename)
   local basename = string.sub(input_filename, 1, -5)
   local command_filename = string.format('%s_newstack.com', basename)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format('$newstack -StandardInput\n\n'))
   command_file:write(string.format('InputFile %s\n\n', input_filename))
   command_file:write(string.format('OutputFile %s.ali\n\n', basename))
   command_file:write(string.format('TransformFile %s.xg\n\n', basename))
   command_file:write(string.format('ModeToOutput %s\n\n', mode_to_output))
   command_file:write(string.format('FloatDensities %s\n\n', float_densities))
   command_file:close()
end

local function write_xyzproj(input_filename)
   local basename = string.sub(input_filename, 1, -5)
   local command_filename = string.format('%s_xyzproj.com', basename)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format('$xyzproj -StandardInput\n\n'))
   command_file:write(string.format('InputFile %s.ali\n\n', basename))
   command_file:write(string.format('OutputFile %s_driftcorr.mrc\n\n', 
      basename))
   command_file:write(string.format('AxisToTiltAround %s\n\n',
      axis_to_tilt_around))
   command_file:close()
end

local function run(command)
   local status, exit, signal = os.execute(command)
   if not status or signal ~= 0 then
      error(string.format('\nError: %s failed.\n', command))
   end
   return status, exit, signal
end

--- Aligns dose-fractioned images.
-- Writes IMOD command files to run xfalign, xftoxg, and newstack to generate an
-- aligned dose-fractioned sum image.
-- @param input_filename dose-fractioned stack to align and sum e.g. 'stack.mrc'
function align_dose_fractioned(input_filename)
   local basename = string.sub(input_filename, 1, -5)
   write_xfalign(input_filename)
   write_xftoxg(input_filename)
   write_newstack(input_filename)
   write_xyzproj(input_filename)
   run(string.format('submfg -s %s_xfalign.com', basename))
   run(string.format('submfg -s %s_xftoxg.com', basename))
   run(string.format('submfg -s %s_newstack.com', basename))
   run(string.format('submfg -s %s_xyzproj.com', basename))
   -- Clean up the command files, log files, transforms, and aligned stack
   local log_filename = string.format('align_dose_fractioned_%s.log', basename)
   local log_file = assert(io.open(log_filename, 'w'))
   local xfalign_log_filename = string.format('%s_xfalign.log', basename)
   local xfalign_log_file = assert(io.open(xfalign_log_filename, 'r'))
   local xfalign_log = xfalign_log_file:read('*a')
   xfalign_log_file:close()
   log_file:write(xfalign_log)
   xfalign_log = nil
   local xftoxg_log_filename = string.format('%s_xftoxg.log', basename)
   local xftoxg_log_file = assert(io.open(xftoxg_log_filename, 'r'))
   local xftoxg_log = xftoxg_log_file:read('*a')
   xftoxg_log_file:close()
   log_file:write(xftoxg_log)
   xftoxg_log = nil
   local newstack_log_filename = string.format('%s_newstack.log', basename)
   local newstack_log_file = assert(io.open(newstack_log_filename, 'r'))
   local newstack_log = newstack_log_file:read('*a')
   newstack_log_file:close()
   log_file:write(newstack_log)
   newstack_log = nil
   local xyzproj_log_filename = string.format('%s_xyzproj.log', basename)
   local xyzproj_log_file = assert(io.open(xyzproj_log_filename, 'r'))
   local xyzproj_log = xyzproj_log_file:read('*a')
   xyzproj_log_file:close()
   log_file:write(xyzproj_log)
   xyzproj_log = nil
   run(string.format('rm *com %s*log %s.xf %s.xg %s.ali', basename, basename,
      basename, basename))
end

if not arg[1] then
   io.write('\nUsage: align_dose_fractioned <image.mrc>\n')
   os.exit(0)
end

local status, err = pcall(align_dose_fractioned, arg[1])
if not status then
   io.stderr:write(err)
   os.exit(1)
else
   os.exit(0)
end
