--- MRC Input Output control library.
-- This module provides all of the input output access for the MRC file format
-- particularly in regards to the header information.
--
-- @module MRCIO
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.30
local MRCIO = {}
local math, string, table = math, string, table
local Utils = require('tomoauto_utils')
local lfs = require('lfs')

--- Creates a new MRC file object for tomoauto.
-- @tparam string filename MRC filename
-- @tparam number optional fiducial marker diameter in nm
-- @treturn table a MRC object table
function MRCIO:new_mrc (filename, fiducial_diameter_nm)
  if not filename or type(filename) ~= 'string' then
    error('ERROR: MRCIO:new_mrc: Filename must be a non-nil string.')
  end

  fiducial_diameter_nm = fiducial_diameter_nm or 0.0
  local currentdir = lfs.currentdir()
  local suffix = Utils.get_suffix(filename)
  local basename = Utils.basename(filename, suffix)
  local dirname = Utils.dirname(filename)
  local abspath = Utils.join_paths(dirname, basename .. suffix)
  local mdoc_filename = Utils.join_paths(dirname, basename .. '.mdoc')
  local has_mdoc = Utils.is_file(mdoc_filename)

  local mrc = {
    filename               = filename,
    basename               = basename,
    currentdir             = currentdir,
    dirname                = dirname,
    abspath                = abspath,
    mdoc_filename          = mdoc_filename,
    has_mdoc               = has_mdoc,
    header                 = {},
    header_fields          = {{ 'nx',           'i'   },
                              { 'ny',           'i'   },
                              { 'nz',           'i'   },
                              { 'mode',         'i'   },
                              { 'nxstart',      'i'   },
                              { 'nystart',      'i'   },
                              { 'nzstart',      'i'   },
                              { 'mx',           'i'   },
                              { 'my',           'i'   },
                              { 'mz',           'i'   },
                              { 'xlen',         'f'   },
                              { 'ylen',         'f'   },
                              { 'zlen',         'f'   },
                              { 'alpha',        'f'   },
                              { 'beta',         'f'   },
                              { 'gamma',        'f'   },
                              { 'mapc',         'i'   },
                              { 'mapr',         'i'   },
                              { 'maps',         'i'   },
                              { 'amin',         'f'   },
                              { 'amax',         'f'   },
                              { 'amean',        'f'   },
                              { 'ispg',         'i'   },
                              { 'Next',         'i'   },
                              { 'dvid',         'h'   },
                              { 'extra_1',      'c6'  },
                              { 'extType',      'c4'  },
                              { 'nversion',     'i'   },
                              { 'extra_2',      'c16' },
                              { 'nint',         'h'   },
                              { 'nreal',        'h'   },
                              { 'extra_3',      'c20' },
                              { 'imodStamp',    'i'   },
                              { 'imodFlags',    'i'   },
                              { 'idtype',       'h'   },
                              { 'lens',         'h'   },
                              { 'nd1',          'h'   },
                              { 'nd2',          'h'   },
                              { 'vd1',          'h'   },
                              { 'vd2',          'h'   },
                              { 'tiltAngles_1', 'f'   },
                              { 'tiltAngles_2', 'f'   },
                              { 'tiltAngles_3', 'f'   },
                              { 'tiltAngles_4', 'f'   },
                              { 'tiltAngles_5', 'f'   },
                              { 'tiltAngles_6', 'f'   },
                              { 'xorg',         'f'   },
                              { 'yorg',         'f'   },
                              { 'zorg',         'f'   },
                              { 'cmap',         'c4'  },
                              { 'stamp',        'c4'  },
                              { 'rms',          'f'   },
                              { 'nlabl',        'i'   },
                              { 'labels_1',     'c80' },
                              { 'labels_2',     'c80' },
                              { 'labels_3',     'c80' },
                              { 'labels_4',     'c80' },
                              { 'labels_5',     'c80' },
                              { 'labels_6',     'c80' },
                              { 'labels_7',     'c80' },
                              { 'labels_8',     'c80' },
                              { 'labels_9',     'c80' },
                              { 'labels_10',    'c80' }},
    extended_header        = {},
    extended_header_fields = {},
    tilt_angles            = {},
    fiducial_diameter_nm   = fiducial_diameter_nm,
    fiducial_diameter_px   = nil,
    tilt_axis_angle        = nil,
    pixel_size_A           = nil,
    pixel_size_nm          = nil,
    is_IMOD                = nil,
    defocus                = nil,
    is_bidirectional       = nil
  }

  setmetatable(mrc, self)
  self.__index = self
  -- We need to prevent this parser from calling new itself
  function mrc:new_mrc ()
    error('ERROR: MRCIO:new_mrc: new_mrc cannot be called from a mrc object.')
  end

  if Utils.is_file(filename) then
    mrc:set_header()
    mrc:set_is_IMOD()
    mrc:set_extended_header_fields()
    mrc:set_extended_header()
    mrc:set_tilt_angles()
    mrc:set_pixel_size()
    mrc:set_fiducial_diameter_px()
    mrc:set_tilt_axis_angle()
  end

  return mrc
end

--- Gets standard 1024 byte MRC header.
-- This reads the first 1024 bytes of an MRC file and returns a table object
-- with the corresponding data. The complete header information for Agard style
-- headers can be found here: http://www.2dx.unibas.ch/documentation/
-- mrc-software/fei-extended-mrc-format-not-used-by-2dx
--
-- The information for the SerialEM/IMOD style MRC file can be found here:
-- http://bio3d.colorado.edu/imod/doc/mrc_format.txt
-- @param input_filename MRC file to read
-- @return header: A table with header information
function MRCIO:set_header ()
  local mrc = io.open(self.filename, 'rb')
  local header_data = mrc:read(1024)
  mrc:close()

  local offset = 1
  local header = {}
  for _, field in ipairs(self.header_fields) do
    header[field[1]], offset = string.unpack(field[2], header_data, offset)
  end

  self.header = header
end

--- Checks MRC header type.
-- This function reads the nint and nreal sections in the header and checks to
-- see if the file comes from IMOD
-- @param self MRC object
function MRCIO:set_is_IMOD ()
  local sum = 0
  local nreal, nint = self.header.nreal, self.header.nint
  sum = nreal & 1  ~= 0 and sum + 2 or sum
  sum = nreal & 2  ~= 0 and sum + 6 or sum
  sum = nreal & 4  ~= 0 and sum + 4 or sum
  sum = nreal & 8  ~= 0 and sum + 2 or sum
  sum = nreal & 16 ~= 0 and sum + 2 or sum
  sum = nreal & 32 ~= 0 and sum + 4 or sum
  self.is_IMOD = (sum == nint) and true
end

function MRCIO:set_extended_header_fields ()
  local fields = {}
  if self.is_IMOD then
    local nreal = self.header.nreal
    if nreal & 1 ~= 0 then
      table.insert(fields, 'a_tilt')
    end

    if nreal & 2 ~= 0 then
      table.insert(fields, 'montage_x')
      table.insert(fields, 'montage_y')
      table.insert(fields, 'montage_z')
    end

    if nreal & 4 ~= 0 then
      table.insert(fields, 'x_stage')
      table.insert(fields, 'y_stage')
    end

    if nreal & 8 ~= 0 then
      table.insert(fields, 'magnification')
    end

    if nreal & 16 ~= 0 then
      table.insert(fields, 'intensity')
    end

    if nreal & 32 ~= 0 then
      table.insert(fields, 'exp_dose_1')
      table.insert(fields, 'exp_dose_2')
    end
  else
    fields = {
      'a_tilt',
      'b_tilt',
      'x_stage',
      'y_stage',
      'z_stage',
      'x_shift',
      'y_shift',
      'defocus',
      'exp_time',
      'mean_int',
      'tilt_axis',
      'pixel_size',
      'magnification',
      'ht',
      'binning',
      'appliedDefocus'
    }
  end
  self.extended_header_fields = fields
end

--- Reads MRC file extended header.
-- A function that reads the extended header for a given MRC file and returns a
-- table object with the corresponnding data
-- @param input_filename MRC file to be read
-- @return extended_header A table object with MRC file information
function MRCIO:set_extended_header ()
  if self.header.Next == 0 then
    self.extended_header = false
    return
  end

  local mrc = io.open(self.filename, 'rb')
  mrc:seek('set', 1024)
  local header_data = mrc:read(self.header.Next)
  mrc:close()

  local offset = 1
  local extended_header = {}
  for i = 1, self.header.nz do
    local header = {}
    for _, field in ipairs(self.extended_header_fields) do
      if self.is_IMOD then
        header[field], offset = string.unpack('h', header_data, offset)
      else
        header[field], offset = string.unpack('f', header_data, offset)
      end
    end

    if not self.is_IMOD then
      offset = offset + 64
    end

    table.insert(extended_header, header)
  end

  self.extended_header = extended_header
end

--- Gets the tilt angles from the extended header of a tilt series.
-- This function writes the tilt angles out to stdout or a file.
-- @param input_filename MRC file to read
-- @param output_filename [optional] Output file
function MRCIO:set_tilt_angles ()
  if self.extended_header and self.extended_header[1].a_tilt then
    for i = 1, self.header.nz do
      local a_tilt
      if self.is_IMOD then
        a_tilt = self.extended_header[i].a_tilt / 100
      else
        a_tilt = self.extended_header[i].a_tilt
      end

      table.insert(self.tilt_angles, a_tilt)
    end

  elseif self.has_mdoc then
    local mdoc_file = io.open(self.mdoc_filename, 'r')
    for line in mdoc_file:lines('*l') do
      local tilt_angle = string.match(line, 'TiltAngle%s=%s(-?%d+%.%d+)$')
      if tilt_angle then
        table.insert(self.tilt_angles, tilt_angle)
      end
    end

  else
    self.tilt_angles = false
  end
end

function MRCIO:set_pixel_size ()
  local mx, xlen = self.header.mx, self.header.xlen
  local pixel_size_x = xlen / mx

  local my, ylen = self.header.my, self.header.ylen
  local pixel_size_y = ylen / my

  local mz, zlen = self.header.mz, self.header.zlen
  local pixel_size_z = zlen / mz

  local extended_header_pixel_size
  if self.extended_header and #self.extended_header ~= 0 then
    extended_header_pixel_size = self.extended_header[1].pixel_size
  end

  local pixel_size_A
  if math.abs(pixel_size_x - pixel_size_y) > 1E-4 or
     math.abs(pixel_size_x - pixel_size_z) > 1E-4 then
    io.stderr:write('WARNING: MRCIO:set_pixel_size: Non-uniform pixel size.')
    pixel_size_A = pixel_size_x

  elseif extended_header_pixel_size and
         extended_header_pixel_size < 1E-4 then
    pixel_size_A = extended_header_pixel_size * 1E9

  elseif extended_header_pixel_size then
    pixel_size_A = extended_header_pixel_size

  elseif pixel_size_x ~= 1.0 then
    pixel_size_A = pixel_size_x

  elseif self.has_mdoc then
    local mdoc_file = io.open(self.mdoc_filename, 'r')
    for line in mdoc_file:lines('*l') do
      pixel_size_A = string.match(line, 'PixelSpacing%s=%s(%d+%.%d+)$')
      if pixel_size_A then
        break
      end
    end

    if not pixel_size_A then
      io.stderr:write('WARNING: MRCIO:set_pixel_size: Pixel size cannot be ' ..
                      'determined beyond the default 1.0.\n')
      pixel_size_A = pixel_size_x
    end

  else
    io.stderr:write('WARNING: MRCIO:set_pixel_size: Pixel size cannot be ' ..
                    'determined beyond the default 1.0.\n')
    pixel_size_A = pixel_size_x
  end

  self.pixel_size_A = pixel_size_A
  self.pixel_size_nm = pixel_size_A / 10
end

function MRCIO:set_fiducial_diameter_px ()
  local fiducial_diameter_px = self.fiducial_diameter_nm / self.pixel_size_nm
  fiducial_diameter_px = math.floor(fiducial_diameter_px + 0.5)
  self.fiducial_diameter_px = fiducial_diameter_px
end

function MRCIO:set_tilt_axis_angle ()
  local extended_header_tilt_axis
  if self.extended_header and #self.extended_header ~= 0 then
    extended_header_tilt_axis = self.extended_header[1].tilt_axis
  end

  local file_type = string.sub(self.header.labels_1, 1, 3)
  if extended_header_tilt_axis and file_type == 'Fei' then
    self.tilt_axis_angle = extended_header_tilt_axis * -1

  elseif extended_header_tilt_axis then
    self.tilt_axis_angle = extended_header_tilt_axis

  elseif file_type == 'Ser' then
    self.tilt_axis_angle = string.match(self.header.labels_2,
                                  'Tilt%saxis%sangle%s=%s(%-?%d+%.?%d+)')
  elseif self.has_mdoc then
    local mdoc_file = io.open(self.mdoc_filename, 'r')
    for line in mdoc_file:lines('*l') do
      local rotation_angle = string.match(line, 'RotationAngle%s=%s(%d+%.%d+)$')
      if rotation_angle then
        self.tilt_axis_angle = rotation_angle - 90.0
        break
      end
    end

    if not self.tilt_axis_angle then
      io.stderr:write('WARNING: MRCIO:set_tilt_axis_angle: Cannot determine ' ..
                      'tilt axis angle so set to 0.0.\n')
      self.tilt_axis_angle = 0.0
    end

  else
    io.stderr:write('WARNING: MRCIO:set_tilt_axis_angle: Cannot determine ' ..
                    'tilt axis angle so set to 0.0.\n')
    self.tilt_axis_angle = 0.0
  end
end

--- Write an MRC file with a given header.
-- This function writes a MRC file using a provided table object with header
-- information
-- @param input_filename MRC file to set header
-- @param output_filename Output MRC file
-- @param header Table object with standard header information
-- @param extended_header Table object with extended header information
function MRCIO:write (output_filename)
  local header_data = ''
  for _, field in ipairs(self.header_fields) do
    header_data = header_data .. string.pack(field[2], self.header[field[1]])
  end

  if self.extended_header and #self.extended_header ~= 0 then
    for i = 1, 1024 do
      if i <= self.header.nz then
        local header = self.extended_header[i]
        for _, field in ipairs(self.extended_header_fields) do
          header_data = self.is_IMOD and
                        header_data .. string.pack('h', header[field]) or
                        header_data .. string.pack('f', header[field])
        end

        if not self.is_IMOD then
          for j = 1, 16 do
            header_data = header_data .. string.pack('f', 0.0)
          end
        end

      elseif i > self.header.nz and self.is_IMOD then
        local excess = self.header.Next - self.header.nz * self.header.nint
        for j = 1, excess, 2 do
          header_data = header_data .. string.pack('h', 0)
        end

        break

      elseif i > self.header.nz then
        for j = 1, 32 do
          header_data = header_data .. string.pack('f', 0.0)
        end
      end
    end
  end

  if #header_data ~= 1024 + self.header.Next then
    error('ERROR: MRCIO:write: header data invalid size.')
  end

  Utils.backup(output_filename)
  local output_file = io.open(output_filename, 'wb')
  output_file:write(header_data)

  local pixel_data_size
  if self.header.mode == 0 then
    pixel_data_size = 1

  elseif self.header.mode == 1 or self.header.mode == 6 then
    pixel_data_size = 2

  elseif self.header.mode == 2 or self.header.mode == 3 then
    pixel_data_size = 4

  elseif self.header.mode == 4 then
    pixel_data_size = 8

  end

  local mrc = io.open(self.filename, 'rb')
  local jump = 1024 + self.header.Next
  mrc:seek('set', jump)

  local section_size = self.header.nx * self.header.ny * pixel_data_size
  for i = 1, self.header.nz do
    output_file:write(mrc:read(section_size))
  end

  mrc:close()
  output_file:close()
end

return MRCIO
