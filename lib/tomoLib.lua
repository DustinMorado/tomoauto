local startDir = os.getenv('TOMOAUTOROOT')
local struct = assert(require 'struct')

--[[==========================================================================#
#                              Local Functions                                #
#==========================================================================--]]
local tomoLib = {}
--[[==========================================================================#
#                                  dispHelp                                   #
#-----------------------------------------------------------------------------#
# A function that displays the usage and options of tomoAuto                  #
#==========================================================================--]]
function tomoLib.dispHelp()
   io.write(
   [[\nUsage: \n\z
   tomoAuto [-c -d <int> -g -h -L <file> -p <int> -z <int>] <file.st> <fid>\n\z
   Automates the alignment of tilt series and the reconstruction of\z
   these series into 3D tomograms.\n\n\z
   -c, --CTF \t Applies CTF correction to the aligned stack\n\z
   -d, --defocus \t Uses this as estimated defocus for ctfplotter\n\z
   -g, --GPU \t Uses GPGPU methods to speed up the reconstruction\n\z
   -h, --help \t Prints this information and exits\n\z
   -L, --config \t Sources a local config file\n\z
   -p, --parallel \t Uses <int> processors to speed up tilt\n\z
   -z, --thickness \t Create a tomogram with <int> thickness\n]])
   return
end
--[[==========================================================================#
#                             checkFreeSpace                                  #
#-----------------------------------------------------------------------------#
# A function to check that there is enough free space to successfully run     #
# some of the more data heavy IMOD routines                                   #
#==========================================================================--]]
function tomoLib.checkFreeSpace(Directory)
	local file = assert(io.popen('df -h ' .. Directory, 'r'))
	local space = string.sub(string.match(file:read('*a'), '.%d%%'), 1, -2)
   space = tonumber(space)
	file:close()
	return assert(space <= 98,
                 'Error: Disk usage is at or above 98% please make more space')
end
--[[==========================================================================#
#                               runCheck                                      #
#-----------------------------------------------------------------------------#
# A function to run shell commands and check that they run successfully if    #
# the routine returns a non-zero exit code an error is thrown                 #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = shell command to be run <'string'>                      #
#==========================================================================--]]
function tomoLib.runCheck(functionString)
	local success,exit,signal = os.execute(functionString .. ' 2> /dev/null')
   if not success then
      io.stderr:write('Error running ' .. functionString)
   end
end
--[[==========================================================================#
#                                 findITP                                     #
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
function tomoLib.findITP(inputFile, fidSize)
	local file = assert(io.open(inputFile, 'rb'))
	local nx = struct.unpack('i4', file:read(4))
	local ny = struct.unpack('i4', file:read(4))
   local nz = struct.unpack('i4', file:read(4))
   file:seek('set', 224)
	local feiLabel = struct.unpack('c3', file:read(3))
   file:seek('set',1064)
	local tiltAxis = struct.unpack('f', file:read(4))
	local pixelSize = struct.unpack('f', file:read(4))

	if feiLabel == 'Fei' then
		pixelSize = pixelSize * 1e9
      tiltAxis = tiltAxis * -1
	else
		pixelSize = pixelSize / 10
	end

	local fidPix = math.floor((fidSize / pixelSize) + 0.5)
	file:close()
	return nx, ny, nz, feiLabel, tiltAxis, pixelSize, fidPix
end
--[[==========================================================================#
#                              approximateDefocus                             #
#-----------------------------------------------------------------------------#
# A function that reads the header of the image stack and returns the defocus #
# value. Please be aware that this is solely a good approximation and in many #
# cases can be way off. If so please use the -d option for tomoAuto and       #
# estimate the defocus manually.                                              #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = inputFile <string> the image stack to read              #
#            arg[2] = feiLabel <string> whether or not its an CCD tomo        #
#==========================================================================--]]
function tomoLib.approximateDefocus(inputFile, feiLabel)
   local file = assert(io.open(inputFile, 'rb'))
   local sum = 0
   file:seek('set', 8)
   z = struct.unpack('i4', file:read(4))
   file:seek('set', 1052)
   for i = 1, z do
      sum = sum + struct.unpack('f', file:read(4))
      file:seek('cur', 124)
   end
   file:close(); file = nil
   if feiLabel == 'Fei' then
      sum = sum * 10000
   else
      sum = sum * -1000
   end
   local avg = sum / z
   return string.format('%.2f', avg)
end
--[[==========================================================================#
#                                 checkAlign                                  #
#-----------------------------------------------------------------------------#
# A function that checks the final alignment to make sure that too many high  #
# tilt sections were not cut by newstack or RAPTOR. If more than 10% of the   #
# original sections are missing, we abort the reconstruction                  #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = image filename <string>                                 #
#            arg[2] = number of original sections <integer>                   #
#==========================================================================--]]
function tomoLib.checkAlign(filename, nz)
   local file = assert(io.open(filename .. '.ali', 'rb'))
   file:seek('set', 8)
   local aliNz = struct.unpack('i4', file:read(4))
   file:close()
   local cut = nz - aliNz
   io.write('\nThe number of intial sections is:\t' .. nz)
   io.write('\nThe number of sections cut was:\t' .. cut .. '\n')
   if (aliNz / nz) >= 0.9 then return true else return nil end
end
--[[==========================================================================#
#                                  writeLog                                   #
#-----------------------------------------------------------------------------#
#  A fuction that writes the file tomoAuto.log                                #
#-----------------------------------------------------------------------------#
# Arguments: arg[1] = image filename <string>                                 #
#==========================================================================--]]
function tomoLib.writeLog(filename)
   local log = assert(io.open('tomoAuto.log', 'w'))

   local ccd = io.open('ccderaser.log', 'r')
   if ccd then
      local ccd_ = ccd:read('*a'); ccd:close(); log:write(ccd_ .. '\n')
   end
   
   local txc = io.open('tiltxcorr.log', 'r')
   if txc then
      local txc_ = txc:read('*a'); txc:close(); log:write(txc_ .. '\n')
   end

   local ftg = io.open('xftoxg.log', 'r')
   if ftg then
      local ftg_ = ftg:read('*a'); ftg:close(); log:write(ftg_ .. '\n')
   end

   local ns = io.open('newstack.log', 'r')
   if ns then
      local ns_ = ns:read('*a'); ns:close(); log:write(ns_ .. '\n')
   end

   local r1 = io.open('raptor1/align/'
                                  .. filename .. '_RAPTOR.log', 'r')
   if r1 then
      local r1_ = r1:read('*a'); r1:close(); log:write(r1_ .. '\n')
   end

   local r2 = io.open('raptor2/align/'
                                  .. filename .. '_RAPTOR.log', 'r')
   if r2 then
      local r2_ = r2:read('*a'); r2:close(); log:write(r2_ .. '\n')
   end

   local m2p = io.open('model2point.log', 'r')
   if m2p then
      local m2p_= m2p:read('*a'); m2p:close(); log:write(m2p_ .. '\n')
   end

   local p2m = io.open('point2model.log', 'r')
   if p2m then
      local p2m_= p2m:read('*a'); p2m:close(); log:write(p2m_ .. '\n')
   end

   local ctfp = io.open('ctfplotter.log', 'r')
   if ctfp then
      local ctfp_ = ctfp:read('*a'); ctfp:close(); log:write(ctfp_ .. '\n')
   end

   local ctfc = io.open('ctfcorrection.log', 'r')
   if ctfc then 
      local ctfc_ = ctfc:read('*a'); ctfc:close(); log:write(ctfc_ .. '\n')
   end

   local gold = io.open('gold_ccderaser.log', 'r')
   if gold then
      local gold_ = gold:read('*a'); gold:close(); log:write(gold_ .. '\n')
   end

   local tilt = io.open('tilt.log', 'r')
   if tilt then
      local tilt_ = tilt:read('*a'); tilt:close(); log:write(tilt_ .. '\n')
   end

   local nad = io.open('nad_eed_3d.log', 'r')
   if nad then
      local nad_ = nad:read('*a'); nad:close(); log:write(nad_ .. '\n')
   end

   log:close()
end

--[[===========================================================================#
#                                  stackSeven                                  #
#------------------------------------------------------------------------------#
# A command that imitates the median 7 average filter                          #
#------------------------------------------------------------------------------#
# Arguments: arg[1] = image filename <string>                                  #
#===========================================================================--]]
function tomoLib.stackSeven(filename)
   local file = assert(io.open('tilt.com', 'r'))
   local contents = file:read('*a')
   file:close(); file = nil
   local thick = contents:match('THICKNESS%s(%d+)')
   thick = thick / 4

   for i = 1, thick do
      if i < 4 then
         sString = 'xyzproj -input ' .. filename .. '.bin4.nad -output '
            .. filename .. '.avg_' .. string.format("%03d", i)
            .. ' -zminmax "1 7" -axis Y'
         tomoLib.runCheck(sString)
      elseif i > thick - 3 then
         eString = 'xyzproj -inpu ' .. filename .. '.bin4.nad -output '
            .. filename .. '.avg_' .. string.format("03%d", i) 
            .. ' -zminmax "' .. thick - 6 .. ' ' .. thick
            .. '" -axis Y'
         tomoLib.runCheck(eString)
      else
         mString = 'xyzproj -input ' .. filename .. '.bin4.nad -output '
            .. filename .. '.avg_' .. string.format("%03d", i)
            .. ' -zminmax "' .. i - 3 .. ' ' .. i + 3 .. '" -axis Y'
         tomoLib.runCheck(mString)
      end
   end

   tomoLib.runCheck('newstack ' .. filename .. '.avg_* ' 
      .. filename .. '.bin4.nad7')
   tomoLib.runCheck('rm -f ' .. filename .. '.avg_*')
end
return tomoLib
