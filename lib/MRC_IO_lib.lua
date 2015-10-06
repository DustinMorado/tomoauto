--- MRC Input Output control library.
-- This module provides all of the input output access for the MRC file format
-- particularly in regards to the header information.
--
-- @module MRC_IO_lib
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.10

local MRC_IO_lib = {}

local struct = assert(require 'struct')
local math, string, table = math, string, table

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
function MRC_IO_lib.get_header(input_filename)
   local header    = {}
   local input_file = assert(io.open(input_filename, 'rb'))
   -- Image size information
   header.nx = struct.unpack('i', input_file:read(4)) -- # of cols. (fastest)
   header.ny = struct.unpack('i', input_file:read(4)) -- # of rows
   header.nz = struct.unpack('i', input_file:read(4)) -- # of secs. (slowest)
   -- Image/transform data format
   -- 0: Image:      unsigned or signed byte (-128, 127; 0-255)
   -- 1: Image:      signed short (-32,768, 32,767)
   -- 2: Image:      single-precision float
   -- 3: Transform:  16-bit (2x short) complex integer
   -- 4: Transform:  64-bit (2x float) complex float
   -- 6: Image:      unsigned short (0, 65,536)
   header.mode = struct.unpack('i', input_file:read(4))
   -- Image size lower bounds
   header.nxstart = struct.unpack('i', input_file:read(4))
   header.nystart = struct.unpack('i', input_file:read(4))
   header.nzstart = struct.unpack('i', input_file:read(4))
   -- Image grid sizes
   header.mx = struct.unpack('i', input_file:read(4))
   header.my = struct.unpack('i', input_file:read(4))
   header.mz = struct.unpack('i', input_file:read(4))
   -- Image cell sizes
   header.xlen = struct.unpack('f', input_file:read(4))
   header.ylen = struct.unpack('f', input_file:read(4))
   header.zlen = struct.unpack('f', input_file:read(4))
   -- Image cell angles (Not used all set to 90)
   header.alpha = struct.unpack('f', input_file:read(4))
   header.beta  = struct.unpack('f', input_file:read(4))
   header.gamma = struct.unpack('f', input_file:read(4))
   -- Axis Mappings (Not used, should be 1,2,3 -> X,Y,Z)
   header.mapc = struct.unpack('i', input_file:read(4)) -- map columns
   header.mapr = struct.unpack('i', input_file:read(4)) -- map rows
   header.maps = struct.unpack('i', input_file:read(4)) -- map sections
   -- Image data value stats
   header.amin  = struct.unpack('f', input_file:read(4)) -- min pixel value
   header.amax  = struct.unpack('f', input_file:read(4)) -- max pixel value
   header.amean = struct.unpack('f', input_file:read(4)) -- mean pixel value
   -- Space group number (not used, set to 0)
   header.ispg = struct.unpack('h', input_file:read(2))
   -- Symmetry info (not used, set to 0)
   header.nsymbt = struct.unpack('h', input_file:read(2))
   -- This value describes the offset in bytes from the end of the header to the
   -- first image dataset.
   header.Next = struct.unpack('i', input_file:read(4))
   -- Creator ID (not used, set to 0)
   header.dvid = struct.unpack('h', input_file:read(2))
   -- 30 Extra bytes (not used, set to 0)
   header.extra = struct.unpack('c30', input_file:read(30))
   -- These next two shorts vary on whether or not they come from SerialEM or
   -- use the Agard format for the extended header. The first short nint is the
   -- number of integers per section (Agard) or the number of bytes per section
   -- (SerialEM). The second short nreal is the number of reals per section
   -- (Agard) or bit flags for which type of data is in the extended header
   -- (SerialEM).
   header.nint  = struct.unpack('h', input_file:read(2))
   header.nreal = struct.unpack('h', input_file:read(2))
   -- These are a bunch of entries that aren't used
   header.sub  = struct.unpack('h', input_file:read(2))
   header.zfac = struct.unpack('h', input_file:read(2))
   header.min2 = struct.unpack('f', input_file:read(4))
   header.max2 = struct.unpack('f', input_file:read(4))
   header.min3 = struct.unpack('f', input_file:read(4))
   header.max3 = struct.unpack('f', input_file:read(4))
   -- These two values if from Biol3d packages deviate from the standard and we
   -- follow this deviation...grudgingly.
   header.imodStamp = struct.unpack('i', input_file:read(4))
   -- Bit flags:
   -- 1 = bytes are stored as signed
   -- 2 = pixel spacing was set from size in extended header
   -- 4 = origin is stored with sign inverted from definition below
   header.imodFlags = struct.unpack('i', input_file:read(4))
   -- Image ID type
   -- 0: mono 1: tilt 2: tilts 3: lina 4: lins
   header.idtype = struct.unpack('h', input_file:read(2))
   -- lens (who knows what that means?)
   header.lens = struct.unpack('h', input_file:read(2))
   -- nd1, nd2 (who knows what that means?)
   -- if idtype = 1 then nd1 = axis (1,2,3 -> X,Y,Z)
   header.nd1 = struct.unpack('h', input_file:read(2))
   header.nd2 = struct.unpack('h', input_file:read(2))
   -- vd1, vd2 (who knows what that means?)
   -- vd1 = 100. * tilt increment
   -- vd2 = 100. * starting angle
   header.vd1 = struct.unpack('h', input_file:read(2))
   header.vd2 = struct.unpack('h', input_file:read(2))
   -- Image tilt angles 0,1,2 = original 3,4,5 = current
   header.tiltAngles = {}
   for i=1,6 do
      local tiltAngle = struct.unpack('f', input_file:read(4))
      table.insert(header.tiltAngles, tiltAngle)
   end
   -- Image origin
   header.xorg = struct.unpack('f', input_file:read(4))
   header.yorg = struct.unpack('f', input_file:read(4))
   header.zorg = struct.unpack('f', input_file:read(4))
   -- Image cmap (Another IMOD stamp?)
   header.cmap = struct.unpack('c4', input_file:read(4))
   -- Image Endianness
   header.stamp = struct.unpack('c4', input_file:read(4))
   -- The Root Mean Square deviation of densities from mean density
   header.rms = struct.unpack('f', input_file:read(4))
   -- The number of labels in the header
   header.nlabl = struct.unpack('i', input_file:read(4))
   header.labels = {}
   for i=1, header.nlabl do
      local label = struct.unpack('c80', input_file:read(80))
      table.insert(header.labels, label)
   end
   input_file:close()
   return header
end

--- Reads Bio3d style floats in the header.
-- This function handles Bio3D's weird way of putting floats in the extended
-- header
-- @param short_1 first short read in
-- @param short_2 second short read in
-- @return real A float
local function IMOD_short_to_float(short_1, short_2)
   local short_1_sign = short_1 < 0 and -1 or 1
   local short_2_sign = short_2 < 0 and -1 or 1
   short_1 = math.abs(short_1)
   short_2 = math.abs(short_2)
   local real = short_1_sign * ((256 * short_1) +
                (short_2 % 256)) * 2 ^ (short_2_sign * (short_2 / 256))
   return real
end

--- Checks MRC header type.
-- This function reads the nint and nreal sections in the header and checks to
-- see if the file comes from IMOD
-- @param nint section from header
-- @param nreal section from header
-- @return true if MRC is SerialEM/IMOD style otherwise nil
function MRC_IO_lib.is_IMOD(nint, nreal)
   local sum = 0
   if bit32.btest(nreal, 1)  then sum = sum + 2 end
   if bit32.btest(nreal, 2)  then sum = sum + 6 end
   if bit32.btest(nreal, 4)  then sum = sum + 4 end
   if bit32.btest(nreal, 8)  then sum = sum + 2 end
   if bit32.btest(nreal, 16) then sum = sum + 2 end
   if bit32.btest(nreal, 32) then sum = sum + 4 end
   if sum == nint then -- This is an IMOD extended header
      return true
   else                -- This is an AGARD extended header
      return nil
   end
end

--- Reads MRC file extended header.
-- A function that reads the extended header for a given MRC file and returns a
-- table object with the corresponnding data
-- @param input_filename MRC file to be read
-- @return extended_header A table object with MRC file information
function MRC_IO_lib.get_extended_header(input_filename)
   local extended_header = {}
   local input_file = assert(io.open(input_filename, 'rb'))
   local header     = MRC_IO_lib.get_header(input_filename)
   local nz         = header.nz
   local Next       = header.Next
   local nint       = header.nint
   local nreal      = header.nreal
   local is_IMOD    = MRC_IO_lib.is_IMOD(nint, nreal)
   header = nil -- clear some space
   if Next == 0 then
      return extended_header
   end
   for i = 1, nz do
      local extended_header_section = {}
      if not is_IMOD then
         local jump = 1024 + (128 * (i - 1))
         input_file:seek('set', jump)
         -- alpha and beta tilt in degrees
         extended_header_section.a_tilt = struct.unpack('f', input_file:read(4))
         extended_header_section.b_tilt = struct.unpack('f', input_file:read(4))
         -- stage positions. Normally in SI units but maybe in micrometers
         extended_header_section.x_stage = struct.unpack('f',
            input_file:read(4))
         extended_header_section.y_stage = struct.unpack('f',
            input_file:read(4))
         extended_header_section.z_stage = struct.unpack('f',
            input_file:read(4))
         -- image shift. In the same units as stage positions
         extended_header_section.x_shift = struct.unpack('f',
            input_file:read(4))
         extended_header_section.y_shift = struct.unpack('f',
            input_file:read(4))
         -- image defocus as read from scope. In same units as stage positions
         extended_header_section.defocus = struct.unpack('f',
            input_file:read(4))
         -- image exposure time in seconds
         extended_header_section.exp_time = struct.unpack('f',
            input_file:read(4))
         -- mean value of image
         extended_header_section.mean_int = struct.unpack('f',
            input_file:read(4))
         -- image tilt axis offset: The orientation of the tilt axis in the image
         -- in degrees. Vertical to the top is 0 Angstroms, the direction of
         -- positive rotation is anti-clockwise.
         extended_header_section.tilt_axis = struct.unpack('f',
            input_file:read(4))
         -- pixel size. Check units may be SI or micrometers
         extended_header_section.pixel_size = struct.unpack('f',
            input_file:read(4))
         -- magnification used
         extended_header_section.magnification = struct.unpack('f',
            input_file:read(4))
         -- high-tension, in SI units (volts)
         extended_header_section.ht = struct.unpack('f',
            input_file:read(4))
         -- binning of the CCD acquisition
         extended_header_section.binning = struct.unpack('f',
            input_file:read(4))
         -- intended application defocus, should be in SI units (meters)
         extended_header_section.appliedDefocus = struct.unpack('f',
            input_file:read(4))
      elseif is_IMOD then
         local jump = 1024 + nint * (i - 1)
         input_file:seek('set', jump)
         if bit32.btest(nreal, 1) then
            extended_header_section.a_tilt = struct.unpack('h',
               input_file:read(2)) / 100
         end
         if bit32.btest(nreal, 2) then
            -- Montage piece coordinates
            extended_header_section.mon = {}
            for i = 1, 3 do
               local monCoord = struct.unpack('h', input_file:read(2))
               table.insert(extended_header_section.mon, monCoord)
            end
         end
         if bit32.btest(nreal, 4) then
            extended_header_section.x_stage = struct.unpack('h',
               input_file:read(2)) / 25
            extended_header_section.y_stage = struct.unpack('h',
               input_file:read(2)) / 25
         end
         if bit32.btest(nreal, 8) then
            extended_header_section.magnification = struct.unpack('h',
               input_file:read(2)) * 100
         end
         if bit32.btest(nreal, 16) then
            extended_header_section.intensity = struct.unpack('h',
               input_file:read(2)) / 25000
         end
         if bit32.btest(nreal, 32) then
            -- Exposure dose in e-/A^2
            extended_header_section.exp_dose = struct.unpack('f',
               input_file:read(4))
         end
      else
         error('Error: I do not know this type of input_file.')
      end
      extended_header[i] = extended_header_section
   end
   input_file:close()
   return extended_header
end

--- Gets the tilt angles from the extended header of a tilt series.
-- This function writes the tilt angles out to stdout or a file.
-- @param input_filename MRC file to read
-- @param output_filename [optional] Output file
function MRC_IO_lib.get_tilt_angles(input_filename, output_filename)
   local mdoc_filename   = input_filename .. '.mdoc'
   local header          = MRC_IO_lib.get_header(input_filename)
   local extended_header = MRC_IO_lib.get_extended_header(input_filename)
   local nz              = header.nz
   local output_file     = io.stdout
   header = nil
   if output_filename then
      output_file = io.open(output_filename, 'w')
   end
   if type(extended_header) == 'table' and type(extended_header[1]) == 'table'
      and extended_header[1].a_tilt then
      for i = 1, nz do
         if not extended_header[i].a_tilt then
            error(string.format('Error: No tilt angle for %s section %d.\n',
               input_filename, i))
         else
            output_file:write(string.format('% 6.2f\n',
               extended_header[i].a_tilt))
         end
      end
   else
      mdoc_file = io.open(mdoc_filename, 'r')
      if mdoc_file then
         for line in mdoc_file:lines('*l') do
            local tilt_angle = string.match(line, 'TiltAngle%s=%s(-?%d+%.%d+)')
            tilt_angle = tonumber(tilt_angle)
            if tilt_angle then
               output_file:write(string.format('% 6.2f\n', tilt_angle))
            end
         end
         mdoc_file:close()
      else
         error(string.format(
            'Error: No tilt angles found in %s\'s extend header\n',
            input_filename))
      end
   end
   output_file:close()
end

--- Write an MRC file with a given header.
-- This function writes a MRC file using a provided table object with header
-- information
-- @param input_filename MRC file to set header
-- @param output_filename Output MRC file
-- @param header Table object with standard header information
-- @param extended_header Table object with extended header information
function MRC_IO_lib.set_header(input_filename, output_filename, header,
   extended_header)

   local input_header    = MRC_IO_lib.get_header(input_filename)
   local jump            = 1024 + input_header.Next
   local pixel_data_size = 1

   if input_header.mode == 0 then
      pixel_data_size = 1
   elseif input_header.mode == 1 then
      pixel_data_size = 2
   elseif input_header.mode == 2 then
      pixel_data_size = 4
   elseif input_header.mode == 6 then
      pixel_data_size = 2
   end
   input_header = nil

   local output_file = assert(io.open(output_filename, 'wb'))
   local is_IMOD = MRC_IO_lib.is_IMOD(header.nint, header.nreal)
   output_file:write(struct.pack('i',   header.nx))
   output_file:write(struct.pack('i',   header.ny))
   output_file:write(struct.pack('i',   header.nz))
   output_file:write(struct.pack('i',   header.mode))
   output_file:write(struct.pack('i',   header.nxstart))
   output_file:write(struct.pack('i',   header.nystart))
   output_file:write(struct.pack('i',   header.nzstart))
   output_file:write(struct.pack('i',   header.mx))
   output_file:write(struct.pack('i',   header.my))
   output_file:write(struct.pack('i',   header.mz))
   output_file:write(struct.pack('f',   header.xlen))
   output_file:write(struct.pack('f',   header.ylen))
   output_file:write(struct.pack('f',   header.zlen))
   output_file:write(struct.pack('f',   header.alpha))
   output_file:write(struct.pack('f',   header.beta))
   output_file:write(struct.pack('f',   header.gamma))
   output_file:write(struct.pack('i',   header.mapc))
   output_file:write(struct.pack('i',   header.mapr))
   output_file:write(struct.pack('i',   header.maps))
   output_file:write(struct.pack('f',   header.amin))
   output_file:write(struct.pack('f',   header.amax))
   output_file:write(struct.pack('f',   header.amean))
   output_file:write(struct.pack('h',   header.ispg))
   output_file:write(struct.pack('h',   header.nsymbt))
   output_file:write(struct.pack('i',   header.Next))
   output_file:write(struct.pack('h',   header.dvid))
   output_file:write(struct.pack('c30', header.extra))
   output_file:write(struct.pack('h',   header.nint))
   output_file:write(struct.pack('h',   header.nreal))
   output_file:write(struct.pack('h',   header.sub))
   output_file:write(struct.pack('h',   header.zfac))
   output_file:write(struct.pack('f',   header.min2))
   output_file:write(struct.pack('f',   header.max2))
   output_file:write(struct.pack('f',   header.min3))
   output_file:write(struct.pack('f',   header.max3))
   output_file:write(struct.pack('i',   header.imodStamp))
   output_file:write(struct.pack('i',   header.imodFlags))
   output_file:write(struct.pack('h',   header.idtype))
   output_file:write(struct.pack('h',   header.lens))
   output_file:write(struct.pack('h',   header.nd1))
   output_file:write(struct.pack('h',   header.nd2))
   output_file:write(struct.pack('h',   header.vd1))
   output_file:write(struct.pack('h',   header.vd2))
   for i=1,6 do
      output_file:write(struct.pack('f', header.tiltAngles[1]))
   end
   output_file:write(struct.pack('f',  header.xorg))
   output_file:write(struct.pack('f',  header.yorg))
   output_file:write(struct.pack('f',  header.zorg))
   output_file:write(struct.pack('c4', header.cmap))
   output_file:write(struct.pack('c4', header.stamp))
   output_file:write(struct.pack('f',  header.rms))
   output_file:write(struct.pack('i',  header.nlabl))
   for i = 1, 10 do
      if header.labels[i] then
         output_file:write(struct.pack('c80', header.labels[i] ..
            string.rep(' ', 80)))
      else
         output_file:write(struct.pack('c80', string.rep(' ', 80)))
      end
   end
   if is_IMOD then
      local extended_header_extra = header.Next - (header.nz * header.nint)
      for i = 1, header.nz do
         if extended_header[i].a_tilt then
            output_file:write(struct.pack('h', extended_header[i].a_tilt * 100))
         end
         if extended_header[i].mon then
            for j = 1, 3 do
               output_file:write(struct.pack('h', extended_header[i].mon[j]))
            end
         end
         if extended_header[i].x_stage then
            output_file:write(struct.pack('h', extended_header[i].x_stage * 25))
            output_file:write(struct.pack('h', extended_header[i].y_stage * 25))
         end
         if extended_header[i].magnification then
            output_file:write(struct.pack('h',
                  extended_header[i].magnification / 100))
         end
         if extended_header[i].intensity then
            output_file:write(struct.pack('h',
                  extended_header[i].intensity * 25000))
         end
         if extended_header[i].exp_dose then
            output_file:write(struct.pack('f', extended_header[i].exp_dose))
         end
      end
      if extended_header_extra > 1 and extended_header_extra % 2 == 0 then
         for i = 1, (extended_header_extra / 2) do
            output_file:write(struct.pack('h', 0))
         end
      end
   else
      for i = 1, 1024 do
         if extended_header[i] then
            output_file:write(struct.pack('f', extended_header[i].a_tilt))
            output_file:write(struct.pack('f', extended_header[i].b_tilt))
            output_file:write(struct.pack('f', extended_header[i].x_stage))
            output_file:write(struct.pack('f', extended_header[i].y_stage))
            output_file:write(struct.pack('f', extended_header[i].z_stage))
            output_file:write(struct.pack('f', extended_header[i].x_shift))
            output_file:write(struct.pack('f', extended_header[i].y_shift))
            output_file:write(struct.pack('f', extended_header[i].defocus))
            output_file:write(struct.pack('f', extended_header[i].exp_time))
            output_file:write(struct.pack('f', extended_header[i].mean_int))
            output_file:write(struct.pack('f', extended_header[i].tilt_axis))
            output_file:write(struct.pack('f', extended_header[i].pixel_size))
            output_file:write(struct.pack('f',
                  extended_header[i].magnification))
            output_file:write(struct.pack('f', extended_header[i].ht))
            output_file:write(struct.pack('f', extended_header[i].binning))
            output_file:write(struct.pack('f',
                  extended_header[i].appliedDefocus))
            for j = 1, 16 do
               output_file:write(struct.pack('f', 0))
            end
         else
            for j = 1, 32 do
               output_file:write(struct.pack('f', 0))
            end
         end
      end
   end

   local input_file  = io.open(input_filename, 'rb')
   input_file:seek('set', jump)
   while true do
      local block_size = 1024
      local data_block = input_file:read(block_size)
      if not data_block then
         break
      end
      output_file:write(data_block)
   end
   input_file:close()
   output_file:close()
end

--- Modifies the header information of a MRC file.
-- This function modifes and rewrites the header of an MRC file.
-- @param input_filename MRC file to process
-- @param output_filename New MRC filename
-- @param options_table Table object with option flags from yago
function MRC_IO_lib.write_header(input_filename, output_filename, options_table)
   local header          = MRC_IO_lib.get_header(input_filename)
   local extended_header = MRC_IO_lib.get_extended_header(input_filename)
   local is_IMOD         = MRC_IO_lib.is_IMOD(header.nint, header.nreal)
   local nz              = header.nz
   if options_table.a_ then header.nx            = options_table.a_ end
   if options_table.b_ then header.ny            = options_table.b_ end
   if options_table.c_ then header.nz            = options_table.c_ end
   if options_table.d_ then header.mode          = options_table.d_ end
   if options_table.e_ then header.nxstart       = options_table.e_ end
   if options_table.f_ then header.nystart       = options_table.f_ end
   if options_table.g_ then header.nzstart       = options_table.g_ end
   if options_table.i_ then header.mx            = options_table.i_ end
   if options_table.j_ then header.my            = options_table.j_ end
   if options_table.k_ then header.mz            = options_table.k_ end
   if options_table.l_ then header.xlen          = options_table.l_ end
   if options_table.m_ then header.ylen          = options_table.m_ end
   if options_table.n_ then header.zlen          = options_table.n_ end
   if options_table.o_ then header.amin          = options_table.o_ end
   if options_table.p_ then header.amax          = options_table.p_ end
   if options_table.q_ then header.amean         = options_table.q_ end
   if options_table.r_ then header.tiltAngles[4] = options_table.r_ end
   if options_table.s_ then header.tiltAngles[5] = options_table.s_ end
   if options_table.t_ then header.tiltAngles[6] = options_table.t_ end
   if options_table.u_ then header.xorg          = options_table.u_ end
   if options_table.v_ then header.yorg          = options_table.v_ end
   if options_table.w_ then header.zorg          = options_table.w_ end
   if options_table.x_ then header.rms           = options_table.x_ end
   if options_table.y_ then
      local label_index = 2
      if options_table.z_ then label_index = tonumber(options_table.z_) end
      if tonumber(header.nlabl) < 10 then
         table.insert(header.labels, label_index, options_table.y_)
         header.nlabl = header.nlabl + 1
      elseif tonumber(header.nlabl) == 10 then
         table.insert(header.labels, label_index, options_table.y_)
         table.remove(header.labels)
      end
   end
   for i = 1, nz do
      if not is_IMOD then
         if options_table.A_ and options_table.B_ then
            if tonumber(options_table.A_) > 0 then
               extended_header[i].a_tilt = tonumber(options_table.A_) -
                  (i - 1) * options_table.B_
            else
               extended_header[i].a_tilt = tonumber(options_table.A_) * -1 -
                  (i - 1) * options_table.B_
            end
         end
         if options_table.C_ then
            extended_header.defocus = options_table.C_
         end
         if options_table.D_ then
            extended_header.exp_time = options_table.D_
         end
         if options_table.E_ then
            extended_header.tilt_axis = options_table.E_
         end
         if options_table.F_ then
            extended_header.pixel_size = options_table.F_
         end
         if options_table.G_ then
            extended_header.magnification = options_table.G_
         end
         if options_table.I_ then
            extended_header.ht = options_table.I_
         end
         if options_table.J_ then
            extended_header.binning = options_table.J_
         end
         if options_table.K_ then
            extended_header.appliedDefocus = options_table.K_
         end
      else
         if options_table.A_ and options_table.B_ then
            if tonumber(options_table.A_) > 0 then
               extended_header[i].a_tilt = tonumber(options_table.A_) -
                  (i - 1) * options_table.B_
            else
               extended_header[i].a_tilt = tonumber(options_table.A_) * -1 -
                  (i - 1) * options_table.B_
            end
         end
         if options_table.G_ then
            extended_header[i].magnification = options_table.G_
         end
         if options_table.L_ then
            extended_header[i].intensity = options_table.L_
         end
         if options_table.M_ then
            extended_header[i].exp_dose = options_table.M_
         end
      end
   end
   MRC_IO_lib.set_header(input_filename, output_filename, header,
      extended_header)
end

--- Gets all header information needed for tomoauto.
-- This function returns a table object with a mix of data from the standard and
-- the extended MRC header.
-- @param input_filename MRC stack filename
-- @param fiducial_diameter Size of fiducial markers in nm
-- @return header A table object with the required information
function MRC_IO_lib.get_required_header(input_filename, fiducial_diameter)

   local  header = MRC_IO_lib.get_header(input_filename)
   local  extended_header = MRC_IO_lib.get_extended_header(input_filename)

   header.file_type = string.sub(header.labels[1], 1, 3)

   if header.file_type == 'Fei' then
      header.tilt_axis  = -1  * extended_header[1].tilt_axis
      header.pixel_size = 1e9 * extended_header[1].pixel_size

   elseif header.file_type == 'TF3' then
      header.tilt_axis  = extended_header[1].tilt_axis
      header.pixel_size = extended_header[1].pixel_size / 10

   elseif header.file_type == 'Ser' then
      header.tilt_axis = string.match(header.labels[2],
         'Tilt%saxis%sangle%s=%s(%-?%d+%.?%d+)')
      header.pixel_size = (header.xlen / header.mx) / 10
   else
      error(string.format('Error: I do no know how to handle image stack %s.\n',
         input_filename))
   end

   -- Calculate the Fiducial size in pixels
   header.fiducial_diameter_px = math.floor(
      fiducial_diameter / header.pixel_size + 0.5)

   -- Find the section at 0 degrees to split alignments
   --[[ Commented out since we are no longer collectiing bidirectionally
   for i = 1, header.nz do
      if math.floor(extended_header[i].a_tilt) == 0 then
         header.split_angle = i
      end
   end
   if not header.split_angle then
      error(string.format('Error: Could not find a zero degree tilt for %s.\n',
         input_filename))
   end
   --]]
   return header
end
return MRC_IO_lib
