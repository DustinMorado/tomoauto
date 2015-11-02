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
local prenewstack = {}
package.loaded[...] = prenewstack 

local config = require('tomoauto.config')

prenewstack = {
  Index = 'prenewstack',
  Name = 'TOMOAUTO{basename}_prenewstack.com',
  Log = 'TOMOAUTO{basename}_prenewstack.log',
  Command = '$newstack -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.st'
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.preali'
  },

  'FileOfInputs',
  FileOfInputs = {
    use = false,
    value = nil
  },

  'FileOfOutputs',
  FileOfOutputs = {
    use = false,
    value = nil
  },

  'SplitStartingNumber',
  SplitStartingNumber = {
    use = false,
    value = nil
  },

  'AppendExtension',
  AppendExtension = {
    use = false,
    value = nil
  },

  'SectionsToRead',
  SectionsToRead = {
    use = false,
    value = nil
  },

  'NumberedFromOne',
  NumberedFromOne = {
    use = false,
    value = nil
  },

  'ExcludeSections',
  ExcludeSections = {
    use = false,
    value = nil
  },

  'TwoDirectionTiltSeries',
  TwoDirectionTiltSeries = {
    use = false,
    value = nil
  },

  'SkipSectionIncrement',
  SkipSectionIncrement = {
    use = false,
    value = nil
  },

  'NumberToOutput',
  NumberToOutput = {
    use = false,
    value = nil
  },

  'ReplaceSections',
  ReplaceSections = {
    use = false,
    value = nil
  },

  'BlankOutput',
  BlankOutput = {
    use = false,
    value = nil
  },

  'OffsetsInXandY',
  OffsetsInXandY = {
    use = false,
    value = nil
  },

  'ApplyOffsetsFirst',
  ApplyOffsetsFirst = {
    use = false,
    value = nil
  },

  'TransformFile',
  TransformFile = {
    use = true,
    value = 'TOMOAUTO{basename}.prexg'
  },

  'UseTransformLines',
  UseTransformLines = {
    use = false,
    value = nil
  },

  'OneTrasformPerFile',
  OneTrasformPerFile = {
    use = false,
    value = nil
  },

  'RotateByAngle',
  RotateByAngle = {
    use = false,
    value = nil
  },

  'ExpandByFactor',
  ExpandByFactor = {
    use = false,
    value = nil
  },

  'ShrinkByFactor',
  ShrinkByFactor = {
    use = false,
    value = nil
  },

  'AntialiasFilter',
  AntialiasFilter = {
    use = false,
    value = nil
  },

  'BinByFactor',
  BinByFactor = {
    use = false,
    value = nil
  },

  'DistortionField',
  DistortionField = {
    use = false,
    value = nil
  },

  'ImagesAreBinned',
  ImagesAreBinned = {
    use = false,
    value = nil
  },

  'UseFields',
  UseFields = {
    use = false,
    value = nil
  },

  'GradientFile',
  GradientFile = {
    use = false,
    value = nil
  },

  'AdjustOrigin',
  AdjustOrigin = {
    use = false,
    value = nil
  },

  'LinearInterpolation',
  LinearInterpolation = {
    use = false,
    value = nil
  },

  'NearestNeighbor',
  NearestNeighbor = {
    use = false,
    value = nil
  },

  'SizeToOutputInXandY',
  SizeToOutputInXandY = {
    use = false,
    value = nil
  },

  'ModeToOutput',
  ModeToOutput = {
    use = false,
    value = nil
  },

  'BytesSignedInOutput',
  BytesSignedInOutput = {
    use = false,
    value = nil
  },

  'StripExtraHeader',
  StripExtraHeader = {
    use = false,
    value = nil
  },

  'FloatDensities',
  FloatDensities = {
    use = false,
    value = nil
  },

  'MeanAndStandardDeviation',
  MeanAndStandardDeviation = {
    use = false,
    value = nil
  },

  'ContrastBlackWhite',
  ContrastBlackWhite = {
    use = false,
    value = nil
  },

  'ScaleMinAndMax',
  ScaleMinAndMax = {
    use = false,
    value = nil
  },

  'MultiplyAndAdd',
  MultiplyAndAdd = {
    use = false,
    value = nil
  },

  'FillValue',
  FillValue = {
    use = false,
    value = nil
  },

  'TaperAtFill',
  TaperAtFill = {
    use = false,
    value = nil
  },

  'MemoryLimit',
  MemoryLimit = {
    use = false,
    value = nil
  },

  'TestLimits',
  TestLimits = {
    use = false,
    value = nil
  },

  'VerboseOutput',
  VerboseOutput = {
    use = false,
    value = nil
  },
}
setmetatable(prenewstack, { __index = config.IMOD })

return prenewstack
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
