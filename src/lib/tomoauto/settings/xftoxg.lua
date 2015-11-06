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

local xftoxg = {}

xftoxg = {
  Index = 'xftoxg',
  Name = 'TOMOAUTO{basename}_xftoxg.com',
  Log = 'TOMOAUTO{basename}_xftoxg.log',
  Command = '$xftoxg -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.prexf'
  },

  'GOutputFile',
  GOutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.prexg'
  },

  'NumberToFit',
  NumberToFit = {
    use = true,
    value = 0
  },

  'ReferenceSection',
  ReferenceSection = {
    use = false,
    value = nil
  },

  'OrderOfPolynomialFit',
  OrderOfPolynomialFit = {
    use = false,
    value = nil
  },

  'HybridFits',
  HybridFits = {
    use = false,
    value = nil
  },

  'RangeOfAnglesInAverage',
  RangeOfAnglesInAverage = {
    use = false,
    value = nil
  },

  'RobustFit',
  RobustFit = {
    use = false,
    value = nil
  },

  'KFactorScaling',
  KFactorScaling = {
    use = false,
    value = nil
  },

  'MaximumIterations',
  MaximumIterations = {
    use = false,
    value = nil
  },

  'IterationParams',
  IterationParams = {
    use = false,
    value = nil
  },
}
setmetatable(xftoxg, { __index = config.IMOD })

return xftoxg
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
