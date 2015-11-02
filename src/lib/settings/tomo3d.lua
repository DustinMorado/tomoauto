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
local tomo3d = {}
package.loaded[...] = tomo3d 

local config = require('tomoauto.config')

tomo3d = {
  Index = 'tomo3d',
  Name = 'TOMOAUTO{basename}_tomo3d.com',
  Log = 'TOMOAUTO{basename}_tomo3d.log',
  Command = '#!/bin/bash\ntomo3d \\',

  'TiltFile',
  TiltFile = {
    use = true,
    value = '-a TOMOAUTO{basename}.tlt \\'
  },

  'InputFile',
  InputFile = {
    use = true,
    value = '-i TOMOAUTO{basename}.ali \\'
  },

  'AngleOffset',
  AngleOffset = {
    use = false,
    value = '-A offset \\'
  },

  'IOBuffers',
  IOBuffers = {
    use = false,
    value = '-b n,m \\'
  },

  'CacheBlock',
  CacheBlock = {
    use = false,
    value = '-C n \\'
  },

  'ConstrainOutputVolume',
  ConstrainOutputVolume = {
    use = false,
    value = '-c \\'
  },

  'VectorExtensions',
  VectorExtensions = {
    use = false,
    value = '-e avx/sse/none \\'
  },

  'OverwriteOutputVolume',
  OverwriteOutputVolume = {
    use = false,
    value = '-f \\'
  },

  'HyperThreading',
  HyperThreading = {
    use = false,
    value = '-H \\'
  },

  'Interpolation',
  Interpolation = {
    use = false,
    value = '-I on/off \\'
  },

  'LogReconstruction',
  LogReconstruction = {
    use = false,
    value = '-L \\'
  },

  'Iterations',
  Iterations = {
    use = false,
    value = '-l iter \\'
  },

  'MemoryLimit',
  MemoryLimit = {
    use = false,
    value = '-M memlimit \\'
  },

  'HammingFrequency',
  HammingFrequency = {
    use = true,
    value = '-m 0.35 \\'
  },

  'InvertHandedness',
  InvertHandedness = {
    use = false,
    value = '-n \\'
  },

  'SinogramOffset',
  SinogramOffset = {
    use = false,
    value = '-O densoffset \\'
  },

  'OutputVolume',
  OutputVolume = {
    use = true,
    value = '-o TOMOAUTO{basename}_tomo3d.rec \\'
  },

  'SinogramProjections',
  SinogramProjections = {
    use = false,
    value = '-P n \\'
  },

  'ProcessRows',
  ProcessRows = {
    use = false,
    value = 'R n \\'
  },

  'ResumeSIRTVolume',
  ResumeSIRTVolume = {
    use = false,
    value = '-r tomogram \\'
  },

  'SIRT',
  SIRT = {
    use = false,
    value = '-S \\'
  },

  'SplitFactor',
  SplitFactor = {
    use = false,
    value = '-s splitf \\'
  },

  'Threading',
  Threading = {
    use = false,
    value = '-t threads \\'
  },

  'Verbosity',
  Verbosity = {
    use = false,
    value = '-v level \\'
  },

  'Weighting',
  Weighting = {
    use = false,
    value = '-w on/off \\'
  },

  'Width',
  Width = {
    use = false,
    value = '-x width \\'
  },

  'Depth',
  Depth = {
    use = false,
    value = '-y y1,y2 \\'
  },

  'Height',
  Height = {
    use = true,
    value = '-z 1200 \\'
  },

  'LogFile',
  LogFile = {
    use = true,
    value = '2>&1 | tee TOMOAUTO{basename}_tomo3d.log'
  }
}
setmetatable(tomo3d, { __index = config.shell })

return tomo3d
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
