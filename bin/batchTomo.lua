#!/usr/bin/env lua
--[[===========================================================================#
# This is a program to run tomoAuto in batch to align and reconstruct a large  #
# number of raw image stacks.                                                  #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: March 24th 2014                                                     #
# Contact: dustin.morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: arg[1] = fiducial size in nm <integer>                            #
#===========================================================================--]]

local lfs = assert(require 'lfs')
local tomoAuto = assert(require 'tomoAuto')
local tomoOpt = assert(require 'tomoOpt')

shortOptsString = 'cd_hn_p_'
longOptsString = 'CTF, defocus, help, max, parallel'
arg, Opts = tomoOpt.get(arg, shortOptsString, longOptsString)

local fileTable = {}
local i = 1

for file in lfs.dir('.') do

   if file:find('%w+%.st$') then
      fileTable[i] = file
      i = i + 1
   end

end

local total = i - 1
local procs = Opts.n_ or 1

local thread = coroutine.create(function ()
   for i = 1, total do
      runString = 'tomoAuto.lua '

      if Opts.c then
         runString = runString .. '-c'
      end

      if Opts.d_ then
         runString = runString .. ' -d ' .. Opts.d_
      end

      if Opts.p_ then
         runString = runString .. ' -p ' .. Opts.p_
      end

      runString = runString .. ' ' .. fileTable .. ' ' .. arg[1]
      
      success, exit, signal = os.execute(runString)
      
      if (i % n == 0) then
         coroutine.yield()
      end
   end
end)

while coroutine.resume(thread) do print('Running on block ' .. i) end
