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

local tilt = {}

tilt = {
  Index = 'tilt',
  Name = 'TOMOAUTO{basename}_tilt.com',
  Log = 'TOMOAUTO{basename}_tilt.log',
  Command = '$tilt -StandardInput',

  'InputProjections',
  InputProjections = {
    use = true,
    value = 'TOMOAUTO{basename}.ali'
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}_full.rec'
  },

  'RecFileToReproject',
  RecFileToReproject = {
    use = false,
    value = nil
  },

  'ProjectModel',
  ProjectModel = {
    use = false,
    value = nil
  },

  'BaseRecFile',
  BaseRecFile = {
    use = false,
    value = nil
  },

  'ActionIfGPUFails',
  ActionIfGPUFails = {
    use = true,
    value = { 1, 2 }
  },

  'AdjustOrigin',
  AdjustOrigin = {
    use = true,
    value = nil
  },

  'ANGLES',
  ANGLES = {
    use = false,
    value = nil
  },

  'BaseNumViews',
  BaseNumViews = {
    use = false,
    value = nil
  },

  'BoundaryInfoFile',
  BoundaryInfoFile = {
    use = false,
    value = nil
  },

  'COMPFRACTION',
  COMPFRACTION = {
    use = false,
    value = nil
  },

  'COMPRESS',
  COMPRESS = {
    use = false,
    value = nil
  },

  'ConstrainSign',
  ConstrainSign = {
    use = false,
    value = nil
  },

  'COSINTERP',
  COSINTERP = {
    use = false,
    value = nil
  },

  'DENSWEIGHT',
  DENSWEIGHT = {
    use = false,
    value = nil
  },

  'DONE',
  DONE = {
    use = false,
    value = nil
  },

  'EXCLUDELIST2',
  EXCLUDELIST2 = {
    use = false,
    value = nil
  },

  'FlatFilterFraction',
  FlatFilterFraction = {
    use = false,
    value = nil
  },

  'FBPINTERP',
  FBPINTERP = {
    use = false,
    value = nil
  },

  'FULLIMAGE',
  FULLIMAGE = {
    use = false,
    value = nil
  },

  'IMAGEBINNED',
  IMAGEBINNED = {
    use = true,
    value = 1
  },

  'INCLUDE',
  INCLUDE = {
    use = false,
    value = nil
  },

  'LOCALFILE',
  LOCALFILE = {
    use = false,
    value = nil
  },

  'LOCALSCALE',
  LOCALSCALE = {
    use = false,
    value = nil
  },

  'LOG',
  LOG = {
    use = true,
    value = 0.0
  },

  'MASK',
  MASK = {
    use = false,
    value = nil
  },

  'MinMaxMean',
  MinMaxMean = {
    use = false,
    value = nil
  },

  'MODE',
  MODE = {
    use = false,
    value = nil
  },

  'OFFSET',
  OFFSET = {
    use = false,
    value = nil
  },

  'PARALLEL',
  PARALLEL = {
    use = false,
    value = nil
  },

  'PERPENDICULAR',
  PERPENDICULAR = {
    use = true,
    value = nil
  },

  'RADIAL',
  RADIAL = {
    use = true,
    value = { 0.35, 0.05 }
  },

  'REPLICATE',
  REPLICATE = {
    use = false,
    value = nil
  },

  'REPROJECT',
  REPROJECT = {
    use = false,
    value = nil
  },

  'RotateBy90',
  RotateBy90 = {
    use = false,
    value = nil
  },

  'SCALE',
  SCALE = {
    use = true,
    value = { 0.0, 700.0 }
  },

  'SHIFT',
  SHIFT = {
    use = true,
    value = { 0.0, 0.0 }
  },

  'SIRTIterations',
  SIRTIterations = {
    use = false,
    value = nil
  },

  'SIRTSubtraction',
  SIRTSubtraction = {
    use = false,
    value = nil
  },

  'SLICE',
  SLICE = {
    use = false,
    value = nil
  },

  'StartingIteration',
  StartingIteration = {
    use = false,
    value = nil
  },

  'SUBSETSTART',
  SUBSETSTART = {
    use = true,
    value = { 0, 0 }
  },

  'SubtractFromBase',
  SubtractFromBase = {
    use = false,
    value = nil
  },

  'THICKNESS',
  THICKNESS = {
    use = true,
    value = 1200
  },

  'TILTFILE',
  TILTFILE = {
    use = true,
    value = 'TOMOAUTO{basename}.tlt'
  },

  'TITLE',
  TITLE = {
    use = false,
    value = nil
  },

  'TOTALSLICES',
  TOTALSLICES = {
    use = false,
    value = nil
  },

  'UseGPU',
  UseGPU = {
    use = false,
    value = nil
  },

  'ViewsToReproject',
  ViewsToReproject = {
    use = false,
    value = nil
  },

  'VertBoundaryFile',
  VertBoundaryFile = {
    use = false,
    value = nil
  },

  'VertSliceOutputFile',
  VertSliceOutputFile = {
    use = false,
    value = nil
  },

  'VertForSIRTInput',
  VertForSIRTInput = {
    use = false,
    value = nil
  },

  'WeightAngleFile',
  WeightAngleFile = {
    use = false,
    value = nil
  },

  'WeightFile',
  WeightFile = {
    use = false,
    value = nil
  },

  'WIDTH',
  WIDTH = {
    use = false,
    value = nil
  },

  'XAXISTILT',
  XAXISTILT = {
    use = false,
    value = nil
  },

  'XMinAndMaxReproj',
  XMinAndMaxReproj = {
    use = false,
    value = nil
  },

  'XTILTFILE',
  XTILTFILE = {
    use = false,
    value = nil
  },

  'XTILTINTERP',
  XTILTINTERP = {
    use = false,
    value = nil
  },

  'YMinAndMaxReproj',
  YMinAndMaxReproj = {
    use = false,
    value = nil
  },

  'ZFACTORFILE',
  ZFACTORFILE = {
    use = false,
    value = nil
  },

  'ZMinAndMaxReproj',
  ZMinAndMaxReproj = {
    use = false,
    value = nil
  },

  'DebugOutput',
  DebugOutput = {
    use = false,
    value = nil
  },

  'InternalSIRTSlices',
  InternalSIRTSlices = {
    use = false,
    value = nil
  },

  'ParameterFile',
  ParameterFile = {
    use = false,
    value = nil
  },
}
setmetatable(tilt, { __index = config.IMOD })

return tilt
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
