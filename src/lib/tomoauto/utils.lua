--- General Utilities for tomoauto.
-- This is a small collection of useful utilities for tomoauto
-- @module utils

local Utils = {}
local io, math, os, string = io, math, os, string
local lfs = require('lfs')

function Utils.run (command)
  local pcall_status, execute_status, exit, signal = pcall(function ()
    local status, exit, signal = os.execute(command)
    if not status or signal ~= 0 then
      error('ERROR: Utils.run: Command failed to execute successfully.\n', 4)
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

--- Extracts the basname from a file path.
-- Removes the preceding file path as well as removes the final suffix
-- @tparam string filename file path
-- @treturn string file basename with path and final suffix removed
function Utils.basename (filename, suffix)
  -- Defines path seperator for the OS, '/' for *nix and '\' for Windows
  local pathsep = string.sub(package.config, 1, 1)
  local regex = '[^' .. pathsep .. ']*' .. pathsep
  local basename = string.gsub(filename, regex, '')

  if suffix then
    suffix = string.gsub(suffix, '%.', '%%.')
    basename = string.gsub(basename, suffix, '')
  end

  return basename
end

function Utils.join_paths (path_1, path_2)
  local pathsep = string.sub(package.config, 1, 1)
  return path_1 .. pathsep .. path_2
end

function Utils.is_abspath (filename)
  local pathsep = string.sub(package.config, 1, 1)
  return string.sub(filename, 1, 1) == pathsep
end

--- Extracts the directory name from a file path.
-- Removes the filename from the full path.
-- @tparam string filename file path
-- @treturn string full path to filename given.
function Utils.dirname (filename)
  local abspath = Utils.join_paths(lfs.currentdir(), filename)
  local pathsep = string.sub(package.config, 1, 1)
  local regex = pathsep .. '[^' .. pathsep .. ']*$'
  local dirname = string.gsub(abspath, regex, '')
  return dirname
end

function Utils.get_suffix (filename)
  return string.match(filename, '%.[%w]+$')
end

--- Checks to see if file exists.
-- @tparam string filename file to check
-- @treturn bool true if file exists false otherwise
Utils.is_file = function (filename)
  local file = io.open(filename, 'r')
  if file then
    file:close()
    return true
  else
    return false
  end
end

--- Backs up a file if it exists.
-- Backs up a file replacing previous backup if it exists.
-- @tparam string filename file to backup
-- @tparam string suffix suffix to add to backup Default is '.bak'
function Utils.backup (filename, suffix)
  if Utils.is_file(filename) then
    local backup_filename = suffix and filename .. suffix or filename .. '.bak'
    os.execute('mv ' .. filename .. ' ' .. backup_filename)
  end
end

--- Reads Bio3d style floats in the extended header.
-- This function is included in the MRC header documentation for IMOD. I have
-- not seen it used anywhere but it could be used in the future and it was
-- easily implemented.
-- @param _1 first short read in
-- @param _2 second short read in
-- @return real A float
function Utils.IMOD_short_to_float (short_1, short_2)
  local sign_1 = short_1 < 0 and -1 or 1
  local sign_2 = short_2 < 0 and -1 or 1
  short_1 = math.abs(short_1)
  short_2 = math.abs(short_2)
  local float = sign_1 * ((256 * short_1) + (short_2 % 256)) *
                2 ^ (sign_2 * (short_2 / 256))
  return float
end

return Utils
