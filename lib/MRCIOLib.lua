local tomoAutoDir = os.getenv('TOMOAUTOROOT')
package.cpath = package.cpath .. ';' .. tomoAutoDir .. '/lib/?.so;'
local struct = assert(require 'struct')
local math, string, table = math, string, table
local MRCIOLib = {}
--[[==========================================================================#
#                                  getHeader                                  #
#-----------------------------------------------------------------------------#
# A function that reads the image stack binary header file and finds the      #
# image size (nx, ny), the tilt axis rotation angle (tilt_axis) and the pixel #
# size (pixel_size). The fiducial size in pixels is also calculated to be     #
# used in RAPTOR.                                                             #
# The complete header information can be found here:                          #
# http://www.2dx.unibas.ch/documentation/mrc-software/                        #
# fei-extended-mrc-format-not-used-by-2dx                                     #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = image stack file <filename.st>                          #
#==========================================================================--]]
function MRCIOLib.getHeader(inputFile)
   local H    = {}
   local file = assert(io.open(inputFile, 'rb')) 
   -- Image size information 
   H.nx = struct.unpack('i4', file:read(4)) -- # of columns (fastest)
   H.ny = struct.unpack('i4', file:read(4)) -- # of rows
   H.nz = struct.unpack('i4', file:read(4)) -- # of sections (slowest)
   -- Image/transform data format
   -- 0: Image:      unsigned or signed byte (-128, 127; 0-255)
   -- 1: Image:      signed short (-32,768, 32,767)
   -- 2: Image:      single-precision float
   -- 3: Transform:  16-bit (2x short) complex integer
   -- 4: Transform:  64-bit (2x float) complex float
   -- 6: Image:      unsigned short (0, 65,536)
   H.mode = struct.unpack('i4', file:read(4))
   -- Image size lower bounds
   H.nxstart = struct.unpack('i4', file:read(4))
   H.nystart = struct.unpack('i4', file:read(4))
   H.nzstart = struct.unpack('i4', file:read(4))
   -- Image grid sizes
   H.mx = struct.unpack('i4', file:read(4))
   H.my = struct.unpack('i4', file:read(4))
   H.mz = struct.unpack('i4', file:read(4))
   -- Image cell sizes
   H.xlen = struct.unpack('f', file:read(4))
   H.ylen = struct.unpack('f', file:read(4))
   H.zlen = struct.unpack('f', file:read(4))
   -- Image cell angles (Not used all set to 90)
   H.alpha = struct.unpack('f', file:read(4))
   H.beta  = struct.unpack('f', file:read(4))
   H.gamma = struct.unpack('f', file:read(4))
   -- Axis Mappings (Not used, should be 1,2,3 -> X,Y,Z)
   H.mapc = struct.unpack('i4', file:read(4)) -- map columns
   H.mapr = struct.unpack('i4', file:read(4)) -- map rows
   H.maps = struct.unpack('i4', file:read(4)) -- map sections
   -- Image data value stats
   H.amin  = struct.unpack('f', file:read(4)) -- min pixel value
   H.amax  = struct.unpack('f', file:read(4)) -- max pixel value
   H.amean = struct.unpack('f', file:read(4)) -- mean pixel value
   -- Space group number (not used, set to 0)
   H.ispg = struct.unpack('i2', file:read(2))
   -- Symmetry info (not used, set to 0)
   H.nsymbt = struct.unpack('i2', file:read(2))
   -- This value describes the offset in bytes from the end of the header to the
   -- first image dataset.
   H.Next = struct.unpack('i4', file:read(4))
   -- Creator ID (not used, set to 0)
   H.dvid = struct.unpack('i2', file:read(2))
   -- 30 Extra bytes (not used, set to 0)
   H.extra = struct.unpack('i30', file:read(30))
   -- These next two shorts vary on whether or not they come from SerialEM or
   -- use the Agard format for the extended header. The first short nint is the
   -- number of integers per section (Agard) or the number of bytes per section
   -- (SerialEM). The second short nreal is the number of reals per section
   -- (Agard) or bit flags for which type of data is in the extended header
   -- (SerialEM).
   H.nint  = struct.unpack('i2', file:read(2))
   H.nreal = struct.unpack('i2', file:read(2))
   -- These are a bunch of entries that aren't used
   H.sub  = struct.unpack('i2', file:read(2))
   H.zfac = struct.unpack('i2', file:read(2))
   H.min2 = struct.unpack('f', file:read(4))
   H.max2 = struct.unpack('f', file:read(4))
   H.min3 = struct.unpack('f', file:read(4))
   H.max3 = struct.unpack('f', file:read(4))
   -- These two values if from Biol3d packages deviate from the standard and we
   -- follow this deviation...grudgingly.
   H.imodStamp = struct.unpack('i4', file:read(4))
   -- Bit flags:
   -- 1 = bytes are stored as signed
   -- 2 = pixel spacing was set from size in extended header
   -- 4 = origin is stored with sign inverted from definition below
   H.imodFlags = struct.unpack('i4', file:read(4))
   -- Image ID type
   -- 0: mono 1: tilt 2: tilts 3: lina 4: lins
   H.idtype = struct.unpack('i2', file:read(2))
   -- lens (who knows what that means?)
   H.lens = struct.unpack('i2', file:read(2))
   -- nd1, nd2 (who knows what that means?)
   -- if idtype = 1 then nd1 = axis (1,2,3 -> X,Y,Z)
   H.nd1 = struct.unpack('i2', file:read(2))
   H.nd2 = struct.unpack('i2', file:read(2))
   -- vd1, vd2 (who knows what that means?)
   -- vd1 = 100. * tilt increment
   -- vd2 = 100. * starting angle
   H.vd1 = struct.unpack('i2', file:read(2))
   H.vd2 = struct.unpack('i2', file:read(2))
   -- Image tilt angles 0,1,2 = original 3,4,5 = current
   H.tiltAngles = {}
   for i=1,6 do
      local tiltAngle = struct.unpack('f', file:read(4))
      table.insert(H.tiltAngles, tiltAngle)
   end
   -- Image origin
   H.xorg = struct.unpack('f', file:read(4))
   H.yorg = struct.unpack('f', file:read(4))
   H.zorg = struct.unpack('f', file:read(4))
   -- Image cmap (Another IMOD stamp?)
   H.cmap = struct.unpack('c4', file:read(4))
   
   -- Image Endianness
   H.stamp = struct.unpack('c4', file:read(4))
   -- The Root Mean Square deviation of densities from mean density
   H.rms = struct.unpack('f', file:read(4))
   -- The number of labels in the header
   H.nlabl = struct.unpack('i4', file:read(4))
   H.labels = {}
   for i=1, H.nlabl do
      local label = struct.unpack('c80', file:read(80))
      table.insert(H.labels, label)
   end
   file:close(); file = nil
   return H
end
--[[===========================================================================#
#                               imodShortToReal                                #
#------------------------------------------------------------------------------#
# A function that handles Biol3D weird way of putting information in the ext-  #
# ended header. As can be seen here:                                           #
# http://bio3d.colorado.edu/imod/doc/mrc_format.txt                            #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: s1 <short>                                                #
#            arg[2]: s2 <short>                                                #
#===========================================================================--]]
local function imodShortToReal(s1, s2)
   local signS1 = s1 < 0 and -1 or 1
   local signS2 = s2 < 0 and -1 or 1
   s1 = math.abs(s1)
   s2 = math.abs(s2)
   local value = signS1 * ((256 * s1) + (s2 % 256)) * 2 ^ (signS2 * (s2 / 256))
   return value
end
--[[===========================================================================#
#                                  checkIMOD                                   #
#------------------------------------------------------------------------------#
# A function that reads the nint and the nreal in the header and checks to see #
# if the file comes from IMOD                                                  #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: nint  <integer>                                           #
#            arg[2]: nreal <integer>                                           #
#===========================================================================--]]
function MRCIOLib.checkIMOD(nint, nreal)
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
      return false
   end
end
--[[===========================================================================#
#                              getExtendedHeader                               #
#------------------------------------------------------------------------------#
# A function that reads the extended header for a given section                #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: image stack file <filename:string>                        #
#===========================================================================--]]
function MRCIOLib.getExtendedHeader(inputFile)
   local extended_header = {}
   local file   = assert(io.open(inputFile, 'rb'))
   local header = MRCIOLib.getHeader(inputFile)
   local nz     = header.nz
   local Next   = header.Next
   local nint   = header.nint
   local nreal  = header.nreal
   local isIMOD = MRCIOLib.checkIMOD(nint, nreal)
   header = nil -- clear some space
   if Next == 0 then
      return extended_header{}
   end
   for i = 1, nz do
      local extended_header_section = {}
      if not isIMOD then
         local jump = 1024 + (128 * (i - 1))
         file:seek('set', jump)
         -- alpha and beta tilt in degrees
         extended_header_section.a_tilt = struct.unpack('f', file:read(4))
         extended_header_section.b_tilt = struct.unpack('f', file:read(4))
         -- stage positions. Normally in SI units but maybe in micrometers
         extended_header_section.x_stage = struct.unpack('f', file:read(4))
         extended_header_section.y_stage = struct.unpack('f', file:read(4))
         extended_header_section.z_stage = struct.unpack('f', file:read(4))
         -- image shift. In the same units as stage positions
         extended_header_section.x_shift = struct.unpack('f', file:read(4))
         extended_header_section.y_shift = struct.unpack('f', file:read(4))
         -- image defocus as read from scope. In same units as stage positions
         extended_header_section.defocus = struct.unpack('f', file:read(4))
         -- image exposure time in seconds
         extended_header_section.exp_time = struct.unpack('f', file:read(4))
         -- mean value of image
         extended_header_section.mean_int = struct.unpack('f', file:read(4))
         -- image tilt axis offset: The orientation of the tilt axis in the image
         -- in degrees. Vertical to the top is 0 Angstroms, the direction of 
         -- positive rotation is anti-clockwise.
         extended_header_section.tilt_axis = struct.unpack('f', file:read(4))
         -- pixel size. Check units may be SI or micrometers 
         extended_header_section.pixel_size = struct.unpack('f', file:read(4))
         -- magnification used
         extended_header_section.magnification = struct.unpack('f', file:read(4))
         -- high-tension, in SI units (volts)
         extended_header_section.ht = struct.unpack('f', file:read(4))
         -- binning of the CCD acquisition
         extended_header_section.binning = struct.unpack('f', file:read(4))
         -- intended application defocus, should be in SI units (meters)
         extended_header_section.appliedDefocus = struct.unpack('f', file:read(4))
      elseif isIMOD then
         local jump = 1024 + nint * (i - 1)
         file:seek('set', jump)
         if bit32.btest(nreal, 1) then
         extended_header_section.a_tilt = struct.unpack('i2', file:read(2)) / 100
         end
         if bit32.btest(nreal, 2) then
            -- Montage piece coordinates
            extended_header_section.mon = {}
            for i = 1, 3 do
               local monCoord = struct.unpack('i2', file:read(2))
               table.insert(extended_header_section.mon, monCoord)
            end
         end
         if bit32.btest(nreal, 4) then
            extended_header_section.x_stage = struct.unpack('i2', file:read(2)) / 25
            extended_header_section.y_stage = struct.unpack('i2', file:read(2)) / 25
         end
         if bit32.btest(nreal, 8) then
            extended_header_section.magnification = struct.unpack('i2', file:read(2)) * 100
         end
         if bit32.btest(nreal, 16) then
            extended_header_section.intensity = struct.unpack('i2', file:read(2)) / 25000
         end
         if bit32.btest(nreal, 32) then
            -- Exposure dose in e-/A^2
            extended_header_section.exp_dose = struct.unpack('f', file:read(4))
         end
      else
         io.stderr:write('Error: I do not know this type of file.')
          return 1
      end
      extended_header[i] = extended_header_section
   end
   file:close(); file = nil
   return extended_header
end
--[[===========================================================================#
#                                   getTilts                                   #
#------------------------------------------------------------------------------#
# This function writes the tilt angles out to stdout or a file, and this file  #
# is used by many IMOD commands.                                               #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: Image stack filename <filename.st>                        #
#            arg[2]: [optional] Output file <filename.rawtlt>                  #
#===========================================================================--]]
function MRCIOLib.getTilts(inputFile, outputFile)
   local mdoc            = inputFile .. '.mdoc'
   local header          = MRCIOLib.getHeader(inputFile)
   local extended_header = MRCIOLib.getExtendedHeader(inputFile)
   local nz              = header.nz
   local file = io.stdout
   header = nil
   if outputFile then
      file = io.open(outputFile, 'w')
   end
   
   if extended_header[1].a_tilt then
      for i = 1, nz do
         if not extended_header[i].a_tilt then
            error(string.format(
               'Error: No tilt angle for %s section %d.\n', inputFile, i), 0)
         else
            file:write(string.format('% 6.2f\n', extended_header[i].a_tilt))
         end
      end
   else
      mdoc_file = io.open(mdoc, 'r')
      if mdoc_file then
         for line in mdoc_file:lines('*l') do
            local tilt_angle = string.match(line, 'TiltAngle%s=%s(-?%d+%.%d+)')
            tilt_angle = tonumber(tilt_angle)
            if tilt_angle then
               file:write(string.format('% 6.2f\n', tilt_angle))
            end
         end
         mdoc_file:close()
      else
         error(string.format(
         'Error: No tilt angles found in %s\'s extend header\n', inputFile), 0)
      end
   end
   file:close()
end
--[[===========================================================================#
#                                  setHeader                                   #
#------------------------------------------------------------------------------#
# This function writes an MRC file using existing header tables                #
#------------------------------------------------------------------------------#
# Arguments: arg[1] = Input  Image Stack <MRC file>                            #
#            arg[2] = Output Image Stack <MRC file>                            #
#            arg[3] = Header <table>                                           #
#            arg[4] = Extendend Header <table>                                 #
#===========================================================================--]]
function MRCIOLib.setHeader(inputFile, outputFile, header, extended_header)
   local oF     = assert(io.open(outputFile, 'wb'))
   local isIMOD = MRCIOLib.checkIMOD(header.nint, header.nreal)
   oF:write(struct.pack('i4', header.nx))
   oF:write(struct.pack('i4', header.ny))
   oF:write(struct.pack('i4', header.nz))
   oF:write(struct.pack('i4', header.mode))
   oF:write(struct.pack('i4', header.nxstart))
   oF:write(struct.pack('i4', header.nystart))
   oF:write(struct.pack('i4', header.nzstart))
   oF:write(struct.pack('i4', header.mx))
   oF:write(struct.pack('i4', header.my))
   oF:write(struct.pack('i4', header.mz))
   oF:write(struct.pack('f',  header.xlen))
   oF:write(struct.pack('f',  header.ylen))
   oF:write(struct.pack('f',  header.zlen))
   oF:write(struct.pack('f',  header.alpha))
   oF:write(struct.pack('f',  header.beta))
   oF:write(struct.pack('f',  header.gamma))
   oF:write(struct.pack('i4', header.mapc))
   oF:write(struct.pack('i4', header.mapr))
   oF:write(struct.pack('i4', header.maps))
   oF:write(struct.pack('f',  header.amin))
   oF:write(struct.pack('f',  header.amax))
   oF:write(struct.pack('f',  header.amean))
   oF:write(struct.pack('i2', header.ispg))
   oF:write(struct.pack('i2', header.nsymbt))
   oF:write(struct.pack('i4', header.Next))
   oF:write(struct.pack('i2', header.dvid))
   oF:write(struct.pack('i2', header.extra))
   oF:write(struct.pack('i2', header.nint))
   oF:write(struct.pack('i2', header.nreal))
   oF:write(struct.pack('i2', header.sub))
   oF:write(struct.pack('i2', header.zfac))
   oF:write(struct.pack('f',  header,min2))
   oF:write(struct.pack('f',  header.max2))
   oF:write(struct.pack('f',  header.min3))
   oF:write(struct.pack('f',  header.max3))
   oF:write(struct.pack('i4', header.imodStamp))
   oF:write(struct.pack('i4', header.imodFlags))
   oF:write(struct.pack('i2', header.idtype))
   oF:write(struct.pack('i2', header.lens))
   oF:write(struct.pack('i2', header.nd1))
   oF:write(struct.pack('i2', header.nd2))
   oF:write(struct.pack('i2', header.vd1))
   oF:write(struct.pack('i2', header.vd2))
   for i=1,6 do
      oF:write(struct.pack('f', header.tiltAngles[1]))
   end
   oF:write(struct.pack('f',  header.xorg))
   oF:write(struct.pack('f',  header.yorg))
   oF:write(struct.pack('f',  header.zorg))
   oF:write(struct.pack('c4', header.cmap))
   oF:write(struct.pack('c4', header.stamp))
   oF:write(struct.pack('f',  header.rms))
   oF:write(struct.pack('i4', header.nlabl))
   for i = 1, 10 do                           
      if header.labels[i] then
         oF:write(struct.pack('c80', header.labels[i] .. string.rep(' ', 80)))
      else
         oF:write(struct.pack('c80', string.rep(' ', 80)))
      end
   end
   if isIMOD then
      local extended_header_extra = header.Next - (header.nz * header.nint)
      for i = 1, header.nz do
         if extended_header[i].a_tilt then
            oF:write(struct.pack('i2', extended_header[i].a_tilt * 100))
         end
         if extended_header[i].mon then
            for j = 1, 3 do
               oF:write(struct.pack('i2', extended_header[i].mon[j]))
            end
         end
         if extended_header[i].xstage then
            oF:write(struct.pack('i2', extended_header[i].x_stage * 25))
            oF:write(struct.pack('i2', extended_header[i].y_stage * 25))
         end
         if extended_header[i].magnification then
            oF:write(struct.pack('i2', extended_header[i].magnification * 100))
         end
         if extended_header[i].intensity then
            oF:write(struct.pack('i2', extended_header[i].intensity * 25000))
         end
         if extended_header[i].exp_dose then
            oF:write(struct.pack('f', extended_header[i].exp_dose))
         end
         if extended_header_extra > 1 and extended_header_extra % 2 == 0 then
            for i = 1, (extended_header_extra / 2) do
               oF:write(struct.pack('i2', 0))
            end
         end
      end
   else
      for i = 1, 1024 do
         if extended_header[i] then
            oF:write(struct.pack('f', extended_header[i].a_tilt))
            oF:write(struct.pack('f', extended_header[i].b_tilt))
            oF:write(struct.pack('f', extended_header[i].x_stage))
            oF:write(struct.pack('f', extended_header[i].y_stage))
            oF:write(struct.pack('f', extended_header[i].z_stage))
            oF:write(struct.pack('f', extended_header[i].x_shift))
            oF:write(struct.pack('f', extended_header[i].y_shift))
            oF:write(struct.pack('f', extended_header[i].defocus))
            oF:write(struct.pack('f', extended_header[i].exp_time))
            oF:write(struct.pack('f', extended_header[i].mean_int))
            oF:write(struct.pack('f', extended_header[i].tilt_axis))
            oF:write(struct.pack('f', extended_header[i].pixel_size))
            oF:write(struct.pack('f', extended_header[i].magnification))
            oF:write(struct.pack('f', extended_header[i].ht))
            oF:write(struct.pack('f', extended_header[i].binning))
            oF:write(struct.pack('f', extended_header[i].appliedDefocus))
            for j = 1, 16 do
               oF:write(struct.pack('f', 0))
            end
         else
            for j = 1, 32 do
               oF:write(struct.pack('f', 0))
            end
         end
      end
   end
   local file     = io.open(inputFile, 'rb')
   local jump     = 1024 + header.Next
   local filesize = header.nx * header.ny * header.nz
   local size     = 1
   if header.mode == 0 then
      size     = 1
      filesize = filesize * size
   elseif header.mode == 1 then
      size     = 2
      filesize = filesize * size
   elseif header.mode == 2 then
      size     = 4
      filesize = filesize * size
   elseif header.mode == 6 then
      size     = 2
      filesize = filesize * size
   end
   file:seek('set', jump)
   oF:write(file:read(filesize))
   file:close()
   oF:close()
end
--[[===========================================================================#
#                                 writeHeader                                  #
#------------------------------------------------------------------------------#
# This function rewrites a stack file to alter, or more usefully fill in miss- #
# ing information, if the information is lost for some reason.                 #
#------------------------------------------------------------------------------#
# Arguments: arg[1] = Input  Image Stack <MRC file>                            #
#            arg[2] = Output Image Stack <MRC file>                            #
#            arg[3] = Option table <options from yago>                         #
#===========================================================================--]]
function MRCIOLib.setHeader(inputFile, outputFile, options)
   local header          = MRCIOLib.getHeader(inputFile)
   local extended_header = MRCIOLib.getExtendedHeader(inputFile)
   local isIMOD          = MRCIOLib.checkIMOD(header.nint, header.nreal)
   local nz              = header.nz
   if options.a_ then header.nx = options.a_ end
   if options.b_ then header.ny = options.b_ end
   if options.c_ then header.nz = options.c_ end
   if options.d_ then header.mode = options.d_ end
   if options.e_ then header.nxstart = options.e_ end
   if options.f_ then header.nystart = options.f_ end
   if options.g_ then header.nzstart = options.g_ end
   if options.i_ then header.mx = options.i_ end
   if options.j_ then header.my = options.j_ end
   if options.k_ then header.mz = options.k_ end
   if options.l_ then header.xlen = options.l_ end
   if options.m_ then header.ylen = options.m_ end
   if options.n_ then header.zlen = options.n_ end
   if options.o_ then header.amin  = options.o_ end
   if options.p_ then header.amax  = options.p_ end
   if options.q_ then header.amean = options.q_ end
   if options.r_ then header.tiltAngles[4] = options.r_ end
   if options.s_ then header.tiltAngles[5] = options.s_ end
   if options.t_ then header.tiltAngles[6] = options.t_ end
   if options.u_ then header.xorg = options.u_ end
   if options.v_ then header.yorg = options.v_ end
   if options.w_ then header.zorg = options.w_ end
   if options.x_ then header.rms = options.x_ end
   if options.y_ then
      local label_index = 2
      if options.z_ then label_index = tonumber(options.z_) end
      if tonumber(header.nlabl) < 10 then
         table.insert(header.labels, label_index, options.y_)
         header.nlabl = header.nlabl + 1
      elseif tonumber(header.nlabl) == 10 then
         table.insert(header.labels, label_index, options.y_)
         table.remove(header.labels)
      end
   end
   for i = 1, nz do
      if not isIMOD then
         if options.A_ and options.B_ then
            if tonumber(options.A_) > 0 then
               extended_header[i].a_tilt = tonumber(options.A_) - 
                  (i - 1) * options.B_
            else
               extended_header[i].a_tilt = tonumber(options.A_) * -1 - 
                  (i - 1) * options.B_
            end
         end
         if options.C_ then extended_header.defocus = options.C_ end
         if options.D_ then extended_header.exp_time = options.D_ end
         if options.E_ then extended_header.tilt_axis = options.E_ end
         if options.F_ then extended_header.pixel_size = options.F_ end
         if options.G_ then extended_header.magnification = options.G_ end
         if options.I_ then extended_header.ht = options.I_ end
         if options.J_ then extended_header.binning = options.J_ end
         if options.K_ then extended_header.appliedDefocus = options.K_ end
      else
         if options.A_ and options.B_ then
            if tonumber(options.A_) > 0 then
               extended_header[i].a_tilt = tonumber(options.A_) - 
                  (i - 1) * options.B_
            else
               extended_header[i].a_tilt = tonumber(options.A_) * -1 -
                  (i - 1) * options.B_
            end
         end
         if options.G_ then extended_header[i].magnification = options.G_ end
         if options.L_ then extended_header[i].intensity = options.L_ end
         if options.M_ then extended_header[i].exp_dose = options.M_ end
      end
   end
   MRCIOLib.setHeader(inputFile, outputFile, header, extended_header)
end
--[[===========================================================================#
#                                getReqdHeader                                 #
#------------------------------------------------------------------------------#
# This function returns a table with a mix of data from the standard and the   #
# extended MRC header as is required for reconstruction.                       #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: Image stack file <filename:string>                        #
#            arg[2]: Fiducial size in nanometers <integer>                     #
#===========================================================================--]]
function MRCIOLib.getReqdHeader(filename, fidNm)
   local   H = MRCIOLib.getHeader(filename)
   local  eH = MRCIOLib.getExtendedHeader(filename, 1)
   H.fType = string.sub(H.labels[1], 1, 3)
   if H.fType == 'Fei' then
      H.tilt_axis  = -1 * eH.tilt_axis
      H.pixel_size = 1e9 * eH.pixel_size
   elseif H.fType == 'TF3' then
      H.tilt_axis  = eH.tilt_axis
      H.pixel_size = eH.pixel_size / 10
   elseif H.fType == 'Ser' then
      for match in string.gmatch(H.labels[2], '[%-%d%.]+') do
         H.tilt_axis = tonumber(match)
         break
      end
      H.pixel_size = (H.xlen / H.mx) / 10
   else
      error(string.format(
         'Error: I do no know how to handle image stack %s.\n', filename))
   end
   -- Calculate the Fiducial size in pixels
   H.fidPx = math.floor((fidNm / H.pixel_size) + 0.5)
   -- Find the section at 0 degrees to split alignments
   for i = 1, H.nz do
      local tiltH = MRCIOLib.getExtendedHeader(filename, i)
      if math.floor(tiltH.a_tilt) == 0 then
         H.split_angle = i
      end
   end
   if not H.split_angle then
      error('Error: Could not find a zero degree tilt for %s.\n', filename)
   end
   return H
end
return MRCIOLib
