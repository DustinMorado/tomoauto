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

return {
  tomoauto       = require('tomoauto.settings.tomoauto'),
  MOTIONCORR     = require('tomoauto.settings.MOTIONCORR'),
  ccderaser      = require('tomoauto.settings.ccderaser'),
  tiltxcorr      = require('tomoauto.settings.tiltxcorr'),
  xftoxg         = require('tomoauto.settings.xftoxg'),
  prenewstack    = require('tomoauto.settings.prenewstack'),
  autofidseed    = require('tomoauto.settings.autofidseed'),
  RAPTOR         = require('tomoauto.settings.RAPTOR'),
  beadtrack      = require('tomoauto.settings.beadtrack'),
  tiltalign      = require('tomoauto.settings.tiltalign'),
  xfproduct      = require('tomoauto.settings.xfproduct'),
  newstack       = require('tomoauto.settings.newstack'),
  ctfplotter     = require('tomoauto.settings.ctfplotter'),
  CTFFIND4       = require('tomoauto.settings.CTFFIND4'),
  ctfphaseflip   = require('tomoauto.settings.ctfphaseflip'),
  xfmodel        = require('tomoauto.settings.xfmodel'),
  gold_ccderaser = require('tomoauto.settings.gold_ccderaser'),
  tilt           = require('tomoauto.settings.tilt'),
  tomo3d         = require('tomoauto.settings.tomo3d'),
  xfalign        = require('tomoauto.settings.xfalign'),
  xyzproj        = require('tomoauto.settings.xyzproj')
}

-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
