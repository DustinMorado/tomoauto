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

local tiltxcorr = {}

tiltxcorr = {
  Index = 'tiltxcorr',
  Name = 'TOMOAUTO{basename}_tiltxcorr.com',
  Log = 'TOMOAUTO{basename}_tiltxcorr.log',
  Command = '$tiltxcorr -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{filename}'
  },

  'PieceListFile',
  PieceListFile = {
    use = false,
    value = nil
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.prexf'
  },

  'RotationAngle',
  RotationAngle = {
    use = true,
    value = 'TOMOAUTO{tilt_axis_angle}'
  },

  'FirstTiltAngle',
  FirstTiltAngle = {
    use = false,
    value = nil
  },

  'TiltIncrement',
  TiltIncrement = {
    use = false,
    value = nil
  },

  'TiltFile',
  TiltFile = {
    use = true,
    value = 'TOMOAUTO{basename}.rawtlt'
  },

  'TiltAngles',
  TiltAngles = {
    use = false,
    value = nil
  },

  'AngleOffset',
  AngleOffset = {
    use = false,
    value = nil
  },

  'ReverseOrder',
  ReverseOrder = {
    use = false,
    value = nil
  },

  'FilterRadius1',
  FilterRadius1 = {
    use = false,
    value = nil
  },

  'FilterRadius2',
  FilterRadius2 = {
    use = true,
    value = 0.25
  },

  'FilterSigma1',
  FilterSigma1 = {
    use = true,
    value = 0.03
  },

  'FilterSigma2',
  FilterSigma2 = {
    use = true,
    value = 0.05
  },

  'ExcludeCentralPeak',
  ExcludeCentralPeak = {
    use = false,
    value = nil
  },

  'CentralPeakExclusionCriteria',
  CentralPeakExclusionCriteria = {
    use = false,
    value = nil
  },

  'ShiftLimitsXandY',
  ShiftLimitsXandY = {
    use = false,
    value = nil
  },

  'RectangularLimits',
  RectangularLimits = {
    use = false,
    value = nil
  },

  'CorrelationCoefficient',
  CorrelationCoefficient = {
    use = false,
    value = nil
  },

  'BordersInXandY',
  BordersInXandY = {
    use = false,
    value = nil
  },

  'XMinAndMax',
  XMinAndMax = {
    use = false,
    value = nil
  },

  'YMinAndMax',
  YMinAndMax = {
    use = false,
    value = nil
  },

  'BoundaryModel',
  BoundaryModel = {
    use = false,
    value = nil
  },

  'BoundaryObject',
  BoundaryObject = {
    use = false,
    value = nil
  },

  'BinningToApply',
  BinningToApply = {
    use = false,
    value = nil
  },

  'AntialiasFilter',
  AntialiasFilter = {
    use = false,
    value = nil
  },

  'LeaveTiltAxisShifted',
  LeaveTiltAxisShifted = {
    use = false,
    value = nil
  },

  'PadsInXandY',
  PadsInXandY = {
    use = false,
    value = nil
  },

  'TapersInXandY',
  TapersInXandY = {
    use = false,
    value = nil
  },

  'StartingEndingViews',
  StartingEndingViews = {
    use = false,
    value = nil
  },

  'SkipViews',
  SkipViews = {
    use = false,
    value = nil
  },

  'BreakAtViews',
  BreakAtViews = {
    use = false,
    value = nil
  },

  'CumulativeCorrelation',
  CumulativeCorrelation = {
    use = false,
    value = nil
  },

  'AbsoluteCosineStretch',
  AbsoluteCosineStretch = {
    use = false,
    value = nil
  },

  'NoCosineStretch',
  NoCosineStretch = {
    use = false,
    value = nil
  },

  'IterateCorrelations',
  IterateCorrelations = {
    use = false,
    value = nil
  },

  'SearchMagChanges',
  SearchMagChanges = {
    use = false,
    value = nil
  },

  'ViewsWithMagChanges',
  ViewsWithMagChanges = {
    use = false,
    value = nil
  },

  'MagnificationLimits',
  MagnificationLimits = {
    use = false,
    value = nil
  },

  'SizeOfPatchesXandY',
  SizeOfPatchesXandY = {
    use = false,
    value = nil
  },

  'NumberOfPatchesXandY',
  NumberOfPatchesXandY = {
    use = false,
    value = nil
  },

  'OverlapPatchesXandY',
  OverlapPatchesXandY = {
    use = false,
    value = nil
  },

  'SeedModel',
  SeedModel = {
    use = false,
    value = nil
  },

  'SeedObject',
  SeedObject = {
    use = false,
    value = nil
  },

  'LengthAndOverlap',
  LengthAndOverlap = {
    use = false,
    value = nil
  },

  'PrealignmentTransformFile',
  PrealignmentTransformFile = {
    use = false,
    value = nil
  },

  'ImagesAreBinned',
  ImagesAreBinned = {
    use = false,
    value = nil
  },

  'UnalignedSizeXandY',
  UnalignedSizeXandY = {
    use = false,
    value = nil
  },

  'FindWarpTransforms',
  FindWarpTransforms = {
    use = false,
    value = nil
  },

  'RawAndAlignedPair',
  RawAndAlignedPair = {
    use = false,
    value = nil
  },

  'AppendToWarpFile',
  AppendToWarpFile = {
    use = false,
    value = nil
  },

  'TestOutput',
  TestOutput = {
    use = false,
    value = nil
  },

  'VerboseOutput',
  VerboseOutput = {
    use = false,
    value = nil
  },
}
setmetatable(tiltxcorr, { __index = config.IMOD })

return tiltxcorr
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
