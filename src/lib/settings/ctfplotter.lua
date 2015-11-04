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
local ctfplotter = {}
package.loaded[...] = ctfplotter 

local config = require('tomoauto.config')

ctfplotter = {
  Index = 'ctfplotter',
  Name = 'TOMOAUTO{basename}_ctfplotter.com',
  Log = 'TOMOAUTO{basename}_ctfplotter.log',
  Command = '$ctfplotter -StandardInput',

  'InputStack',
  InputStack = {
    use = true,
    value = 'TOMOAUTO{basename}.st'
  },

  'AngleFile',
  AngleFile = {
    use = true,
    value = 'TOMOAUTO{basename}.tlt'
  },

  'InvertTiltAngles',
  InvertTiltAngles = {
    use = false,
    value = nil
  },

  'OffsetToAdd',
  OffsetToAdd = {
    use = false,
    value = nil
  },

  'ConfigFile',
  ConfigFile = {
    use = true,
    value = '/usr/local/ImodCalib/CTFnoise/K24Kbackground/' ..
            'polara-K2-4K-2014.ctg'
  },

  'DefocusFile',
  DefocusFile = {
    use = true,
    value = 'TOMOAUTO{basename}.defocus'
  },

  'AxisAngle',
  AxisAngle = {
    use = true,
    value = 'TOMOAUTO{tilt_axis_angle}'
  },

  'PSResolution',
  PSResolution = {
    use = false,
    value = nil
  },

  'TileSize',
  TileSize = {
    use = false,
    value = nil
  },

  'Voltage',
  Voltage = {
    use = true,
    value = 300
  },

  'MaxCacheSize',
  MaxCacheSize = {
    use = false,
    value = nil
  },

  'SphericalAberration',
  SphericalAberration = {
    use = true,
    value = 2.0
  },

  'DefocusTol',
  DefocusTol = {
    use = false,
    value = nil
  },

  'PixelSize',
  PixelSize = {
    use = true,
    value = 'TOMOAUTO{pixel_size_nm}'
  },

  'AmplitudeContrast',
  AmplitudeContrast = {
    use = true,
    value = 0.10
  },

  'ExpectedDefocus',
  ExpectedDefocus = {
    use = true,
    value = '5'
  },

  'LeftDefTol',
  LeftDefTol = {
    use = false,
    value = nil
  },

  'RightDefTol',
  RightDefTol = {
    use = false,
    value = nil
  },

  'AngleRange',
  AngleRange = {
    use = true,
    value = { -40.0, 40.0 }
  },

  'AutoFitRangeAndStep',
  AutoFitRangeAndStep = {
    use = true,
    value = { 0.0, 0.0 }
  },

  'FrequencyRangeToFit',
  FrequencyRangeToFit = {
    use = true,
    value = { 0.05, 0.225 }
  },

  'VaryExponentInFit',
  VaryExponentInFit = {
    use = false,
    value = nil
  },

  'BaselineFittingOrder',
  BaselineFittingOrder = {
    use = true,
    value = 2
  },

  'SaveAndExit',
  SaveAndExit = {
    use = true,
    value = nil
  },

  'DebugLevel',
  DebugLevel = {
    use = false,
    value = nil
  },

  'Parameter',
  Parameter = {
    use = false,
    value = nil
  },

  'FocalPairDefocusOffset',
  FocalPairDefocusOffset = {
    use = false,
    value = nil
  },
}
setmetatable(ctfplotter, { __index = config.IMOD })

return ctfplotter
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
