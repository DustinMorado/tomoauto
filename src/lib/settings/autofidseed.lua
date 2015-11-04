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
local autofidseed = {}
package.loaded[...] = autofidseed

local config = require('tomoauto.config')

autofidseed = {
  Index = 'autofidseed',
  Name = 'TOMOAUTO{basename}_autofidseed.com',
  Log = 'TOMOAUTO{basename}_autofidseed.log',
  Command = '$autofidseed -StandardInput',

  'TrackCommandFile',
  TrackCommandFile = {
    use = true,
    value = 'TOMOAUTO{basename}_beadtrack.com'
  },

  'AppendToSeedModel',
  AppendToSeedModel = {
    use = false,
    value = nil
  },

  'MinGuessNumBeads',
  MinGuessNumBeads = {
    use = false,
    value = nil
  },

  'MinSpacing',
  MinSpacing = {
    use = true,
    value = 0.85
  },

  'BeadSize',
  BeadSize = {
    use = false,
    value = nil
  },

  'AdjustSizes',
  AdjustSizes = {
    use = false,
    value = nil
  },

  'PeakStorageFraction',
  PeakStorageFraction = {
    use = true,
    value = 1.0
  },

  'FindBeadOptions',
  FindBeadOptions = {
    use = false,
    value = nil
  },

  'NumberOfSeedViews',
  NumberOfSeedViews = {
    use = false,
    value = nil
  },

  'BoundaryModel',
  BoundaryModel = {
    use = false,
    value = nil
  },

  'ExcludeInsideAreas',
  ExcludeInsideAreas = {
    use = false,
    value = nil
  },

  'BordersInXandY',
  BordersInXandY = {
    use = false,
    value = nil
  },

  'TwoSurfaces',
  TwoSurfaces = {
    use = false,
    value = nil
  },

  'TargetNumberOfBeads',
  TargetNumberOfBeads = {
    use = true,
    value = 20
  },

  'TargetDensityOfBeads',
  TargetDensityOfBeads = {
    use = false,
    value = nil
  },

  'MaxMajorToMinorRatio',
  MaxMajorToMinorRatio = {
    use = false,
    value = nil
  },

  'ElongatedPointsAllowed',
  ElongatedPointsAllowed = {
    use = false,
    value = nil
  },

  'ClusteredPointsAllowed',
  ClusteredPointsAllowed = {
    use = false,
    value = nil
  },

  'LowerTargetForClustered',
  LowerTargetForClustered = {
    use = false,
    value = nil
  },

  'SubareaSize',
  SubareaSize = {
    use = false,
    value = nil
  },

  'SortAreasMinNumAndSize',
  SortAreasMinNumAndSize = {
    use = false,
    value = nil
  },

  'IgnoreSurfaceData',
  IgnoreSurfaceData = {
    use = false,
    value = nil
  },

  'DropTracks',
  DropTracks = {
    use = false,
    value = nil
  },

  'PickSeedOptions',
  PickSeedOptions = {
    use = false,
    value = nil
  },

  'RemoveTempFiles',
  RemoveTempFiles = {
    use = false,
    value = nil
  },

  'OutputSeedModel',
  OutputSeedModel = {
    use = false,
    value = nil
  },

  'InfoFile',
  InfoFile = {
    use = false,
    value = nil
  },

  'TemporaryDirectory',
  TemporaryDirectory = {
    use = false,
    value = nil
  },

  'LeaveTempFiles',
  LeaveTempFiles = {
    use = false,
    value = nil
  },
}
setmetatable(autofidseed, { __index = config.IMOD })

return autofidseed
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
