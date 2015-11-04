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

--- MRC Input Output control library.
-- This module provides all of the routines responsible for the reading,
-- modifying (particularly in regards to the header information) and writing MRC
-- files.
-- @module mrcio
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local mrcio = {}
package.loaded[...] = mdoc

local utils = require('tomoauto.utils')
local mdoc = require('tomoauto.mdoc')
local lfs = require('lfs')
local assert, ipairs, setmetatable, type = assert, ipairs, setmetatable, type
local print = print
local io, math, os, string, table = io, math, os, string, table

_ENV = nil

local header_format = 'iiiiiiiiiiffffffiiifffiihc6c4ic16hhc20iihhhhhhfffffffff'
header_format = header_format .. 'c4c4fic80c80c80c80c80c80c80c80c80c80'

local header_fields = {
  'nx', 'ny', 'nz',
  'mode',
  'nxstart', 'nystart', 'nzstart',
  'mx', 'my', 'mz',
  'xlen', 'ylen', 'zlen',
  'alpha', 'beta', 'gamma',
  'mapc', 'mapr', 'maps',
  'amin', 'amax', 'amean',
  'ispg',
  'Next',
  'dvid',
  'extra_1',
  'extType',
  'nversion',
  'extra_2',
  'nint', 'nreal',
  'extra_3',
  'imodStamp', 'imodFlags',
  'idtype', 'lens',
  'nd1', 'nd2', 'vd1', 'vd2',
  'tiltAngles_1', 'tiltAngles_2', 'tiltAngles_3',
  'tiltAngles_4', 'tiltAngles_5', 'tiltAngles_6',
  'xorg', 'yorg', 'zorg',
  'cmap', 'stamp', 'rms', 'nlabl',
  'labels_1', 'labels_2', 'labels_3', 'labels_4', 'labels_5',
  'labels_6', 'labels_7', 'labels_8', 'labels_9', 'labels_10'
}

local function read_header (MRC)
  local MRC_file = assert(io.open(MRC.path, 'rb'))
  local data = MRC_file:read(1024)
  return MRC_file:close() and data
end

local function check_header_dim (header)
  local max = 65536
  if header.nx < 0 or header.ny < 0 or header.nz < 0 then
    return false
  elseif header.nx >= max and header.ny >= max and header.nz >= max then
    return false
  else
    return true
  end
end

local function check_header_map (header)
  if header.mapc < 1 or header.mapc > 3 then
    return false
  elseif header.mapr < 1 or header.mapr > 3 then
    return false
  elseif header.maps < 1 or header.maps > 3 then
    return false
  else
    return true
  end
end

local function check_header (header)
  return check_header_dim(header) and check_header_map(header) and header
end

local function get_header (MRC)
  local header = {}
  local data = read_header(MRC)
  local raw_header = table.pack(header_format:unpack(data))

  for i, field in ipairs(header_fields) do header[field] = raw_header[i] end
  return assert(check_header(header))
end

local function get_pixel_data_size (MRC)
  local sizes = {1, 2, 4, 4, 8, 1, 2}
  return sizes[MRC.header.mode + 1] or false
end

local function get_data_offset (MRC)
  local nx, ny, nz = MRC.header.nx, MRC.header.ny, MRC.header.nz
  return MRC.size - (nx * ny * nz * MRC.pixel_data_size)
end

local function btest (x, y) return x & y ~= 0 end

local function is_IMOD (MRC)
  local sum = 0

  for i, size in ipairs({2, 6, 4, 2, 2, 4}) do
    local flag = math.floor(2^(i - 1))
    sum = btest(MRC.header.nreal, flag) and sum + size or sum
  end

  return sum == MRC.header.nint
end

local function has_extended_header (MRC)
  return MRC.header.Next > 0 and true or nil
end

local IMOD_extended_header_fields = {
  'a_tilt',
  'montage_x', 'montage_y', 'montage_z',
  'x_stage', 'y_stage',
  'magnification',
  'intensity',
  'exp_dose_1', 'exp_dose_2'
}

local function update_IMOD_extended_header_fields (fields, flag)
  if flag == 1 then
    table.insert(fields, IMOD_extended_header_fields[1])
  elseif flag == 2 then
    table.insert(fields, IMOD_extended_header_fields[2])
    table.insert(fields, IMOD_extended_header_fields[3])
    table.insert(fields, IMOD_extended_header_fields[4])
  elseif flag == 4 then
    table.insert(fields, IMOD_extended_header_fields[5])
    table.insert(fields, IMOD_extended_header_fields[6])
  elseif flag == 8 then
    table.insert(fields, IMOD_extended_header_fields[7])
  elseif flag == 16 then
    table.insert(fields, IMOD_extended_header_fields[8])
  elseif flag == 32 then
    table.insert(fields, IMOD_extended_header_fields[9])
    table.insert(fields, IMOD_extended_header_fields[10])
  else
    return fields
  end

  return fields
end

local function get_IMOD_extended_header_fields (MRC)
  local fields = {}

  for i = 0, 5 do
    local flag = math.floor(2^i)
    if btest(MRC.header.nreal, flag) then
      fields = update_IMOD_extended_header_fields(fields, flag)
    end
  end

  return fields
end

local FEI_extended_header_fields = {
  'a_tilt', 'b_tilt',
  'x_stage', 'y_stage', 'z_stage',
  'x_shift', 'y_shift',
  'defocus',
  'exp_time',
  'mean_int',
  'tilt_axis',
  'pixel_size',
  'magnification',
  'ht',
  'binning',
  'appliedDefocus',
  'extra_1', 'extra_2', 'extra_3', 'extra_4', 'extra_5', 'extra_6', 'extra_7',
  'extra_8', 'extra_9', 'extra_10', 'extra_11', 'extra_12', 'extra_13',
  'extra_14', 'extra_15', 'extra_16'
}

local function get_FEI_extended_header_fields (MRC)
  return FEI_extended_header_fields
end

local function get_extended_header_fields (MRC)
  if MRC.has_extended_header and MRC.is_IMOD then
    return get_IMOD_extended_header_fields(MRC)
  elseif MRC.has_extended_header then
    return get_FEI_extended_header_fields(MRC)
  else
    return nil
  end
end

local function get_extended_header_format (MRC)
  if MRC.has_extended_header and MRC.is_IMOD then
    return string.rep('h', MRC.header.nint / 2)
  elseif MRC.has_extended_header then
    return string.rep('f', 32)
  else
    return nil
  end
end

local function get_num_extended_header_sections (MRC)
  if MRC.has_extended_header and MRC.is_IMOD then
    return math.floor(MRC.header.Next / MRC.header.nint)
  elseif MRC.has_extended_header then
    return 1024
  else
    return nil
  end
end

local function read_extended_header (MRC)
  local MRC_file = assert(io.open(MRC.path, 'rb'))
  MRC_file:seek('set', 1024)
  local data = MRC_file:read(MRC.header.Next)
  return MRC_file:close() and data
end

local function get_extended_header_section_offset (MRC, index)
  if MRC.is_IMOD then
    return ((index - 1) * MRC.header.nint) + 1
  else
    return ((index - 1) * 128) + 1
  end
end

local function get_extended_header_section (MRC, data, index)
  local section_data = {}
  local offset = get_extended_header_section_offset(MRC, index)
  local raw_section = table.pack(
    MRC.extended_header_format:unpack(data, offset)
  )

  for i, field in ipairs(MRC.extended_header_fields) do
    section_data[field] = raw_section[i] 
  end

  return section_data
end

local function get_extended_header (MRC)
  if MRC.has_extended_header then
    local data = read_extended_header(MRC)
    local extended_header = {}

    for index = 1, MRC.num_extended_header_sections do
      extended_header[index] = get_extended_header_section(MRC, data, index)
    end

    return extended_header
  else
    return nil
  end
end

local function get_field_from_extended_header (MRC, field)
  local field_data = {}

  for _, section in ipairs(MRC.extended_header) do
    table.insert(field_data, section[field])
  end

  return field_data
end

local function get_section_from_extended_header (MRC, section)
  return MRC.extended_header[section]
end

local function has_extended_header_field (MRC, field)
  return MRC.extended_header[1][field] and true or false
end

local function MRC_get_extended_header (MRC, section, field)
  assert(MRC.has_extended_header)
  if field then assert(has_extended_header_field(MRC, field)) end

  if section and field then
    return MRC.extended_header[section][field]
  elseif section then
    return MRC.extended_header[section]
  elseif field then
    return get_field_from_extended_header(MRC, field)
  else
    return MRC.extended_header
  end
end

local function get_IMOD_tilt_angles (MRC)
  local tilt_angles = get_field_from_extended_header(MRC, 'a_tilt')

  for index, angle in ipairs(tilt_angles) do
    tilt_angles[index] = angle / 100
  end

  return tilt_angles
end

local function get_FEI_tilt_angles (MRC)
  return get_field_from_extended_header(MRC, 'a_tilt')
end

local function get_MDOC_tilt_angles (MRC)
  return mdoc.get_field_from_section_data(MRC, 'TiltAngle')
end

local function get_tilt_angles (MRC)
  if MRC.extended_header and has_extended_header_field(MRC, 'a_tilt') then
    if MRC.is_IMOD then
      return get_IMOD_tilt_angles(MRC)
    else
      return get_FEI_tilt_angles(MRC)
    end
  elseif MRC.mdoc then
    return get_MDOC_tilt_angles(MRC)
  else
    return nil
  end
end

local function MRC_get_tilt_angles (MRC)
  if MRC.tilt_angles then
    return MRC.tilt_angles
  else
    return get_tilt_angles (MRC)
  end
end

local function get_IMOD_pixel_size (MRC)
  return MRC.header.mx == 0 and 1.0 or MRC.header.xlen / MRC.header.mx
end

local function get_FEI_pixel_size (MRC)
  local pixel_size = MRC.extended_header[1]['pixel_size']
  return pixel_size < 1E-4 and pixel_size * 1E9 or pixel_size
end

local function get_MDOC_pixel_size (MRC)
  return mdoc.get_field_from_global_data(MRC, 'PixelSpacing')
end

local function get_pixel_size (MRC)
  if MRC.extended_header and has_extended_header_field(MRC, 'pixel_size') then
    return get_FEI_pixel_size(MRC)
  elseif MRC.mdoc then
    return get_MDOC_pixel_size(MRC)
  else
    return get_IMOD_pixel_size(MRC)
  end
end

local function MRC_get_pixel_size (MRC)
  if MRC.pixel_size then
    return MRC.pixel_size
  else
    return get_pixel_size (MRC)
  end
end

local function get_fiducial_diameter_px (MRC)
  local pixel_size_nm = MRC.pixel_size / 10
  local result = MRC.fiducial_diameter_nm / pixel_size_nm
  return math.floor(result + 0.5)
end

local function get_IMOD_tilt_axis_angle (MRC)
  return MRC.header.labels_2:match('Tilt axis angle = (%-?%d+%.?%d+)') or 0.0
end

local function get_FEI_tilt_axis_angle (MRC)
  local file_type = MRC.header.labels_1:sub(1, 3)
  local tilt_axis_angle = MRC.extended_header[1]['tilt_axis']
  return file_type == 'Fei' and tilt_axis_angle * -1 or tilt_axis_angle
end

local function get_MDOC_tilt_axis_angle (MRC)
  return mdoc.get_section_data(MRC)[1]['RotationAngle']
end

local function get_tilt_axis_angle (MRC)
  if MRC.extended_header and has_extended_header_field(MRC, 'tilt_axis') then
    return get_FEI_tilt_axis_angle(MRC)
  elseif MRC.mdoc then
    return get_MDOC_tilt_axis_angle(MRC)
  else
    return get_IMOD_tilt_axis_angle(MRC)
  end
end

local function MRC_get_tilt_axis_angle (MRC)
  if MRC.tilt_axis_angle then
    return MRC.tilt_axis_angle
  else
    return get_tilt_axis_angle(MRC)
  end
end

local function get_label_table (MRC)
  local label_table = {}

  for i = 1, 10 do
    local field = 'labels_' .. i
    label_table[i] = string.format('%-80s', MRC.header[field]):sub(1, 80)
  end

  return label_table
end

local function set_labels_from_label_table (MRC, label_table)
  for i = 1, 10 do
    local field = 'labels_' .. i
    MRC.header[field] = string.format('%-80s', label_table[i]):sub(1, 80)
  end
end

local function MRC_add_label (MRC, label, position)
  assert(type(label) == 'string')
  if position then
    assert(type(position) == 'number' and postion >= 1 and position <= 10)
  end

  local label = string.format('%-80s', label):sub(1, 80)
  local label_table = get_label_table(MRC)
  local position = position or MRC.header.nlabl + 1
  position = position > 10 and 3 or position
  table.insert(label_table, position, label)
  set_labels_from_label_table(MRC, label_table)
  MRC.header.nlabl = MRC.header.nlabl == 10 and 10 or MRC.header.nlabl + 1
end

local function MRC_delete_label (MRC, position)
  assert(type(label) == 'string')
  if position then
    assert(type(position) == 'number' and position >= 1 and position <= 10)
  end

  local position = position or MRC.header.nlabl
  local label_table = get_label_table(MRC)
  table.remove(label_table, position)
  set_labels_from_label_table(MRC, label_table)
  MRC.header.nlabl = MRC.header.nlabl - 1
end

local function MRC_update (MRC)
  MRC.pixel_data_size = get_pixel_data_size(MRC)
  MRC.data_offset = get_data_offset(MRC)
  MRC.has_extended_header = has_extended_header(MRC)
  MRC.is_IMOD = is_IMOD(MRC)
  MRC.extended_header_fields = get_extended_header_fields(MRC)
  MRC.extended_header_format = get_extended_header_format(MRC)
  MRC.num_extended_header_sections = get_num_extended_header_sections(MRC)
end

local function MRC_add_FEI_extended_header (MRC)
  MRC.header.nint, MRC.header.nreal = 0, 32
  MRC.header.Next = 131072
  MRC_update(MRC)
  MRC.extended_header = {}
  for i = 1, 1024 do
    MRC.extended_header[i] = {}

    for _, field in ipairs(FEI_extended_header_fields) do
      MRC.extended_header[i][field] = 0.0
    end
  end
end

local function is_valid_IMOD_extended_header_field (field)
  for _, valid_field in ipairs(IMOD_extended_header_fields) do
    if field == valid_field then return true end
  end

  return nil
end

local function is_valid_FEI_extended_header_field (field)
  for _, valid_field in ipairs(FEI_extended_header_fields) do
    if field == valid_field then return true end
  end

  return nil
end

local function MRC_add_FEI_extended_header_field (MRC, field, field_data)
  assert(utils.is_string(field))
  assert(is_valid_FEI_extended_header_field(field))

  if (not MRC.extended_header) or MRC.is_IMOD then
    MRC:add_FEI_extended_header()
  end

  for i = 1, 1024 do
    MRC.extended_header[i][field] = field_data[i] or 0.0
  end
end

local function max_table_length (table_1, table_2)
  if #table_1 >= #table_2 then
    return #table_1
  else
    return #table_2
  end
end

local function update_IMOD_extended_header_a_tilt (MRC, tilt_angles)
  for i, section in ipairs(MRC.extended_header) do
    local new_angle = tilt_angles[i]
    local old_angle = MRC.extended_header[i]['a_tilt']
    MRC.extended_header[i]['a_tilt'] = new_angle or old_angle
  end

  return MRC.extended_header
end

local function update_IMOD_header_a_tilt (MRC, tilt_angles)
  MRC.header.nint = MRC.header.nint + 2
  MRC.header.nreal = MRC.header.nreal + 1
  if MRC.header.Next == 0 then
    MRC.header.Next = 2 * #tilt_angles
  else
    MRC.header.Next = MRC.header.Next + 2 * #MRC.extended_header
  end

  return MRC.header
end

local function add_IMOD_extended_header_a_tilt (MRC, tilt_angles)
  if MRC.extended_header and MRC.extended_header[1]['a_tilt'] then
    return update_IMOD_extended_header_a_tilt (MRC, tilt_angles)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_a_tilt(MRC, tilt_angles)
    MRC_update(MRC)
    local n = max_table_length(tilt_angles, MRC.extended_header)

    for i = 1, n do
      MRC.extended_header[i] = MRC.extended_header[i] or {}
      local tilt_angle = tilt_angles[i] or 0
      MRC.extended_header[i]['a_tilt'] = math.floor(tilt_angle * 100)
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_a_tilt (MRC)
  MRC.header.nint = MRC.header.nint - 2
  MRC.header.nreal = MRC.header.nreal - 1
  MRC.header.Next = MRC.header.Next - (2 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['a_tilt'] = nil
  end

  return MRC.extended_header
end

local function update_IMOD_extended_header_montage (MRC, montage_x, montage_y,
						    montage_z)
  for i, section in ipairs(MRC.extended_header) do
    local new_mx, new_my, new_mz = montage_x[i], montage_y[i], montage_z[i]
    local old_mx = MRC.extended_header[i]['montage_x']
    local old_my = MRC.extended_header[i]['montage_y']
    local old_mz = MRC.extended_header[i]['montage_y']
    MRC.extended_header[i]['montage_x'] = new_mx or old_mx
    MRC.extended_header[i]['montage_y'] = new_my or old_my
    MRC.extended_header[i]['montage_z'] = new_mz or old_mz
  end

  return MRC.extended_header
end

local function update_IMOD_header_montage (MRC, montage_x)
  MRC.header.nint = MRC.header.nint + 6
  MRC.header.nreal = MRC.header.nreal + 2
  if MRC.header.Next == 0 then
    MRC.header.Next = 6 * #montage_x
  else
    MRC.header.Next = MRC.header.Next + (6 * #MRC.extended_header)
  end

  return MRC.header
end

local function add_IMOD_extended_header_montage (MRC, montage_x, montage_y,
						 montage_z)
  if MRC.extended_header and MRC.extended_header[1]['montage_x'] then
    return update_IMOD_extended_header_montage (MRC, montage_x, montage_y,
						montage_z)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_montage(MRC, montage_x)
    MRC_update(MRC)
    local n = max_table_length(montage_x, MRC.extended_header)

    for i = 1, n do
      local mx = montage_x[i] or 0
      local my = montage_y[i] or 0
      local mz = montage_z[i] or 0
      MRC.extended_header[i]['montage_x'] = mx
      MRC.extended_header[i]['montage_y'] = my
      MRC.extended_header[i]['montage_z'] = mz
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_montage (MRC)
  MRC.header.nint = MRC.header.nint - 6
  MRC.header.nreal = MRC.header.nreal - 2
  MRC.header.Next = MRC.header.Next - (6 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['montage_x'] = nil
    MRC.extended_header[i]['montage_y'] = nil
    MRC.extended_header[i]['montage_z'] = nil
  end

  return MRC.extended_header
end

local function update_IMOD_extended_header_stage (MRC, x_stage, y_stage)
  for i, section in ipairs(MRC.extended_header) do
    local new_x_stage, new_y_stage = x_stage[i], y_stage[i]
    local old_x_stage = MRC.extended_header[i]['x_stage']
    local old_y_stage = MRC.extended_header[i]['y_stage']
    MRC.extended_header[i]['x_stage'] = new_x_stage or old_x_stage
    MRC.extended_header[i]['y_stage'] = new_y_stage or old_y_stage
  end

  return MRC.extended_header
end

local function update_IMOD_header_stage (MRC, x_stage)
  MRC.header.nint = MRC.header.nint + 4
  MRC.header.nreal = MRC.header.nreal + 4
  if MRC.header.Next == 0 then
    MRC.header.Next = 4 * #montage_x
  else
    MRC.header.Next = MRC.header.Next + (4 * #MRC.extended_header)
  end

  return MRC.header
end

local function add_IMOD_extended_header_stage (MRC, x_stage, y_stage)
  if MRC.extended_header and MRC.extended_header[1]['x_stage'] then
    return update_IMOD_extended_header_stage (MRC, x_stage, y_stage)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_stage(MRC, x_stage)
    MRC_update(MRC)
    local n = max_table_length(x_stage, MRC.extended_header)

    for i = 1, n do
      local xs = x_stage[i] or 0
      local ys = y_stage[i] or 0
      MRC.extended_header[i]['x_stage'] = math.floor(xs * 25)
      MRC.extended_header[i]['y_stage'] = math.floor(ys * 25)
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_stage (MRC)
  MRC.header.nint = MRC.header.nint - 4
  MRC.header.nreal = MRC.header.nreal - 4
  MRC.header.Next = MRC.header.Next - (4 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['x_stage'] = nil
    MRC.extended_header[i]['y_stage'] = nil
  end

  return MRC.extended_header
end

local function update_IMOD_extended_header_magnification (MRC, magnification)
  for i, section in ipairs(MRC.extended_header) do
    local new_mag = magnification[i]
    local old_mag = MRC.extended_header[i]['magnification']
    MRC.extended_header[i]['magnification'] = new_mag or old_mag
  end

  return MRC.extended_header
end

local function update_IMOD_header_magnification (MRC, magnification)
  MRC.header.nint = MRC.header.nint + 2
  MRC.header.nreal = MRC.header.nreal + 8
  if MRC.header.Next == 0 then
    MRC.header.Next = 2 * #magnification
  else
    MRC.header.Next = MRC.header.Next + 2 * #MRC.extended_header
  end

  return MRC.header
end

local function add_IMOD_extended_header_magnification (MRC, magnification)
  if MRC.extended_header and MRC.extended_header[1]['magnification'] then
    return update_IMOD_extended_header_magnification (MRC, magnification)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_magnification(MRC, magnification)
    MRC_update(MRC)
    local n = max_table_length(magnification, MRC.extended_header)

    for i = 1, n do
      local mag = magnification[i] or 0
      MRC.extended_header[i]['magnification'] = math.floor(mag / 100)
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_magnification (MRC)
  MRC.header.nint = MRC.header.nint - 2
  MRC.header.nreal = MRC.header.nreal - 8
  MRC.header.Next = MRC.header.Next - (2 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['magnification'] = nil
  end

  return MRC.extended_header
end

local function update_IMOD_extended_header_intensity (MRC, intensity)
  for i, section in ipairs(MRC.extended_header) do
    local new_intensity = intensity[i]
    local old_intensity = MRC.extended_header[i]['intensity']
    MRC.extended_header[i]['intensity'] = new_intensity or old_intensity
  end

  return MRC.extended_header
end

local function update_IMOD_header_intensity (MRC, intensity)
  MRC.header.nint = MRC.header.nint + 2
  MRC.header.nreal = MRC.header.nreal + 16
  if MRC.header.Next == 0 then
    MRC.header.Next = 2 * #intensity
  else
    MRC.header.Next = MRC.header.Next + (2 * #MRC.extended_header)
  end

  return MRC.header
end

local function add_IMOD_extended_header_intensity (MRC, intensity)
  if MRC.extended_header and MRC.extended_header[1]['intensity'] then
    return update_IMOD_extended_header_intensity (MRC, intensity)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_intensity(MRC, intensity)
    MRC_update(MRC)
    local n = max_table_length(intensity, MRC.extended_header)

    for i = 1, n do
      local _intensity = intensity[i] or 0
      MRC.extended_header[i]['intensity'] = math.floor(_intensity * 25000)
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_intensity (MRC)
  MRC.header.nint = MRC.header.nint - 2
  MRC.header.nreal = MRC.header.nreal - 16
  MRC.header.Next = MRC.header.Next - (2 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['intensity'] = nil
  end

  return MRC.extended_header
end

local function update_IMOD_extended_header_exp_dose (MRC, exp_dose_1,
						     exp_dose_2)
  for i, section in ipairs(MRC.extended_header) do
    local new_exp_dose_1, new_exp_dose_2 = exp_dose_1[i], exp_dose_2[i]
    local old_exp_dose_1 = MRC.extended_header[i]['exp_dose_1']
    local old_exp_dose_2 = MRC.extended_header[i]['exp_dose_2']
    MRC.extended_header[i]['exp_dose_1'] = new_exp_dose_1 or old_exp_dose_1
    MRC.extended_header[i]['exp_dose_2'] = new_exp_dose_2 or old_exp_dose_2
  end

  return MRC.extended_header
end

local function update_IMOD_header_exp_dose (MRC, exp_dose_1)
  MRC.header.nint = MRC.header.nint + 4
  MRC.header.nreal = MRC.header.nreal + 32
  if MRC.header.Next == 0 then
    MRC.header.Next = 4 * #exp_dose_1
  else
    MRC.header.Next = MRC.header.Next + (4 * #MRC.extended_header)
  end

  return MRC.header
end

local function add_IMOD_extended_header_exp_dose (MRC, exp_dose_1, exp_dose_2)
  if MRC.extended_header and MRC.extended_header[1]['exp_dose_1'] then
    return update_IMOD_extended_header_montage (MRC, exp_dose_1, exp_dose_2)
  else
    MRC.extended_header = MRC.extended_header or {}
    MRC.header = update_IMOD_header_montage(MRC, exp_dose_1)
    MRC_update(MRC)
    local n = max_table_length(exp_dose_1, MRC.extended_header)

    for i = 1, n do
      local dose_1 = exp_dose_1[i] or 0
      local dose_2 = exp_dose_2[i] or 0
      MRC.extended_header[i]['exp_dose_1'] = dose_1
      MRC.extended_header[i]['exp_dose_2'] = dose_2
    end
  end

  return MRC.extended_header
end

local function remove_IMOD_extended_header_exp_dose (MRC)
  MRC.header.nint = MRC.header.nint - 4
  MRC.header.nreal = MRC.header.nreal - 32
  MRC.header.Next = MRC.header.Next - (4 * #MRC.extended_header)

  for i = 1, #MRC.extended_header do
    MRC.extended_header[i]['exp_dose_1'] = nil
    MRC.extended_header[i]['exp_dose_2'] = nil
  end

  return MRC.extended_header
end

local function MRC_add_IMOD_extended_header_field (MRC, field, ...)
  assert(utils.is_string(field))
  if field == 'a_tilt' then
    local tilt_angles = ...
    MRC.extended_header = add_IMOD_extended_header_a_tilt(MRC, tilt_angles)
  elseif field == 'montage' then
    local montage_x, montage_y, montage_z = ...
    MRC.extended_header = add_IMOD_extended_header_montage(MRC, montage_x,
							   montage_y, montage_z)
  elseif field == 'stage' then
    local x_stage, y_stage = ...
    MRC.extended_header = add_IMOD_extended_header_stage(MRC, x_stage, y_stage)
  elseif field == 'magnification' then
    local magnification = ...
    MRC.extended_header = add_IMOD_extended_header_magnification(MRC,
								 magnification)
  elseif field == 'intensity' then
    local intensity = ...
    MRC.extended_header = add_IMOD_extended_header_intensity(MRC, intensity)
  elseif field == 'exp_dose' then
    local exp_dose_1, exp_dose_2 = ...
    MRC.extended_header = add_IMOD_extended_header_exp_dose(MRC, exp_dose_1,
							    exp_dose_2)
  else
    return nil
  end

  return true
end

local function MRC_remove_IMOD_extended_header_field (MRC, field)
  assert(utils.is_string(field))
  if field == 'a_tilt' then
    MRC.extended_header = remove_IMOD_extended_header_a_tilt(MRC)
  elseif field == 'montage' then
    MRC.extended_header = remove_IMOD_extended_header_montage(MRC)
  elseif field == 'stage' then
    MRC.extended_header = remove_IMOD_extended_header_stage(MRC)
  elseif field == 'magnification' then
    MRC.extended_header = remove_IMOD_extended_header_magnification(MRC)
  elseif field == 'intensity' then
    MRC.extended_header = remove_IMOD_extended_header_intensity(MRC)
  elseif field == 'exp_dose' then
    MRC.extended_header = remove_IMOD_extended_header_exp_dose(MRC)
  else
    return nil
  end

  return true
end

local function write_header (MRC)
  local raw_header = {}
  for _, field in ipairs(header_fields) do
    table.insert(raw_header, MRC.header[field])
  end

  return assert(header_format:pack(table.unpack(raw_header)))
end

local function write_extended_header_section (MRC, index)
  local raw_section = {}

  for _, field in ipairs(MRC.extended_header_fields) do
    table.insert(raw_section, MRC.extended_header[index][field])
  end

  return assert(MRC.extended_header_format:pack(table.unpack(raw_section)))
end

local function has_excess_extended_header (MRC)
  if MRC.is_IMOD then
    return MRC.header.Next % MRC.header.nint ~= 0 and true or nil
  else
    return nil
  end
end

local function write_excess_extended_header (MRC)
  local excess_data = ''
  local excess_shorts = (MRC.header.Next % MRC.header.nint) / 2

  for i = 1, excess_shorts do
    excess_data = excess_data .. string.pack('h', 0)
  end

  return excess_data
end

local function write_extended_header (MRC)
  local extended_header = ''

  print('DEBUG: ', MRC.num_extended_header_sections)
  for index = 1, MRC.num_extended_header_sections do
    extended_header = extended_header ..
		      write_extended_header_section(MRC, index)
  end

  if has_excess_extended_header(MRC) then
    extended_header = extended_header .. write_excess_extended_header(MRC)
  end

  return extended_header
end

local function MRC_write (MRC, path)
  assert(utils.is_string(path))
  assert(utils.backup(path))
  local new_MRC = assert(io.open(path, 'wb'))
  new_MRC:write(write_header(MRC))

  if MRC.extended_header then new_MRC:write(write_extended_header(MRC)) end

  local old_MRC = assert(io.open(MRC.path, 'rb'))
  old_MRC:seek('set', MRC.data_offset)
  local section_size = MRC.header.nx * MRC.header.ny * MRC.pixel_data_size

  for i = 1, MRC.header.nz do new_MRC:write(old_MRC:read(section_size)) end

  return old_MRC:close() and new_MRC:close() and true
end

function mrcio.new_MRC (path, fiducial_diameter_nm, mdoc_path)
  local path = utils.absolute_path(path)
  local fiducial_diameter_nm = fiducial_diameter_nm or 0.0
  local mdoc_path = mdoc_path or path .. '.mdoc'
  local currentdir = lfs.currentdir()
  local dirname = utils.dirname(path)
  local filename = utils.basename(path)
  local suffix = utils.get_suffix(path)
  local basename = utils.basename(path, suffix)
  local basepath = utils.join_paths(dirname, basename)
  local log = utils.is_file(basepath .. '.log') and basepath .. '.log' or nil
  local size = lfs.attributes(path, 'size')

  mdoc_path = utils.absolute_path(mdoc_path)
  local MRC = {
    path = path,
    currentdir = currentdir,
    dirname = dirname,
    filename = filename,
    basename = basename,
    basepath = basepath,
    log = log,
    size = size,
    fiducial_diameter_nm = fiducial_diameter_nm,
    mdoc = mdoc.has_mdoc(mdoc_path),
  }

  MRC.header = get_header(MRC)
  MRC.pixel_data_size = get_pixel_data_size(MRC)
  MRC.data_offset = get_data_offset(MRC)
  MRC.has_extended_header = has_extended_header(MRC)
  MRC.is_IMOD = is_IMOD(MRC)
  MRC.extended_header_fields = get_extended_header_fields(MRC)
  MRC.extended_header_format = get_extended_header_format(MRC)
  MRC.num_extended_header_sections = get_num_extended_header_sections(MRC)
  MRC.extended_header = get_extended_header(MRC)
  MRC.tilt_angles = get_tilt_angles(MRC)
  MRC.pixel_size = get_pixel_size(MRC)
  MRC.pixel_size_A = MRC.pixel_size
  MRC.pixel_size_nm = MRC.pixel_size / 10
  MRC.fiducial_diameter_px = get_fiducial_diameter_px(MRC)
  MRC.tilt_axis_angle = get_tilt_axis_angle(MRC)

  MRC.get_extended_header = MRC_get_extended_header
  MRC.get_tilt_angles = MRC_get_tilt_angles
  MRC.get_pixel_size = MRC_get_pixel_size
  MRC.get_tilt_axis_angle = MRC_get_tilt_axis_angle
  MRC.add_label = MRC_add_label
  MRC.delete_label = MRC_delete_label
  MRC.update = MRC_update
  MRC.add_FEI_extended_header = MRC_add_FEI_extended_header
  MRC.add_FEI_extended_header_field = MRC_add_FEI_extended_header_field
  MRC.add_IMOD_extended_header_field = MRC_add_IMOD_extended_header_field
  MRC.remove_IMOD_extended_header_field = MRC_remove_IMOD_extended_header_field
  MRC.write = MRC_write

  return MRC
end

return mrcio
-- vim: set ft=lua tw=80 ts=8 sts=2 sw=2 noet :
