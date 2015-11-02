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
local xyzproj = {}
package.loaded[...] = xyzproj 

local config = require('tomoauto.config')

xyzproj = {
  Index = 'xyzproj',
  Name = 'TOMOAUTO{basename}_xyzproj.com',
  Log = 'TOMOAUTO{basename}_xyzproj.log',
  Command = '$xyzproj -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.ali'
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}_driftcorr.mrc'
  },

  'AxisToTiltAround',
  AxisToTiltAround = {
    use = true,
    value = 'Y'
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

  'ZMinAndMax',
  ZMinAndMax = {
    use = false,
    value = nil
  },

  'StartEndIncAngle',
  StartEndIncAngle = {
    use = false,
    value = nil
  },

  'ModeToOutput',
  ModeToOutput = {
    use = false,
    value = nil
  },

  'WidthToOutput',
  WidthToOutput = {
    use = false,
    value = nil
  },

  'AddThenMultiply',
  AddThenMultiply = {
    use = false,
    value = nil
  },

  'FillValue',
  FillValue = {
    use = false,
    value = nil
  },

  'ConstantScaling',
  ConstantScaling = {
    use = false,
    value = nil
  },

  'TiltFile',
  TiltFile = {
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

  'TiltAngles',
  TiltAngles = {
    use = false,
    value = nil
  },

  'FullAreaAtTilt',
  FullAreaAtTilt = {
    use = false,
    value = nil
  },
}
setmetatable(xyzproj, { __index = config.IMOD })

return xyzproj
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
