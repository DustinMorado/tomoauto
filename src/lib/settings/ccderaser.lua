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
local ccderaser = {}
package.loaded[...] = ccderaser 

local config = require('tomoauto.config')

ccderaser = {
  Index = 'ccderaser',
  Name = 'TOMOAUTO{basename}_ccderaser.com',
  Log = 'TOMOAUTO{basename}_ccderaser.log',
  Command = '$ccderaser -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{filename}'
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}_fixed.st'
  },

  'PieceListFile',
  PieceListFile = {
    use = false,
    value = nil
  },

  'OverlapsForModel',
  OverlapsForModel = {
    use = false,
    value = nil
  },

  'FindPeaks',
  FindPeaks = {
    use = true,
    value = nil
  },

  'PeakCriterion',
  PeakCriterion = {
    use = true,
    value = 10.0
  },

  'DiffCriterion',
  DiffCriterion = {
    use = true,
    value = 8.0
  },

  'GrowCriterion',
  GrowCriterion = {
    use = true,
    value = 4.0
  },

  'ScanCriterion',
  ScanCriterion = {
    use = true,
    value = 3.0
  },

  'MaximumRadius',
  MaximumRadius = {
    use = true,
    value = 4.2
  },

  'GiantCriterion',
  GiantCriterion = {
    use = true,
    value = 12.0
  },

  'ExtraLargeRadius',
  ExtraLargeRadius = {
    use = true,
    value = 8.0
  },

  'BigDiffCriterion',
  BigDiffCriterion = {
    use = true,
    value = 19.0
  },

  'MaxPixelsInDiffPatch',
  MaxPixelsInDiffPatch = {
    use = false,
    value = nil
  },

  'OuterRadius',
  OuterRadius = {
    use = false,
    value = nil
  },

  'AnnulusWidth',
  AnnulusWidth = {
    use = true,
    value = 2.0
  },

  'XYScanSize',
  XYScanSize = {
    use = true,
    value = 100
  },

  'EdgeExclusionWidth',
  EdgeExclusionWidth = {
    use = true,
    value = 4
  },

  'PointModel',
  PointModel = {
    use = false,
    value = 'TOMOAUTO{basename}_peak.mod'
  },

  'ModelFile',
  ModelFile = {
    use = false,
    value = nil
  },

  'LineObjects',
  LineObjects = {
    use = false,
    value = nil
  },

  'BoundaryObjects',
  BoundaryObjects = {
    use = false,
    value = nil
  },

  'AllSectionObjects',
  AllSectionObjects = {
    use = false,
    value = nil
  },

  'CircleObjects',
  CircleObjects = {
    use = false,
    value = nil
  },

  'BetterRadius',
  BetterRadius = {
    use = false,
    value = nil
  },

  'ExpandCircleIterations',
  ExpandCircleIterations = {
    use = false,
    value = nil
  },

  'MergePatches',
  MergePatches = {
    use = false,
    value = nil
  },

  'BorderSize',
  BorderSize = {
    use = true,
    value = 2
  },

  'PolynomialOrder',
  PolynomialOrder = {
    use = true,
    value = 2
  },

  'ExcludeAdjacent',
  ExcludeAdjacent = {
    use = false,
    value = nil
  },

  'TrialMode',
  TrialMode = {
    use = false,
    value = nil
  },

  'Verbose',
  Verbose = {
    use = false,
    value = nil
  },

  'ProcessID',
  ProcessID = {
    use = false,
    value = nil
  },
}
setmetatable(ccderaser, { __index = config.IMOD })

return ccderaser
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
