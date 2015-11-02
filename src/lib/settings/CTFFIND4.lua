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

--- Global default option value settings for CTFFIND4.
-- This module contains all of the default option values for CTFFIND4. Every
-- effort has been made to include every option.
--
-- @module CTFFIND4
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30
local CTFFIND4 = {}
package.loaded[...] = CTFFIND4

local config = require('tomoauto.config')

CTFFIND4 = {
  Index   = 'CTFFIND4',
  Name    = 'TOMOAUTO{basename}_CTFFIND4.com',
  Log     = 'TOMOAUTO{basename}_CTFFIND4.log',
  Command = '#!/bin/bash\nctffind << EOF',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.mrc'
  },

  'DiagnosticOutput',
  DiagnosticOutput = {
    use = true,
    value = 'TOMOAUTO{basename}.ctf'
  },

  'PixelSize',
  PixelSize = {
    use = true,
    value = 'TOMOAUTO{pixel_size_A}'
  },

  'AccelerationVoltage',
  AccelerationVoltage = {
    use = true,
    value = 300
  },

  'ShpericalAberration',
  ShpericalAberration = {
    use = true,
    value = 2.0
  },

  'AmplitudeContrast',
  AmplitudeContrast = {
    use = true,
    value = 0.10
  },

  'BoxSize',
  BoxSize = {
    use = true,
    value = 256
  },

  'MinimumResolution',
  MinimumResolution = {
    use = true,
    value = 50.0
  },

  'MaximumResolution',
  MaximumResolution = {
    use = true,
    value = 10.0
  },

  'MinimumDefocus',
  MinimumDefocus = {
    use = true,
    value = 10000.0
  },

  'MaximumDefocus',
  MaximumDefocus = {
    use = true,
    value = 90000.0
  },

  'DefocusSearchStep',
  DefocusSearchStep = {
    use = true,
    value = 5000.0
  },

  'AstigmatismTolerance',
  AstigmatismTolerance = {
    use = true,
    value = 100.0
  },

  'AdditionalPhaseShift',
  AdditionalPhaseShift = {
    use = true,
    value = 'no'
  },

  'MinimumPhaseShift',
  MinimumPhaseShift = {
    use = false,
    value = nil
  },

  'MaximumPhaseShift',
  MaximumPhaseShift = {
    use = false,
    value = nil
  },

  'PhaseShiftSearchStep',
  PhaseShiftSearchStep = {
    use = false,
    value = nil
  },

  'HeredocEnd',
  HeredocEnd = {
    use = true,
    value = 'EOF'
  },
}

setmetatable(CTFFIND4, { __index = config.shell })

return CTFFIND4
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
