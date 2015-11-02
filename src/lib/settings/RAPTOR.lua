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
local RAPTOR = {}
package.loaded[...] = RAPTOR  

local config = require('tomoauto.config')

RAPTOR = {
  Index = 'RAPTOR',
  Name = 'TOMOAUTO{basename}_RAPTOR.com',
  Log = 'TOMOAUTO{basename}_RAPTOR.log',
  Command = '$RAPTOR -StandardInput',

  'RaptorExecPath',
  RaptorExecPath = {
    use = true,
    value = '/usr/local/IMOD/bin/realbin/'
  },

  'InputPath',
  InputPath = {
    use = true,
    value = 'TOMOAUTO{dirname}'
  },

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.preali'
  },

  'OutputPath',
  OutputPath = {
    use = true,
    value = 'TOMOAUTO{currentdir}/TOMOAUTO{basename}_RAPTOR'
  },

  'Diameter',
  Diameter = {
    use = true,
    value = 'TOMOAUTO{fiducial_diameter_px}'
  },

  'WhiteMarkers',
  WhiteMarkers = {
    use = false,
    value = nil
  },

  'MarkersPerImage',
  MarkersPerImage = {
    use = false,
    value = nil
  },

  'AnglesInHeader',
  AnglesInHeader = {
    use = true,
    value = nil
  },

  'Binning',
  Binning = {
    use = false,
    value = nil
  },

  'Reconstruction',
  Reconstruction = {
    use = false,
    value = nil
  },

  'Thickness',
  Thickness = {
    use = false,
    value = nil
  },

  'Orient',
  Orient = {
    use = false,
    value = nil
  },

  'TrackingOnly',
  TrackingOnly = {
    use = false,
    value = nil
  },

  'xRay',
  xRay = {
    use = false,
    value = nil
  },

  'Verbose',
  Verbose = {
    use = false,
    value = nil
  },

  'MaxDistanceCandidate',
  MaxDistanceCandidate = {
    use = false,
    value = nil
  },

  'MinNeighborsMRF',
  MinNeighborsMRF = {
    use = false,
    value = nil
  },

  'RollOffMRF',
  RollOffMRF = {
    use = false,
    value = nil
  },
}
setmetatable(RAPTOR, { __index = config.IMOD })

return RAPTOR
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
