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

--- Global default option value settings for MOTIONCORR.
-- This module contains all of the default option values for MOTIONCORR. Every
-- effort has been made to include every option.
--
-- @module MOTIONCORR
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local config = require('tomoauto.config')
local setmetatable = setmetatable

_ENV = nil

local MOTIONCORR = {}

MOTIONCORR = {
  Index = 'MOTIONCORR',
  Name = 'TOMOAUTO{basename}_MOTIONCORR.com',
  Log = 'TOMOAUTO{basename}_MOTIONCORR.log',
  Command = '#!/bin/bash\ndosefgpu_driftcorr \\',

  'InputStack',
  InputStack = {
    use = true,
    value = 'TOMOAUTO{path} \\'
  },

  'CropOffsetX',
  CropOffsetX = {
    use = false,
    value = '-crx 0 \\'
  },

  'CropOffsetY',
  CropOffsetY = {
    use = false,
    value = '-cry 0 \\'
  },

  'CropDimensionX',
  CropDimensionX = {
    use = false,
    value = '-cdx 0 \\'
  },

  'CropDimensionY',
  CropDimensionY = {
    use = false,
    value = '-cdy 0 \\'
  },

  'Binning',
  Binning = {
    use = false,
    value = '-bin 1 \\'
  },

  'AlignmentFirstFrame',
  AlignmentFirstFrame = {
    use = false,
    value = '-nst 0 \\'
  },

  'AlignmentLastFrame',
  AlignmentLastFrame = {
    use = false,
    value = '-ned 0 \\'
  },

  'SumFirstFrame',
  SumFirstFrame = {
    use = false,
    value = '-nss 0 \\'
  },

  'SumLastFrame',
  SumLastFrame = {
    use = false,
    value = '-nes 0 \\'
  },

  'GPUDeviceID',
  GPUDeviceID = {
    use = false,
    value = '-gpu 0 \\'
  },

  'BFactor',
  BFactor = {
    use = true,
    value = '-bft 300 \\'
  },

  'PeakBox',
  PeakBox = {
    use = false,
    value = '-pbx 96 \\'
  },

  'FrameOffset',
  FrameOffset = {
    use = true,
    value = '-fod 1 \\'
  },

  'NoisePeakRadius',
  NoisePeakRadius = {
    use = false,
    value = '-nps 0 \\'
  },

  'ErrorThreshold',
  ErrorThreshold = {
    use = false,
    value = '-kit 1.0 \\'
  },

  'GainReferenceFile',
  GainReferenceFile = {
    use = false,
    value = '-fgr FileName.mrc \\'
  },

  'DarkReferenceFile',
  DarkReferenceFile = {
    use = false,
    value = '-fdr FileName.mrc \\'
  },

  'SaveUncorrectedSum',
  SaveUncorrectedSum = {
    use = false,
    value = '-srs 0 \\'
  },

  'SaveUncorrectedStack',
  SaveUncorrectedStack = {
    use = false,
    value = '-ssr 0 \\'
  },

  'SaveCorrectedStack',
  SaveCorrectedStack = {
    use = false,
    value = '-ssc 0 \\'
  },

  'SaveCorrelationMap',
  SaveCorrelationMap = {
    use = false,
    value = '-scc 0 \\'
  },

  'SaveLog',
  SaveLog = {
    use = false,
    value = '-slg 1 \\'
  },

  'AlignToMiddleFrame',
  AlignToMiddleFrame = {
    use = false,
    value = '-atm 1 \\'
  },

  'SaveQuickResults',
  SaveQuickResults = {
    use = true,
    value = '-dsp 0 \\'
  },

  'UncorrectedSumOutput',
  UncorrectedSumOutput = {
    use = false,
    value = '-frs FileName.mrc \\'
  },

  'UncorrectedStackOutput',
  UncorrectedStackOutput = {
    use = false,
    value = '-frt FileName.mrc \\'
  },

  'CorrectedSumOutput',
  CorrectedSumOutput = {
    use = true,
    value = '-fcs TOMOAUTO{basename}_driftcorr.mrc \\'
  },

  'CorrectedStackOutput',
  CorrectedStackOutput = {
    use = false,
    value = '-fct FileName.mrc \\'
  },

  'CorrelationMapOutput',
  CorrelationMapOutput = {
    use = false,
    value = '-fcm FileName.mrc \\'
  },

  'LogFileOutput',
  LogFileOutput = {
    use = true,
    value = '-flg TOMOAUTO{basename}_driftcorr.log \\'
  },
}
setmetatable(MOTIONCORR, { __index = config.shell })

return MOTIONCORR
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
