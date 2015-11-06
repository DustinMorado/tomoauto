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

local ctfphaseflip = {}

ctfphaseflip = {
  Index = 'ctfphaseflip',
  Name = 'TOMOAUTO{basename}_ctfphaseflip.com',
  Log = 'TOMOAUTO{basename}_ctfphaseflip.log',
  Command = '$ctfphaseflip -StandardInput',

  'InputStack',
  InputStack = {
    use = true,
    value = 'TOMOAUTO{basename}.ali'
  },

  'OutputFileName',
  OutputFileName = {
    use = true,
    value = 'TOMOAUTO{basename}_ctfcorr.ali'
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

  'DefocusFile',
  DefocusFile = {
    use = true,
    value = 'TOMOAUTO{basename}.defocus'
  },

  'TransformFile',
  TransformFile = {
    use = true,
    value = 'TOMOAUTO{basename}.xf'
  },

  'DefocusTol',
  DefocusTol = {
    use = true,
    value = 200
  },

  'MaximumStripWidth',
  MaximumStripWidth = {
    use = false,
    value = nil
  },

  'InterpolationWidth',
  InterpolationWidth = {
    use = true,
    value = 20
  },

  'PixelSize',
  PixelSize = {
    use = true,
    value = 'TOMOAUTO{pixel_size_nm}'
  },

  'Voltage',
  Voltage = {
    use = true,
    value = 300
  },

  'SphericalAberration',
  SphericalAberration = {
    use = true,
    value = 2.0
  },

  'AmplitudeContrast',
  AmplitudeContrast = {
    use = true,
    value = 0.10
  },

  'StartingEndingViews',
  StartingEndingViews = {
    use = false,
    value = nil
  },

  'TotalViews',
  TotalViews = {
    use = false,
    value = nil
  },

  'BoundaryInfoFile',
  BoundaryInfoFile = {
    use = false,
    value = nil
  },

  'AxisAngle',
  AxisAngle = {
    use = false,
    value = nil
  },
}
setmetatable(ctfphaseflip, { __index = config.IMOD })

return ctfphaseflip
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
