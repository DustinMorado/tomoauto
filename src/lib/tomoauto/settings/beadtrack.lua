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

local beadtrack = {}

beadtrack = {
  Index = 'beadtrack',
  Name = 'TOMOAUTO{basename}_beadtrack.com',
  Log = 'TOMOAUTO{basename}_beadtrack.log',
  Command = '$beadtrack -StandardInput',

  'InputSeedModel',
  InputSeedModel = {
    use = true,
    value = 'TOMOAUTO{basename}.seed'
  },

  'OutputModel',
  OutputModel = {
    use = true,
    value = 'TOMOAUTO{basename}.fid'
  },

  'ImageFile',
  ImageFile = {
    use = true,
    value = 'TOMOAUTO{basename}.preali'
  },

  'PieceListFile',
  PieceListFile = {
    use = false,
    value = nil
  },

  'PrealignTransformFile',
  PrealignTransformFile = {
    use = true,
    value = 'TOMOAUTO{basename}.prexg'
  },

  'ImagesAreBinned',
  ImagesAreBinned = {
    use = true,
    value = 1
  },

  'XYZOutputFile',
  XYZOutputFile = {
    use = false,
    value = nil
  },

  'ElongationOuptutFile',
  ElongationOuptutFile = {
    use = false,
    value = nil
  },

  'SkipViews',
  SkipViews = {
    use = false,
    value = nil
  },

  'RotationAngle',
  RotationAngle = {
    use = true,
    value = 'TOMOAUTO{tilt_axis_angle}'
  },

  'SeparateGroup',
  SeparateGroup = {
    use = false,
    value = nil
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

  'TiltDefaultGrouping',
  TiltDefaultGrouping = {
    use = true,
    value = 7
  },

  'TiltNondefaultGrouping',
  TiltNondefaultGrouping = {
    use = false,
    value = nil
  },

  'MagDefaultGrouping',
  MagDefaultGrouping = {
    use = true,
    value = 5
  },

  'MagNondefaultGrouping',
  MagNondefaultGrouping = {
    use = false,
    value = nil
  },

  'RotDefaultGrouping',
  RotDefaultGrouping = {
    use = true,
    value = 1
  },

  'RotNondefaultGrouping',
  RotNondefaultGrouping = {
    use = false,
    value = nil
  },

  'MinViewsForTiltalign',
  MinViewsForTiltalign = {
    use = true,
    value = 4
  },

  'CentroidRadius',
  CentroidRadius = {
    use = false,
    value = nil
  },

  'BeadDiameter',
  BeadDiameter = {
    use = true,
    value = 'TOMOAUTO{fiducial_diameter_px}'
  },

  'MedianForCentroid',
  MedianForCentroid = {
    use = false,
    value = nil
  },

  'LightBeads',
  LightBeads = {
    use = false,
    value = nil
  },

  'FillGaps',
  FillGaps = {
    use = true,
    value = nil
  },

  'MaxGapSize',
  MaxGapSize = {
    use = true,
    value = 5
  },

  'MinTiltRangeToFindAxis',
  MinTiltRangeToFindAxis = {
    use = true,
    value = 10.0
  },

  'MinTiltRangeToFindAngles',
  MinTiltRangeToFindAngles = {
    use = true,
    value = 20.0
  },

  'BoxSizeXandY',
  BoxSizeXandY = {
    use = true,
    value = { 128, 128 }
  },

  'RoundsOfTracking',
  RoundsOfTracking = {
    use = true,
    value = 2
  },

  'MaxViewsInAlign',
  MaxViewsInAlign = {
    use = false,
    value = nil
  },

  'RestrictViewsOnRound',
  RestrictViewsOnRound = {
    use = false,
    value = nil
  },

  'UnsplitFirstRound',
  UnsplitFirstRound = {
    use = false,
    value = nil
  },

  'LocalAreaTracking',
  LocalAreaTracking = {
    use = true,
    value = 1
  },

  'LocalAreaTargetSize',
  LocalAreaTargetSize = {
    use = true,
    value = 1000
  },

  'MinBeadsInArea',
  MinBeadsInArea = {
    use = true,
    value = 8
  },

  'MinOverlapBeads',
  MinOverlapBeads = {
    use = true,
    value = 5
  },

  'TrackObjectsTogether',
  TrackObjectsTogether = {
    use = false,
    value = nil
  },

  'MaxBeadsToAverage',
  MaxBeadsToAverage = {
    use = true,
    value = 4
  },

  'SobelFilterCentering',
  SobelFilterCentering = {
    use = true,
    value = 1
  },

  'KernelSigmaForSobel',
  KernelSigmaForSobel = {
    use = true,
    value = 1.5
  },

  'AverageBeadsForSobel',
  AverageBeadsForSobel = {
    use = false,
    value = nil
  },

  'InterpolationType',
  InterpolationType = {
    use = false,
    value = nil
  },

  'PointsToFitMaxAndMin',
  PointsToFitMaxAndMin = {
    use = true,
    value = { 7, 3 }
  },

  'DensityRescueFractionAndSD',
  DensityRescueFractionAndSD = {
    use = true,
    value = { 0.6, 1.0 }
  },

  'DistanceRescueCriterion',
  DistanceRescueCriterion = {
    use = true,
    value = 10.0
  },

  'RescueRelaxationDensityAndDistance',
  RescueRelaxationDensityAndDistance = {
    use = true,
    value = { 0.7, 0.9 }
  },

  'PostFitRescueResidual',
  PostFitRescueResidual = {
    use = true,
    value = 2.5
  },

  'DensityRelaxationPostFit',
  DensityRelaxationPostFit = {
    use = true,
    value = 0.9
  },

  'MaxRescueDistance',
  MaxRescueDistance = {
    use = true,
    value = 2.5
  },

  'ResidualsToAnalyzeMaxAndMin',
  ResidualsToAnalyzeMaxAndMin = {
    use = true,
    value = { 9, 5 }
  },

  'DeletionCriterionMinAndSD',
  DeletionCriterionMinAndSD = {
    use = true,
    value = { 0.04, 2.0 }
  },

  'BoxOutputFile',
  BoxOutputFile = {
    use = false,
    value = nil
  },

  'SnapshotViews',
  SnapshotViews = {
    use = false,
    value = nil
  },

  'SaveAllPointsAreaRound',
  SaveAllPointsAreaRound = {
    use = false,
    value = nil
  },
}
setmetatable(beadtrack, { __index = config.IMOD })

return beadtrack
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
