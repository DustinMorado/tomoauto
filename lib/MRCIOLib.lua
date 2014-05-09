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
#            arg[2] = fiducial diameter in nanometers <integer>               #
#==========================================================================--]]
function MRCIOLib.getHeader(inputFile)
   local H = {}
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
   H.alpha   = struct.unpack('f', file:read(4))
   H.beta    = struct.unpack('f', file:read(4))
   H.gamma   = struct.unpack('f', file:read(4))

   -- Axis Mappings (Not used, should be 1,2,3 -> X,Y,Z)
   H.mapc = struct.unpack('i4', file:read(4)) -- map columns
   H.mapr = struct.unpack('i4', file:read(4)) -- map rows
   H.maps = struct.unpack('i4', file:read(4)) -- map sections

   -- Image data value stats
   H.amin    = struct.unpack('f', file:read(4)) -- min pixel value
   H.amax    = struct.unpack('f', file:read(4)) -- max pixel value
   H.amean   = struct.unpack('f', file:read(4)) -- mean pixel value

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
   H.nint    = struct.unpack('i2', file:read(2))
   H.nreal   = struct.unpack('i2', file:read(2))

   -- These are a bunch of entries that aren't used
   H.sub     = struct.unpack('i2', file:read(2))
   H.zfac    = struct.unpack('i2', file:read(2))
   H.min2    = struct.unpack('f', file:read(4))
   H.max2    = struct.unpack('f', file:read(4))
   H.min3    = struct.unpack('f', file:read(4))
   H.max3    = struct.unpack('f', file:read(4))

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
#                              getExtendedHeader                               #
#------------------------------------------------------------------------------#
# A function that reads the extended header for a given section                #
#------------------------------------------------------------------------------#
# Arguments: arg[1]: image stack file <filename:string>                        #
#            arg[2]: section of which to read <integer>                        #
#===========================================================================--]]
function MRCIOLib.getExtendedHeader(inputFile, section)
   local eH   = {}
   local file        = assert(io.open(inputFile, 'rb'))
   local H      = MRCIOLib.getHeader(inputFile)
   local nz          = H.nz
   local isImod      = H.imodStamp == 1146047817 and true or false
   local nint        = H.nint
   local nreal       = H.nreal

   H = nil -- clear some space

   -- Check that our section is reasonable
   assert(section >= 1, 'Error: Asking for section less than one!')
   assert(section <= nz, 'Error: Asking for section that does not exist!')
   
   local jump = 1024
   if not isImod then
      jump = jump + (128 * (section - 1))
      file:seek('set', jump)
      -- alpha and beta tilt in degrees
      eH.a_tilt  = struct.unpack('f', file:read(4))
      eH.b_tilt  = struct.unpack('f', file:read(4))

      -- stage positions. Normally in SI units but maybe in micrometers
      eH.x_stage = struct.unpack('f', file:read(4))
      eH.y_stage = struct.unpack('f', file:read(4))
      eH.z_stage = struct.unpack('f', file:read(4))

      -- image shift. In the same units as stage positions
      eH.x_shift = struct.unpack('f', file:read(4))
      eH.y_shift = struct.unpack('f', file:read(4))

      -- image defocus as read from scope. In same units as stage positions
      eH.defocus = struct.unpack('f', file:read(4))

      -- image exposure time in seconds
      eH.exp_time = struct.unpack('f', file:read(4))

      -- mean value of image
      eH.mean_int = struct.unpack('f', file:read(4))

      -- image tilt axis offset: The orientation of the tilt axis in the image
      -- in degrees. Vertical to the top is 0 Angstroms, the direction of 
      -- positive rotation is anti-clockwise.
      eH.tilt_axis = struct.unpack('f', file:read(4))

      -- pixel size. Check units may be SI or micrometers 
      eH.pixel_size = struct.unpack('f', file:read(4))

      -- magnification used
      eH.magnification = struct.unpack('f', file:read(4))

      -- high-tension, in SI units (volts)
      eH.ht = struct.unpack('f', file:read(4))

      -- binning of the CCD acquisition
      eH.binning = struct.unpack('f', file:read(4))

      -- intended application defocus, should be in SI units (meters)
      eH.appliedDefocus = struct.unpack('f', file:read(4))
   else
      jump = jump + (nint * (section -1))
      file:seek('set', jump)
      local isExp = (nreal - 32) >= 0 and true or false
      if isExp then nreal = nreal - 32 end

      local isInt = (nreal - 16) >= 0 and true or false
      if isInt then nreal = nreal - 16 end

      local isMag = (nreal - 8) >= 0 and true or false
      if isMag then nreal = nreal - 8 end

      local isStg = (nreal - 4) >= 0 and true or false
      if isStg then nreal = nreal - 4 end

      local isMon = (nreal - 2) >= 0 and true or false
      if isMon then nreal = nreal - 2 end

      local isTlt = (nreal - 1) >= 0 and true or false
      if isTlt then nreal = nreal - 1 end

      if nreal ~= 0 then
         io.stderr:write('I have not seen this kind of IMOD extended header \
         please contact the developer!')
      end
      
      if isTlt then
         eH.a_tilt = struct.unpack('h', file:read(2)) / 100
      end
      
      if isMon then
         eH.mon = {}
         for i = 1, 3 do
            local monCoord = struct.unpack('h', file:read(2))
            table.insert(eH.mon, monCoord)
         end
      end

      if isStg then
         eH.x_stage = struct.unpack('h', file:read(2)) / 25
         eH.y_stage = struct.unpack('h', file:read(2)) / 25
      end

      if isMag then
         eH.magnification = struct.unpack('h', file:read(2)) * 100
      end

      if isInt then
         eH.intensity = struct.unpack('h', file:read(2)) / 25000
      end

      if isExp then
         eH.exposure = struct.unpack('f', file:read(4))
      end
   end
   file:close(); file = nil
   return eH
end

function MRCIOLib.getReqdHeader(filename, fidNm)
   local rqH = {}
   local   H = MRCIOLib.getHeader(filename)
   local  eH = MRCIOLib.getExtendedHeader(filename, 1)
   
   rqH.fType = string.sub(H.labels[1], 1, 3)
   rqH.nx, rqH.ny, rqH.nz = H.nx, H.ny, H.nz

   if rqH.fType == 'Fei' then
      rqH.tilt_axis  = -1 * eH.tilt_axis
      rqH.pixel_size = 1e9 * eH.pixel_size
   elseif rqH.fType == 'TF3' then
      rqH.tilt_axis  = eH.tilt_axis
      rqH.pixel_size = eH.pixel_size / 10
   elseif rqH.fType == 'Ser' then
      for match in string.gmatch(H.labels[2], '[%-%d%.]+') do
         rqH.tilt_axis = tonumber(match)
         break
      end
      rqH.pixel_size = (H.xlen / H.mx) / 10
   else
      io.stderr:write('Error: I do no know how to handle this type of stack\n')
      return false
   end

   rqH.fidPx = math.floor((fidNm / rqH.pixel_size) + 0.5)
   H, eH = nil, nil
   return rqH
end

return MRCIOLib
