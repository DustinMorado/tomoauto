--- MRC Input Output control library.
-- This module provides all of the input output access for the MRC file format
-- particularly in regards to the header information.
--
-- @module MRCIO
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.10

local MRCIO = {}
local math, string, table = math, string, table

--- Reads Bio3d style floats in the extended header.
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
local function check_IMOD(nint, nreal)
    local sum = 0
    sum = nreal & 1  ~= 0 and sum + 2 or sum
    sum = nreal & 2  ~= 0 and sum + 6 or sum
    sum = nreal & 4  ~= 0 and sum + 4 or sum
    sum = nreal & 8  ~= 0 and sum + 2 or sum
    sum = nreal & 16 ~= 0 and sum + 2 or sum
    sum = nreal & 32 ~= 0 and sum + 4 or sum
    local check = sum == nint and true or false
    return check
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
function MRCIO.get_header(input_filename)
    local input_file = assert(io.open(input_filename, 'rb'))
    local header_data = input_file:read(1024)
    input_file:close()

    local header = {
        nx         =   string.unpack('i',   header_data, 1),
        ny         =   string.unpack('i',   header_data, 5),
        nz         =   string.unpack('i',   header_data, 9),
        mode       =   string.unpack('i',   header_data, 13),
        nxstart    =   string.unpack('i',   header_data, 17),
        nystart    =   string.unpack('i',   header_data, 21),
        nzstart    =   string.unpack('i',   header_data, 25),
        mx         =   string.unpack('i',   header_data, 29),
        my         =   string.unpack('i',   header_data, 33),
        mz         =   string.unpack('i',   header_data, 37),
        xlen       =   string.unpack('f',   header_data, 41),
        ylen       =   string.unpack('f',   header_data, 45),
        zlen       =   string.unpack('f',   header_data, 49),
        alpha      =   string.unpack('f',   header_data, 53),
        beta       =   string.unpack('f',   header_data, 57),
        gamma      =   string.unpack('f',   header_data, 61),
        mapc       =   string.unpack('i',   header_data, 65),
        mapr       =   string.unpack('i',   header_data, 69),
        maps       =   string.unpack('i',   header_data, 73),
        amin       =   string.unpack('f',   header_data, 77),
        amax       =   string.unpack('f',   header_data, 81),
        amean      =   string.unpack('f',   header_data, 85),
        ispg       =   string.unpack('i',   header_data, 89),
        Next       =   string.unpack('i',   header_data, 93),
        dvid       =   string.unpack('h',   header_data, 97),
        extra      =   string.unpack('c30', header_data, 99),
        nint       =   string.unpack('h',   header_data, 129),
        nreal      =   string.unpack('h',   header_data, 131),
        sub        =   string.unpack('h',   header_data, 133),
        zfac       =   string.unpack('h',   header_data, 135),
        min2       =   string.unpack('f',   header_data, 137),
        max2       =   string.unpack('f',   header_data, 141),
        min3       =   string.unpack('f',   header_data, 145),
        max3       =   string.unpack('f',   header_data, 149),
        imodStamp  =   string.unpack('i',   header_data, 153),
        imodFlags  =   string.unpack('i',   header_data, 157),
        idtype     =   string.unpack('h',   header_data, 161),
        lens       =   string.unpack('h',   header_data, 163),
        nd1        =   string.unpack('h',   header_data, 165),
        nd2        =   string.unpack('h',   header_data, 167),
        vd1        =   string.unpack('h',   header_data, 169),
        vd2        =   string.unpack('h',   header_data, 171),
        tiltAngles = { string.unpack('f',   header_data, 173),
                       string.unpack('f',   header_data, 177),
                       string.unpack('f',   header_data, 181),
                       string.unpack('f',   header_data, 185),
                       string.unpack('f',   header_data, 189),
                       string.unpack('f',   header_data, 193)},
        xorg       =   string.unpack('f',   header_data, 197),
        yorg       =   string.unpack('f',   header_data, 201),
        zorg       =   string.unpack('f',   header_data, 205),
        cmap       =   string.unpack('c4',  header_data, 209),
        stamp      =   string.unpack('c4',  header_data, 213),
        rms        =   string.unpack('f',   header_data, 217),
        nlabl      =   string.unpack('i',   header_data, 221),
        labels     = { string.unpack('c80', header_data, 225),
                       string.unpack('c80', header_data, 305),
                       string.unpack('c80', header_data, 385),
                       string.unpack('c80', header_data, 465),
                       string.unpack('c80', header_data, 545),
                       string.unpack('c80', header_data, 625),
                       string.unpack('c80', header_data, 705),
                       string.unpack('c80', header_data, 785),
                       string.unpack('c80', header_data, 865),
                       string.unpack('c80', header_data, 945)}}
    header.isIMOD = check_IMOD(header.nint, header.nreal)
    header.extendedFields = get_extended_fields(header.nint, header.nreal)
    header_data = nil
    return header
end

--- Reads MRC file extended header.
-- A function that reads the extended header for a given MRC file and returns a
-- table object with the corresponnding data
-- @param input_filename MRC file to be read
-- @return extended_header A table object with MRC file information
function MRCIO.get_extended_header(input_filename)
    local header = MRCIO.get_header(input_filename)
    local extended_header_data

    if header.Next == 0 then
        return nil
    else
        local input_file = assert(io.open(input_filename, 'rb'))
        input_file:seek('set', 1024)
        extended_header_data = input_file:read(header.Next)
        input_file:close()
    end

    local extended_header = {}
    for i = 1, header.nz do
        extended_header[i] = {}

        if header.is_IMOD then
            local offset = header.nint * (i - 1) + 1

            if header.nreal & 1 ~= 0 then
                extended_header[i].a_tilt, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].a_tilt = extended_header[i].a_tilt / 100
            end

            if header.nreal & 2 ~= 0 then
                extended_header[i].mon = {}

                for j = 1, 3 do
                    table.insert(extended_header[i].mon, string.unpack('h',
                        extended_header_data, offset))
                    offset = offset + 2
                end
            end

            if header.nreal & 4 ~= 0 then
                extended_header[i].x_stage, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].x_stage = extended_header[i].x_stage / 25
                extended_header[i].y_stage, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].y_stage = extended_header[i].y_stage / 25
            end

            if header.nreal & 8 ~= 0 then
                extended_header[i].magnification, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].magnification =
                    extended_header[i].magnification * 100
            end

            if header.nreal & 16 ~= 0 then
                extended_header[i].intensity, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].intensity = extended_header[i].intensity /
                    25000
            end

            if header.nreal & 32 ~= 0 then
                local exp_dose_short_1, offset = string.unpack('h',
                    extended_header_data, offset)
                local exp_dose_short_2, offset = string.unpack('h',
                    extended_header_data, offset)
                extended_header[i].exp_dose = IMOD_short_to_float(
                    exp_dose_short_1, exp_dose_short_2)
            end
        else
            local offset = 128 * (i - 1) + 1
            extended_header[i].a_tilt,         offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].b_tilt,         offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].x_stage,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].y_stage,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].z_stage,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].x_shift,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].y_shift,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].defocus,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].exp_time,       offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].mean_int,       offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].tilt_axis,      offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].pixel_size,     offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].magnification,  offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].ht,             offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].binning,        offset = string.unpack('f',
                extended_header_data, offset)
            extended_header[i].appliedDefocus, offset = string.unpack('f',
                extended_header_data, offset)
        end
    end
    extended_header_data = nil
    return extended_header
end

--- Gets the tilt angles from the extended header of a tilt series.
-- This function writes the tilt angles out to stdout or a file.
-- @param input_filename MRC file to read
-- @param output_filename [optional] Output file
function MRCIO.get_tilt_angles(input_filename, output_filename)
    local mdoc_filename   = input_filename .. '.mdoc'
    local header          = MRCIO.get_header(input_filename)
    local extended_header = MRCIO.get_extended_header(input_filename)
    local output_file     = io.stdout

    if not extended_header then
        error(string.format('Error: No extended header in %s\n',
            input_filename))
    end

    if output_filename then
        output_file = io.open(output_filename, 'w')
    end

    if extended_header[1].a_tilt then
        for i = 1, header.nz do
            output_file:write(string.format('% 6.2f\n',
                extended_header[i].a_tilt))
        end
    else
        local mdoc_file = io.open(mdoc, 'r')
        if mdoc_file then
            for line in mdoc_output_file:lines('*l') do
                local tilt_angle = string.match(line,
                    'TiltAngle%s=%s(-?%d+%.%d+)')
                if tilt_angle then
                    tilt_angle = tonumber(tilt_angle)
                    output_file:write(string.format('% 6.2f\n', tilt_angle))
                end
            end
            mdoc_output_file:close()
        else
            output_file:close()
            error(string.format(
                'Error: No tilt angles found in %s\n', input_filename))
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
function MRCIO.set_header(input_filename, output_filename, header,
    extended_header)
    local input_header    = MRCIO.get_header(input_filename)
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

    local output_file = assert(io.open(output_filename, 'wb'))
    local header_data =          string.pack('i',   header.nx)
    header_data = header_data .. string.pack('i',   header.ny)
    header_data = header_data .. string.pack('i',   header.nz)
    header_data = header_data .. string.pack('i',   header.mode)
    header_data = header_data .. string.pack('i',   header.nxstart)
    header_data = header_data .. string.pack('i',   header.nystart)
    header_data = header_data .. string.pack('i',   header.nzstart)
    header_data = header_data .. string.pack('i',   header.mx)
    header_data = header_data .. string.pack('i',   header.my)
    header_data = header_data .. string.pack('i',   header.mz)
    header_data = header_data .. string.pack('f',   header.xlen)
    header_data = header_data .. string.pack('f',   header.ylen)
    header_data = header_data .. string.pack('f',   header.zlen)
    header_data = header_data .. string.pack('f',   header.alpha)
    header_data = header_data .. string.pack('f',   header.beta)
    header_data = header_data .. string.pack('f',   header.gamma)
    header_data = header_data .. string.pack('i',   header.mapc)
    header_data = header_data .. string.pack('i',   header.mapr)
    header_data = header_data .. string.pack('i',   header.maps)
    header_data = header_data .. string.pack('f',   header.amin)
    header_data = header_data .. string.pack('f',   header.amax)
    header_data = header_data .. string.pack('f',   header.amean)
    header_data = header_data .. string.pack('h',   header.ispg)
    header_data = header_data .. string.pack('h',   header.nsymbt)
    header_data = header_data .. string.pack('i',   header.Next)
    header_data = header_data .. string.pack('c30', header.extra)
    header_data = header_data .. string.pack('h',   header.nint)
    header_data = header_data .. string.pack('h',   header.nreal)
    header_data = header_data .. string.pack('h',   header.sub)
    header_data = header_data .. string.pack('h',   header.zfac)
    header_data = header_data .. string.pack('f',   header.min2)
    header_data = header_data .. string.pack('f',   header.max2)
    header_data = header_data .. string.pack('f',   header.min3)
    header_data = header_data .. string.pack('f',   header.max3)
    header_data = header_data .. string.pack('i',   header.imodStamp)
    header_data = header_data .. string.pack('i',   header.imodFlags)
    header_data = header_data .. string.pack('h',   header.idtype)
    header_data = header_data .. string.pack('h',   header.lens)
    header_data = header_data .. string.pack('h',   header.nd1)
    header_data = header_data .. string.pack('h',   header.nd2)
    header_data = header_data .. string.pack('h',   header.vd1)
    header_data = header_data .. string.pack('h',   header.vd2)
    header_data = header_data .. string.pack('ffffff',
        table.unpack(header.tiltAngles))
    header_data = header_data .. string.pack('f',   header.xorg)
    header_data = header_data .. string.pack('f',   header.yorg)
    header_data = header_data .. string.pack('f',   header.zorg)
    header_data = header_data .. string.pack('c4',  header.cmap)
    header_data = header_data .. string.pack('c4',  header.stamp)
    header_data = header_data .. string.pack('f',   header.rms)
    header_data = header_data .. string.pack('i',   header.nlabl)
    header_data = header_data .. string.pack(string.rep('c80', 10),
        table.unpack(header.labels))

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
function MRCIO.write_header(input_filename, output_filename, options_table)
    local header          = MRCIO.get_header(input_filename)
    local extended_header = MRCIO.get_extended_header(input_filename)
    local is_IMOD         = MRCIO.is_IMOD(header.nint, header.nreal)
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
        MRCIO.set_header(input_filename, output_filename, header,
        extended_header)
end

--- Gets all header information needed for tomoauto.
-- This function returns a table object with a mix of data from the standard and
-- the extended MRC header.
-- @param input_filename MRC stack filename
-- @param fiducial_diameter Size of fiducial markers in nm
-- @return header A table object with the required information
function MRCIO.get_required_header(input_filename, fiducial_diameter)
    local  header = MRCIO.get_header(input_filename)
    local  extended_header = MRCIO.get_extended_header(input_filename)

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
            for i = 1, header.nz do
                if math.floor(extended_header[i].a_tilt) == 0 then
                    header.split_angle = i
                end
            end
            if not header.split_angle then
                error(string.format('Error: Could not find a zero degree tilt for %s.\n',
                input_filename))
            end
            return header
end
return MRCIO
