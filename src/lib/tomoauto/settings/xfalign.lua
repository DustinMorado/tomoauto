--[[
  Copyright (c) 2015 Dustin Reed Morado

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
--]]

--- Global default option value setting for tomoauto.
-- This module contains all of the default option values for every command run
-- by tomoauto as well as defaults for the tomoauto program itself such as which
-- program to use for reconstruction and CTF determination. Every effort has
-- been made to include every option for each command.
-- @module settings
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local config = require('tomoauto.config')
local setmetatable = setmetatable

_ENV = nil

local xfalign = {}

xfalign = {
  Index = 'xfalign',
  Name = 'TOMOAUTO{basename}_xfalign.com',
  Log = 'TOMOAUTO{basename}_xfalign.log',
  Command = '$xfalign -StandardInput',

  'InputImageFile',
  InputImageFile = {
    use = true,
    value = 'TOMOAUTO{abspath}'
  },

  'OutputTransformFile',
  OutputTransformFile = {
    use = true,
    value = 'TOMOAUTO{basename}.xf'
  },

  'SizeToAnalyze',
  SizeToAnalyze = {
    use = false,
    value = nil
  },

  'OffsetToSubarea',
  OffsetToSubarea = {
    use = false,
    value = nil
  },

  'EdgeToIgnore',
  EdgeToIgnore = {
    use = false,
    value = nil
  },

  'ReduceByBinning',
  ReduceByBinning = {
    use = true,
    value = 4
  },

  'FilterParameters',
  FilterParameters = {
    use = false,
    value = nil
  },

  'SobelFilter',
  SobelFilter = {
    use = false,
    value = nil
  },

  'ParametersToSearch',
  ParametersToSearch = {
    use = false,
    value = nil
  },

  'LimitsOnSearch',
  LimitsOnSearch = {
    use = false,
    value = nil
  },

  'BilinearInterpolation',
  BilinearInterpolation = {
    use = false,
    value = nil
  },

  'CorrelationCoefficient',
  CorrelationCoefficient = {
    use = false,
    value = nil
  },

  'LocalPatchSize',
  LocalPatchSize = {
    use = false,
    value = nil
  },

  'ReferenceFile',
  ReferenceFile = {
    use = false,
    value = nil
  },

  'PreCrossCorrelation',
  PreCrossCorrelation = {
    use = true,
    value = nil
  },

  'XcorrFilter',
  XcorrFilter = {
    use = true,
    value = { 0.01, 0.02, 0, 0.3 }
  },

  'InitialTransform',
  InitialTransform = {
    use = false,
    value = nil
  },

  'WarpPatchSizeXandY',
  WarpPatchSizeXandY = {
    use = false,
    value = nil
  },

  'BoundaryModel',
  BoundaryModel = {
    use = false,
    value = nil
  },

  'ShiftLimitsForWarp',
  ShiftLimitsForWarp = {
    use = false,
    value = nil
  },

  'SkipSections',
  SkipSections = {
    use = false,
    value = nil
  },

  'BreakAtSections',
  BreakAtSections = {
    use = false,
    value = nil
  },

  'PairedImages',
  PairedImages = {
    use = false,
    value = nil
  },

  'TomogramAverages',
  TomogramAverages = {
    use = false,
    value = nil
  },

  'DifferenceOutput',
  DifferenceOutput = {
    use = false,
    value = nil
  },

  'SectionsNumberedFromOne',
  SectionsNumberedFromOne = {
    use = false,
    value = nil
  },

  'PID',
  PID = {
    use = false,
    value = nil
  },
}
setmetatable(xfalign, { __index = config.IMOD })

return xfalign
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
