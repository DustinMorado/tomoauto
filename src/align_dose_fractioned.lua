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
-- @release 0.2.30

local io, os, string = io, os, string
local Config = require('tomoauto_config')
local Utils = require('tomoauto_utils')
local MRCIO = require('tomoauto_mrcio')
local yalgo = require('yalgo')

local parser = yalgo:new_parser('Use IMOD to align dose-fractionated data.')
parser:add_argument({
  name = 'input',
  is_positional = true,
  is_required = true,
  description = 'Input dose-fractionated data stack',
  meta_value = 'INPUT.mrc'
})

parser:add_argument({
  name = 'output',
  is_positional = true,
  description = 'Output aligned micrograph',
  default_value = 'TOMOAUTO{basename}_driftcorr.mrc',
  meta_value = 'OUTPUT.mrc'
})

local options = parser:get_arguments()

if not Utils.is_file(options.input) then
  error('ERROR: align_dose_fractioned: Input file does not exist.\n')
end

local input_mrc = MRCIO:new_mrc(options.input)

-- xfalign options
local xfalign = {
  InputImageFile = { use = true, value = 'TOMOAUTO{basename}.mrc' },
  OutputTransformFile = { use = true, value = 'TOMOAUTO{basename}.xf' },
  ReduceByBinning = { use = true, value = 2 },
  PreCrossCorrelation = { use = true, value = nil },
  XcorrFilter = { use = true, value = { 0.01, 0.02, 0, 0.3 } },
}

Config.xfalign:clear()
Config.xfalign:update(xfalign)
Config.xfalign:run(input_mrc)

-- xftoxg options
local xftoxg = {
  InputFile = { use = true, value = 'TOMOAUTO{basename}.xf' },
  GOutputFile = { use = true, value = 'TOMOAUTO{basename}.xg' },
  NumberToFit = { use = true, value = 0 },
}

Config.xftoxg:clear()
Config.xftoxg:update(xftoxg)
Config.xftoxg:run(input_mrc)

-- newstack options
local newstack = {
  InputFile = { use = true, value = 'TOMOAUTO{basename}.mrc' },
  OutputFile = { use = true, value = 'TOMOAUTO{basename}.ali' },
  TransformFile = { use = true, value = 'TOMOAUTO{basename}.xg' },
  ModeToOutput = { use = true, value = 2 },
  FloatDensities = { use = true, value = 2 },
}

Config.newstack:clear()
Config.newstack:update(newstack)
Config.newstack:run(input_mrc)

-- xyzproj options
local xyzproj = {
  InputFile = { use = true, value = 'TOMOAUTO{basename}.ali' },
  OuputFile = { use = true, value = options.output },
  AxisToTiltAround = { use = true, value = 'Y' },
}

Config.xyzproj:clear()
Config.xyzproj:update(xyzproj)
Config.xyzproj:run(input_mrc)

local log_filename = 'align_dose_fractioned_' .. input_mrc.basename .. '.log'
local log_file = io.open(log_filename, 'w')
for _, log in ipairs({ 'xfalign', 'xftoxg', 'newstack', 'xyzproj' }) do
  local command_filename = input_mrc.basename .. '_' .. log .. '.com'
  local sublog_filename = input_mrc.basename .. '_' .. log .. '.log'
  local sublog_file = io.open(sublog_filename, 'r')
  sublog_data = sublog_file:read('*a')
  sublog_file:close()
  log_file:write(sublog_data)
  Utils.run('rm ' .. sublog_filename)
  Utils.run('rm ' .. command_filename)
end

Utils.run('rm ' .. input_mrc.basename .. '.xf')
Utils.run('rm ' .. input_mrc.basename .. '.xg')
Utils.run('rm ' .. input_mrc.basename .. '.ali')
Utils.run('rm ' .. input_mrc.basename .. '.xcxf')
