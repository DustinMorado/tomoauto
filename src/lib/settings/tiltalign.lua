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
local tiltalign = {}
package.loaded[...] = tiltalign 

local config = require('tomoauto.config')

tiltalign = {
  Index = 'tiltalign',
  Name = 'TOMOAUTO{basename}_tiltalign.com',
  Log = 'TOMOAUTO{basename}_tiltalign.log',
  Command = '$tiltalign -StandardInput',

  'ModelFile',
  ModelFile = {
    use = true,
    value = 'TOMOAUTO{basename}.fid'
  },

  'ImageFile',
  ImageFile = {
    use = true,
    value = 'TOMOAUTO{basename}.preali'
  },

  'ImageSizeXandY',
  ImageSizeXandY = {
    use = false,
    value = nil
  },

  'ImageOriginXandY',
  ImageOriginXandY = {
    use = false,
    value = nil
  },

  'ImagePixelSizeXandY',
  ImagePixelSizeXandY = {
    use = false,
    value = nil
  },

  'ImagesAreBinned',
  ImagesAreBinned = {
    use = false,
    value = nil
  },

  'OutputModelFile',
  OutputModelFile = {
    use = false,
    value = nil
  },

  'OutputResidualFile',
  OutputResidualFile = {
    use = false,
    value = nil
  },

  'OutputModelAndResidual',
  OutputModelAndResidual = {
    use = true,
    value = 'TOMOAUTO{basename}'
  },

  'OutputTopBotResiduals',
  OutputTopBotResiduals = {
    use = false,
    value = nil
  },

  'OutputFidXYZFile',
  OutputFidXYZFile = {
    use = false,
    value = 'TOMOAUTO{basename}_fid.xyz'
  },

  'OutputTiltFile',
  OutputTiltFile = {
    use = true,
    value = 'TOMOAUTO{basename}.tlt'
  },

  'OutputUnadjustedTiltFile',
  OutputUnadjustedTiltFile = {
    use = false,
    value = nil
  },

  'OutputXAxisTiltFile',
  OutputXAxisTiltFile = {
    use = false,
    value = 'TOMOAUTO{basename}.xtilt'
  },

  'OutputTransformFile',
  OutputTransformFile = {
    use = true,
    value = 'TOMOAUTO{basename}.tltxf'
  },

  'OutputZFactorFile',
  OutputZFactorFile = {
    use = false,
    value = 'TOMOAUTO{basename}.zfac'
  },

  'IncludeStartEndInc',
  IncludeStartEndInc = {
    use = false,
    value = nil
  },

  'IncludeList',
  IncludeList = {
    use = false,
    value = nil
  },

  'ExcludeList',
  ExcludeList = {
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
    value = '1-TOMOAUTO{bidirectional_section}'
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

  'ProjectionStretch',
  ProjectionStretch = {
    use = false,
    value = nil
  },

  'BeamTiltOption',
  BeamTiltOption = {
    use = true,
    value = 2
  },

  'FixedOrInitialBeamTilt',
  FixedOrInitialBeamTilt = {
    use = false,
    value = nil
  },

  'RotOption',
  RotOption = {
    use = true,
    value = 3
  },

  'RotDefaultGrouping',
  RotDefaultGrouping = {
    use = true,
    value = 5
  },

  'RotNondefaultGrouping',
  RotNondefaultGrouping = {
    use = false,
    value = nil
  },

  'RotationFixedView',
  RotationFixedView = {
    use = false,
    value = nil
  },

  'LocalRotOption',
  LocalRotOption = {
    use = false,
    value = 3
  },

  'LocalRotDefaultGrouping',
  LocalRotDefaultGrouping = {
    use = false,
    value = 6
  },

  'LocalRotNondefaultGrouping',
  LocalRotNondefaultGrouping = {
    use = false,
    value = nil
  },

  'TiltOption',
  TiltOption = {
    use = true,
    value = 5
  },

  'TiltFixedView',
  TiltFixedView = {
    use = false,
    value = nil
  },

  'TiltSecondFixedView',
  TiltSecondFixedView = {
    use = false,
    value = nil
  },

  'TiltDefaultGrouping',
  TiltDefaultGrouping = {
    use = true,
    value = 5
  },

  'TiltNondefaultGrouping',
  TiltNondefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalTiltOption',
  LocalTiltOption = {
    use = false,
    value = 5
  },

  'LocalTiltFixedView',
  LocalTiltFixedView = {
    use = false,
    value = nil
  },

  'LocalTiltSecondFixedView',
  LocalTiltSecondFixedView = {
    use = false,
    value = nil
  },

  'LocalTiltDefaultGrouping',
  LocalTiltDefaultGrouping = {
    use = false,
    value = 6
  },

  'LocalTiltNondefaultGrouping',
  LocalTiltNondefaultGrouping = {
    use = false,
    value = nil
  },

  'MagReferenceView',
  MagReferenceView = {
    use = true,
    value = 1
  },

  'MagOption',
  MagOption = {
    use = true,
    value = 3
  },

  'MagDefaultGrouping',
  MagDefaultGrouping = {
    use = true,
    value = 4
  },

  'MagNondefaultGrouping',
  MagNondefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalMagReferenceView',
  LocalMagReferenceView = {
    use = false,
    value = 1
  },

  'LocalMagOption',
  LocalMagOption = {
    use = false,
    value = 3
  },

  'LocalMagDefaultGrouping',
  LocalMagDefaultGrouping = {
    use = false,
    value = 7
  },

  'LocalMagNondefaultGrouping',
  LocalMagNondefaultGrouping = {
    use = false,
    value = nil
  },

  'CompReferenceView',
  CompReferenceView = {
    use = false,
    value = nil
  },

  'CompOption',
  CompOption = {
    use = false,
    value = nil
  },

  'CompDefaultGrouping',
  CompDefaultGrouping = {
    use = false,
    value = nil
  },

  'CompNondefaultGrouping',
  CompNondefaultGrouping = {
    use = false,
    value = nil
  },

  'XStretchOption',
  XStretchOption = {
    use = true,
    value = 0
  },

  'XStretchDefaultGrouping',
  XStretchDefaultGrouping = {
    use = true,
    value = 7
  },

  'XStretchNondefaultGrouping',
  XStretchNondefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalXStretchOption',
  LocalXStretchOption = {
    use = false,
    value = 3
  },

  'LocalXStretchDefaultGrouping',
  LocalXStretchDefaultGrouping = {
    use = false,
    value = 11
  },

  'LocalXStretchNondefaultGrouping',
  LocalXStretchNondefaultGrouping = {
    use = false,
    value = nil
  },

  'SkewOption',
  SkewOption = {
    use = true,
    value = 0
  },

  'SkewDefaultGrouping',
  SkewDefaultGrouping = {
    use = true,
    value = 11
  },

  'SkewNondefaultGrouping',
  SkewNondefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalSkewOption',
  LocalSkewOption = {
    use = false,
    value = 3
  },

  'LocalSkewDefaultGrouping',
  LocalSkewDefaultGrouping = {
    use = false,
    value = 11
  },

  'LocalSkewNondefaultGrouping',
  LocalSkewNondefaultGrouping = {
    use = false,
    value = nil
  },

  'XTiltOption',
  XTiltOption = {
    use = false,
    value = nil
  },

  'XTiltDefaultGrouping',
  XTiltDefaultGrouping = {
    use = false,
    value = nil
  },

  'XTiltNondefaultGrouping',
  XTiltNondefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalXTiltOption',
  LocalXTiltOption = {
    use = false,
    value = nil
  },

  'LocalXTiltDefaultGrouping',
  LocalXTiltDefaultGrouping = {
    use = false,
    value = nil
  },

  'LocalXTiltNondefaultGrouping',
  LocalXTiltNondefaultGrouping = {
    use = false,
    value = nil
  },

  'ResidualReportCriterion',
  ResidualReportCriterion = {
    use = true,
    value = 3.0
  },

  'SurfacesToAnalyze',
  SurfacesToAnalyze = {
    use = true,
    value = 2
  },

  'MetroFactor',
  MetroFactor = {
    use = true,
    value = 0.25
  },

  'MaximumCycles',
  MaximumCycles = {
    use = true,
    value = 1000
  },

  'RobustFitting',
  RobustFitting = {
    use = true,
    value = nil
  },

  'WeightWholeTracks',
  WeightWholeTracks = {
    use = false,
    value = nil
  },

  'KFactorScaling',
  KFactorScaling = {
    use = true,
    value = 1.0
  },

  'WarnOnRobustFailure',
  WarnOnRobustFailure = {
    use = false,
    value = nil
  },

  'MinWeightGroupSizes',
  MinWeightGroupSizes = {
    use = false,
    value = nil
  },

  'AxisZShift',
  AxisZShift = {
    use = true,
    value = 0.0
  },

  'ShiftZFromOriginal',
  ShiftZFromOriginal = {
    use = true,
    value = nil
  },

  'AxisXShift',
  AxisXShift = {
    use = false,
    value = nil
  },

  'LocalAlignments',
  LocalAlignments = {
    use = false,
    value = nil
  },

  'OutputLocalFile',
  OutputLocalFile = {
    use = false,
    value = nil
  },

  'NumberOfLocalPatchesXandY',
  NumberOfLocalPatchesXandY = {
    use = false,
    value = { 5, 5 }
  },

  'TargetPatchSizeXandY',
  TargetPatchSizeXandY = {
    use = false,
    value = nil
  },

  'MinSizeOrOverlapXandY',
  MinSizeOrOverlapXandY = {
    use = true,
    value = { 0.5, 0.5 }
  },

  'MinFidsTotalAndEachSurface',
  MinFidsTotalAndEachSurface = {
    use = true,
    value = { 8, 3}
  },

  'FidXYZCoordinates',
  FidXYZCoordinates = {
    use = false,
    value = nil
  },

  'LocalOutputOptions',
  LocalOutputOptions = {
    use = false,
    value = { 1, 0, 1 }
  },

  'RotMapping',
  RotMapping = {
    use = false,
    value = nil
  },

  'LocalRotMapping',
  LocalRotMapping = {
    use = false,
    value = nil
  },

  'TiltMapping',
  TiltMapping = {
    use = false,
    value = nil
  },

  'LocalTiltMapping',
  LocalTiltMapping = {
    use = false,
    value = nil
  },

  'MagMapping',
  MagMapping = {
    use = false,
    value = nil
  },

  'LocalMagMapping',
  LocalMagMapping = {
    use = false,
    value = nil
  },

  'CompMapping',
  CompMapping = {
    use = false,
    value = nil
  },

  'XStretchMapping',
  XStretchMapping = {
    use = false,
    value = nil
  },

  'LocalXStretchMapping',
  LocalXStretchMapping = {
    use = false,
    value = nil
  },

  'SkewMapping',
  SkewMapping = {
    use = false,
    value = nil
  },

  'LocalSkewMapping',
  LocalSkewMapping = {
    use = false,
    value = nil
  },

  'XTiltMapping',
  XTiltMapping = {
    use = false,
    value = nil
  },

  'LocalXTiltMapping',
  LocalXTiltMapping = {
    use = false,
    value = nil
  },
}
setmetatable(tiltalign, { __index = config.IMOD })

return tiltalign
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
