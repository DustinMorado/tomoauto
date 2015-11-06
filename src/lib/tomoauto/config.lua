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

--- Configuration processing module for tomoauto.
-- This module contains all of the functions used for managing the settings
-- modules that define the default options for commands used in tomoauto.
-- @module config
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local utils = require('tomoauto.utils')
local io, os, string, table = io, os, string, table
local assert, getmetatable, ipairs = assert, getmetatable, ipairs
local loadfile, pairs, setmetatable, type = loadfile, pairs, setmetatable, type

_ENV = nil

local config = {}

function config.copy (setting)
  local new_setting = {
    Name = setting.Name,
    Log  = setting.Log,
    Index = setting.Index,
    Command = setting.Command
  }

  for index, key in ipairs(setting) do
    new_setting[index] = key
    new_setting[key] = { use = setting[key].use, value = setting[key].value }
  end

  setmetatable(new_setting, getmetatable(setting))
  return new_setting
end

local function update_value (value, MRC)
  local field = type(value) == 'string' and value:match('TOMOAUTO{([%w_-]+)}')
  if field then
    local new_value = assert(MRC[field], 'Invalid MRC field')
    return value:gsub('TOMOAUTO{[%w_-]+}', new_value)
  else
    return value
  end
end

function config.setup (setting, MRC)
  local new_setting = config.copy(setting)
  new_setting.Name = update_value(new_setting.Name, MRC)
  new_setting.Log  = update_value(new_setting.Log,  MRC)

  for index, key in ipairs(new_setting) do
    if new_setting[key].use then
      new_setting[key].value = update_value(new_setting[key].value, MRC)
    end
  end

  return new_setting
end

function config.clear (setting)
  local new_setting = config.copy(setting)

  for _, key in ipairs(new_setting) do
    new_setting[key].use = false
  end

  return new_setting
end

function config.update (setting, update_setting)
  local new_setting = config.copy(setting)

  for key, record in pairs(update_setting) do
    new_setting[key].use   = not not record.use
    new_setting[key].value = record.value
  end

  return new_setting
end

function config.load_local_configuration (path)
  if not path then
    return {}
  else
    local sandbox = {}
    local chunk = assert(loadfile(path, 't', sandbox))
    chunk()
    return sandbox
  end
end

function config.apply_local_configuration (setting, sandbox)
  if utils.is_table(sandbox) then
    for setting_index, update_setting in pairs(sandbox) do
      if setting_index == setting.Index then
	return config.update(setting, update_setting)
      end
    end

    return setting
  else
    return setting
  end
end

function config.get_log (setting)
  if not setting.Log then
    return ''
  end

  local log = io.open(setting.Log, 'r')
  local data = log:read('a') .. '\n'
  return log:close() and data
end

function config.cleanup (setting)
  if utils.is_file(setting.Name) then
    assert(os.remove(setting.Name))
  end

  if setting.Log and utils.is_file(setting.Log) then
    assert(os.remove(setting.Log))
  end
end

config.IMOD = {}
setmetatable(config.IMOD, {__index = config})

config.shell = {}
setmetatable(config.shell, {__index = config})

local function write_line (key, value)
  local line = key and key .. '\t' or ''
  if type(value) == 'table' then
    return line .. table.concat(value, ',') .. '\n'
  elseif value then
    return line .. value .. '\n'
  elseif key then
    return key .. '\n'
  end
end

function config.IMOD.write (setting)
  assert(utils.backup(setting.Name))
  local command = assert(io.open(setting.Name, 'w'))
  command:write(setting.Command .. '\n')

  for _, key in ipairs(setting) do
    local use, value = setting[key].use, setting[key].value

    if use then
      command:write(write_line(key, value))
    end
  end

  return command:close()
end

function config.shell.write (setting)
  assert(utils.backup(setting.Name))
  local command = io.open(setting.Name, 'w')
  command:write(setting.Command .. '\n')

  for _, key in ipairs(setting) do
    local use, value = setting[key].use, setting[key].value

    if use then
      command:write(write_line(nil, value)) 
    end
  end

  return command:close()
end

function config.IMOD.run (setting)
  assert(utils.run('submfg ' .. setting.Name))
end

function config.shell.run (setting)
  assert(utils.run('chmod u+x ' .. setting.Name))
  assert(utils.run('./' .. setting.Name))
end

function config.write_cycle (setting, MRC, sandbox)
  local setting = setting:apply_local_configuration(sandbox)
  setting = setting:setup(MRC)
  setting:write()
  return setting
end

function config.run_cycle (setting, MRC, sandbox)
  local setting = setting:apply_local_configuration(sandbox)
  setting = setting:setup(MRC)
  setting:write()
  setting:run()
  local log_data = setting:get_log()
  setting:cleanup()
  return setting, log_data
end

function config.run_full_cycle (setting, update_setting, MRC, sandbox)
  local setting = setting:clear()
  setting = setting:update(update_setting)
  return setting:run_cycle(MRC, sandbox)
end

return config
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
