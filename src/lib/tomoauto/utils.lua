--[[
Copyright (c) 2015 Dustin Reed Morado

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--- General utilities module for tomoauto.
-- This is a small collection of useful utilities for tomoauto
-- @module utils
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local utils = {}
local lfs = require('lfs')
local io, math, os, string = io, math, os, string

--------------------------------------------------------------------------------
--                               PATH UTILITIES                               --
--------------------------------------------------------------------------------

local pathsep = string.sub(_G.package.config, 1, 1)

--- Determines whether argument is a valid existing path.
-- @tparam string path The path to check.
-- @treturn string Returns the path if it exists and nil otherwise.
function utils.is_path (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.is_path: Path must be a valid string.\n', 2)
  end

  return lfs.attributes(path, 'mode') and path
end

--- Determines whether or not the argument is in the form of an absolute path.
-- This a simple (read dumb) check which simply checks that the first character
-- of a string is the path separtor which usually signifies an absolute path.
-- @tparam string path The path to check.
-- @treturn boolean Returns true if path starts with the path separator false
-- otherwise.
function utils.is_absolute_path (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.is_absolute_path: Path must be a valid ' ..
      'string.\n', 2)
  end

  return string.sub(path, 1, 1) == pathsep
end

--- Determines whether or not the argument is the path of a directory.
-- @tparam string path The path to check.
-- @tparam boolean Returns true if path is a directory and false otherwise.
function utils.is_dir (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.is_dir: Path must be a valid string.\n', 2)
  end

  return lfs.attributes(path, 'mode') == 'directory'
end

--- Determines whether or not the argument is the path of file.
-- @tparam string path The path to check.
-- @treturn boolean Returns true if path is a file and false otherwise.
function utils.is_file (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.is_file: Path must be a valid string.\n', 2)
  end

  return lfs.attributes(path, 'mode') == 'file'
end

--- Takes two paths and joins them with the correct path separator.
-- @tparam string path_1 The path to join on the left hand side.
-- @tparam string path_2 The path to join on the right hand side.
-- @treturn string Returns the joined path.
function utils.join_paths (path_1, path_2)
  if type(path_1) ~= 'string' or type(path_2) ~= 'string' then
    error('ERROR: tomoauto.utils.join_paths: Paths must be valid strings.\n', 2)
  end

  if path_1 == '' then
    return path_2
  elseif path_2 == '' then
    return path_1
  else
    return path_1 .. pathsep .. path_2
  end
end

--- Determines the normalized absolute path of the argument.
-- @tparam string path The path to convert to normalized absolute path.
-- @treturn string Returns the normalized absolute path.
function utils.absolute_path (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.absolute_path: Path must be a valid string.\n',
      2)
  end

  local absolute_path
  if utils.is_absolute_path(path) then
    absolute_path = path
  else
    absolute_path = utils.join_paths(lfs.currentdir(), path)
  end

  repeat
    local old_absolute_path = absolute_path
    absolute_path = string.gsub(absolute_path, pathsep .. '%.' .. pathsep ..
      '?', pathsep)

    absolute_path = string.gsub(absolute_path, pathsep .. pathsep .. '+',
      pathsep)

    absolute_path = string.gsub(absolute_path, pathsep .. '$', '')
    absolute_path = string.gsub(absolute_path, '[^' .. pathsep .. ']+' ..
      pathsep .. '%.%.' ..  pathsep .. '?', '')

  until old_absolute_path == absolute_path

  absolute_path = absolute_path == '' and pathsep or absolute_path
  return absolute_path
end

--- Splits argument into directory and file components.
-- This takes an argument and returns the absolute path of the directory and the
-- file part as two separate strings, if the argument is not an absolute path
-- the path is taken to be in relation to the current directory.
-- @tparam string path The path to split.
-- @treturn string The absolute path directory component of the argument.
-- @treturn string The file component of the argument.
function utils.split_path (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.split_path: Path must be a valid string.\n', 2)
  end

  local absolute_path = utils.absolute_path(path)
  local dirname, basename
  if utils.is_dir(absolute_path) then
    dirname = absolute_path
    basename = ''

  else
    dirname = string.gsub(absolute_path, pathsep .. '[^' .. pathsep .. ']+$',
      '')

    basename = string.match(absolute_path, pathsep .. '([^' .. pathsep ..
      ']+)$')

  end

  return dirname, basename
end

--- Determines the absolute directory component of the argument.
-- This returns the first component of utils.split_path(path)
-- @tparam string path The path to determine the directory component.
-- @treturn string Returns the absolute path directory component.
function utils.dirname (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.dirname: Path must be a valid string.\n', 2)
  end

  local dirname = utils.split_path(path)
  return dirname
end

--- Determines the final suffix of the argument.
-- This function just returns the last suffix of a given string including the
-- leading period.
-- @tparam string path The path of which to determin the suffix.
-- @treturn string The last suffix of the argument including the leading dot.
function utils.get_suffix (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.get_suffix: Path must be a valid string.\n', 2)
  end

  return string.match(path, '%.[%w]+$')
end

--- Determines the file component of a path and optionally remove a suffix.
-- This function just returns the second component of utils.split_path(path) and
-- if suffix is given removes the suffix from the file component. If the path
-- given is a directory the function returns an empty string.
-- @tparam string path The path to determine the file component.
-- @tparam string suffix An optional suffix to strip from the file component.
-- @treturn string Returns the file component of the given path with the suffix
-- optionally stripped from the returned string.
function utils.basename (path, suffix)
  if type(path) ~= 'string' or suffix and type(suffix) ~= 'string' then
    error('ERROR: tomoauto.utils.basename: Path and suffix if present must ' ..
      'be a valid string.\n', 2)
  end

  local _, basename = utils.split_path(path)

  if suffix then
    suffix = string.gsub(suffix, '%.', '%%.')
    return string.gsub(basename, suffix, '')
  end

  return basename
end

--- Determines the relative path of the argument
-- This function returns the relative path of the argument with respect to the
-- current directory.
-- @tparam string path The path to determine the relative path
-- @treturn string Returns the relative path of the argument with respect to the
-- current directory.
function utils.relative_path (path)
  if type(path) ~= 'string' then
    error('ERROR: tomoauto.utils.relative_path: Path must be a valid string.\n',
      2)
  end

  local source = lfs.currentdir()
  local target = utils.absolute_path(path)
  local relative_path = ''

  while source ~= '' do
    local source_word, target_word
    source_word = string.match(source, pathsep .. '[^' .. pathsep .. ']+')
    target_word = string.match(target, pathsep .. '[^' .. pathsep .. ']+')
    if source_word == target_word then
      source = string.gsub(source, source_word, '', 1)
      target = string.gsub(target, target_word, '', 1)

    else
      source = string.gsub(source, source_word, '', 1)
      relative_path = utils.join_paths(relative_path, '..')
    end
  end

  target = string.gsub(target, '^' .. pathsep, '')
  relative_path = utils.join_paths(relative_path, target)
  return relative_path
end

--------------------------------------------------------------------------------
--                                 OS UTILITIES                               --
--------------------------------------------------------------------------------

--- Runs an OS command and exits Lua if the command fails.
-- This function runs a command in os.execute and if the command fails or
-- returns a non-zero signal aborts the Lua process with signal 1.
-- @tparam string command The command to run with os.execute.
-- @treturn boolean Returns a status code on whether the command was successful.
-- @treturn boolean Returns the status code on whether the command completed.
-- @treturn string Returns the string 'exit' on command completion.
-- @treturn numbers Returns the signal that the command exited with (0).
function utils.run (command)
  local pcall_status, execute_status, exit, signal = pcall(function ()
    local status, exit, signal = os.execute(command)
    if not status or signal ~= 0 then
      error('ERROR: utils.run: Command failed to execute successfully.\n', 4)
    else
      return status, exit, signal
    end
  end)

  if not pcall_status then
    local err_msg = execute_status
    io.stderr:write(err_msg)
    os.exit(1)
  else
    return execute_status, exit, signal
  end
end

--- Backs up a file if it exists.
-- Backs up a file replacing previous backup if it exists.
-- @tparam string filename file to backup
-- @tparam string suffix suffix to add to backup Default is '.bak'
function utils.backup (path, suffix)
  if type(path) ~= 'string' or suffix and type(suffix) ~= 'string' then
    error('ERROR: tomoauto.utils.backup: Path and suffix if present must ' ..
      'be a valid string.\n', 2)
  end

  local absolute_path = utils.absolute_path(path)
  if utils.is_file(absolute_path) then
    local backup
    if suffix then
      backup = absolute_path .. suffix
    else
      backup = absolute_path .. '.bak'
    end

    status, err = os.rename(absolute_path, backup)
    if not status then
      error(err)
    end
  end
end

--------------------------------------------------------------------------------
--                              OTHER UTILITIES                               --
--------------------------------------------------------------------------------

--- Reads Bio3d style floats in the extended header.
-- This function is included in the MRC header documentation for IMOD. I have
-- not seen it used anywhere but it could be used in the future and it was
-- easily implemented.
-- @tparam number short_1 first short read in
-- @tparam number short_2 second short read in
-- @treturn number Returns the float encoded by the two shorts.
function utils.IMOD_short_to_float (short_1, short_2)
  local sign_1 = short_1 < 0 and -1 or 1
  local sign_2 = short_2 < 0 and -1 or 1
  short_1 = math.abs(short_1)
  short_2 = math.abs(short_2)
  local float = sign_1 * ((256 * short_1) + (short_2 % 256)) *
                2 ^ (sign_2 * (short_2 / 256))
  return float
end

return utils
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
