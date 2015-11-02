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
local gold_ccderaser = {}
package.loaded[...] = gold_ccderaser 

local config = require('tomoauto.config')

gold_ccderaser = {
  Index = 'gold_ccderaser',
  Name = 'TOMOAUTO{basename}_gold_ccderaser.com',
  Log = 'TOMOAUTO{basename}_gold_ccderaser.log',
  Command = '$ccderaser -StandardInput',

  'InputFile',
  InputFile = {
    use = true,
    value = 'TOMOAUTO{basename}.ali'
  },

  'OutputFile',
  OutputFile = {
    use = true,
    value = 'TOMOAUTO{basename}_erase.ali'
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
    use = false,
    value = nil
  },

  'PeakCriterion',
  PeakCriterion = {
    use = false,
    value = nil
  },

  'DiffCriterion',
  DiffCriterion = {
    use = false,
    value = nil
  },

  'GrowCriterion',
  GrowCriterion = {
    use = false,
    value = nil
  },

  'ScanCriterion',
  ScanCriterion = {
    use = false,
    value = nil
  },

  'MaximumRadius',
  MaximumRadius = {
    use = false,
    value = nil
  },

  'GiantCriterion',
  GiantCriterion = {
    use = false,
    value = nil
  },

  'ExtraLargeRadius',
  ExtraLargeRadius = {
    use = false,
    value = nil
  },

  'BigDiffCriterion',
  BigDiffCriterion = {
    use = false,
    value = nil
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
    use = false,
    value = nil
  },

  'XYScanSize',
  XYScanSize = {
    use = false,
    value = nil
  },

  'EdgeExclusionWidth',
  EdgeExclusionWidth = {
    use = false,
    value = nil
  },

  'PointModel',
  PointModel = {
    use = false,
    value = nil
  },

  'ModelFile',
  ModelFile = {
    use = true,
    value = 'TOMOAUTO{basename}_erase.fid'
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
    use = true,
    value = '/'
  },

  'BetterRadius',
  BetterRadius = {
    use = true,
    value = 13.25
  },

  'ExpandCircleIterations',
  ExpandCircleIterations = {
    use = false,
    value = nil
  },

  'MergePatches',
  MergePatches = {
    use = true,
    value = nil
  },

  'BorderSize',
  BorderSize = {
    use = false,
    value = nil
  },

  'PolynomialOrder',
  PolynomialOrder = {
    use = true,
    value = 0
  },

  'ExcludeAdjacent',
  ExcludeAdjacent = {
    use = true,
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

  'ParameterFile',
  ParameterFile = {
    use = false,
    value = nil
  },
}
setmetatable(gold_ccderaser, { __index = config.IMOD })

return gold_ccderaser
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
