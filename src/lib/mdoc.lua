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

--- MRC IMOD autodoc parsing library
-- This module provides all of the routines responsible for the reading, and
-- writing autodoc files specifying extra MRC file metadata for tilt-series.
-- @module mdoc
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local mdoc = {}
package.loaded[...] = mdoc

local mrcio = require('tomoauto.mrcio')
local utils = require('tomoauto.utils')
local ipairs, pairs, type = ipairs, pairs, type
local io, string, table = io, string, table

_ENV = nil

function mdoc.has_mdoc (path)
  return utils.is_file(path) and path or nil
end

local function get_global_data (MRC)
  local mdoc_file = assert(io.open(MRC.mdoc, 'r'))
  local global_data = {}

  for line in mdoc_file:lines() do
    if line:match('%[.*=.*%]') then
      break
    else
      local key, value = line:match('(%w+) = (.+)')
      if key and value then global_data[key] = value end
    end
  end

  return mdoc_file:close() and global_data
end

function mdoc.get_global_data (MRC)
  return get_global_data(MRC)
end

function mdoc.get_field_from_global_data (MRC, field)
  assert(utils.is_string(field))
  return get_global_data(MRC)[field]
end

local function print_global_data (global_data)
  local output = ''

  for key, value in pairs(global_data) do
    output = output .. key .. ' = ' .. value .. '\n'
  end

  return output
end

local function get_label_data (MRC)
  local mdoc_file = assert(io.open(MRC.mdoc, 'r'))
  local label_data = {}

  for line in mdoc_file:lines() do
    if line:match('%[ZValue = %d+%]') then
      break
    else
      local label = line:match('%[T = (.+)%]')
      if label then table.insert(label_data, label) end
    end
  end

  return mdoc_file:close() and label_data
end

function mdoc.get_label_data (MRC)
  return get_label_data(MRC)
end

function mdoc.get_from_label_data (MRC, label)
  assert(utils.is_number(label))
  return get_label_data(MRC)[label]
end

local function print_label_data (label_data)
  local output = ''

  for _, label in ipairs(label_data) do
    output = output .. '[T = ' .. label .. ']\n\n'
  end

  return output
end

local function get_section_data (MRC)
  local mdoc_file = assert(io.open(MRC.mdoc, 'r'))
  local section_data, section = {}, false

  for line in mdoc_file:lines() do
    if line:match('%[ZValue = %d+%]') then
      section = section and section + 1 or 1
      section_data[section] = {}
    elseif section then
      local key, value = line:match('(%w+) = (.+)')
      if key and value then section_data[section][key] = value end
    end
  end

  return mdoc_file:close() and section_data
end

function mdoc.get_section_from_section_data (MRC, section)
  assert(utils.is_number(section))
  return get_section_data(MRC)[section]
end

function mdoc.get_field_from_section_data (MRC, field)
  assert(utils.is_string(field))
  local field_data = {}

  for _, section in ipairs(get_section_data(MRC)) do
    table.insert(field_data, section[field])
  end

  return field_data
end

function mdoc.get_section_data (MRC)
  return get_section_data(MRC)
end

local function print_section_data (section_data)
  local output = ''

  for index, section in ipairs(section_data) do
    output = output .. '[ZValue = ' .. index - 1 .. ']\n'

    for key, value in pairs(section) do
      output = output .. key .. ' = ' .. value .. '\n'
    end

    output = output .. '\n'
  end

  return output
end

function mdoc.write_mdoc (path, global_data, label_data, section_data)
  local mdoc_file = assert(io.open(path, 'w'))

  if global_data then
    mdoc_file:write(print_global_data(global_data))
  end

  if label_data then
    mdoc_file:write(print_label_data(label_data))
  end

  if section_data then
    mdoc_file:write(print_section_data(section_data))
  end

  mdoc_file:close()
end

return mdoc
