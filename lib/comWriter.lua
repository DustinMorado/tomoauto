--[[==========================================================================#
#                               comWriter.lua                                 #
#-----------------------------------------------------------------------------#
# This is a lua module for tomoAuto responsible for writing all of the        #
# command (COM) files for the various programs in IMOD.                       #
#-----------------------------------------------------------------------------#
# Author: Dustin Morado                                                       #
# Date: 02/28/2014                                                            #
# Contact: dustin.morado@uth.tmc.edu                                          #
#==========================================================================--]]

local comWriter = {}
tomoAutoRoot = os.getenv('TOMOAUTOROOT')
globalConfig = assert(loadfile(tomoAutoRoot .. '/lib/globalConfig.lua'))
globalConfig()
localConfig = loadfile('localConfig.lua')
if localConfig then localConfig() end

local function writeCcderaserCom(inputFile)
	local comName = 'ccderaser.com'
	local filename = string.sub(inputFile, 1, -4)
	local file=assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN CCDERASER\n')
	file:write('####CreatedVersion#### 3.7.2\n')
	file:write('$ccderaser -StandardInput\n')
	file:write('InputFile ' .. inputFile .. '\n')
	file:write('OutputFile ' .. filename .. '_fixed.st\n')
	file:write('PointModel ' .. filename .. '_peak.mod\n')
	file:write('FindPeaks\n')
	file:write('PeakCriterion ' .. ccderaserPeakCriterion .. '\n')
	file:write('DiffCriterion ' .. ccderaserDiffCriterion .. '\n')
	file:write('GrowCriterion ' .. ccderaserGrowCriterion .. '\n')
	file:write('ScanCriterion ' .. ccderaserScanCriterion .. '\n')
	file:write('MaximumRadius ' .. ccderaserMaximumRadius .. '\n')
	file:write('AnnulusWidth ' .. ccderaserAnnulusWidth .. '\n')
	file:write('XYScanSize ' .. ccderaserXYScanSize .. '\n')
	file:write('EdgeExclusionWidth ' .. ccderaserEdgeExclusionWidth .. '\n')
	file:write('BorderSize ' .. ccderaserBorderSize .. '\n')
	file:write('PolynomialOrder ' .. ccderaserPolynomialOrder .. '\n')
	file:close()
end

local function writeTiltXCorrCom(inputFile, tiltAxis)
	local comName = 'tiltxcorr.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN TILTXCORR\n')
	file:write('####CreatedVersion#### 3.4.4\n')
	file:write('$tiltxcorr -StandardInput\n')
	file:write('InputFile ' .. inputFile .. '\n')
	file:write('OutputFile ' .. filename .. '.prexf\n')
	file:write('TiltFile ' .. filename .. '.rawtlt\n')
	file:write('RotationAngle ' .. tiltAxis .. '\n')
	file:write('AngleOffset ' .. tiltxcorrAngleOffset .. '\n')
	file:write('FilterRadius2 ' .. tiltxcorrFilterRadius2 .. '\n')
	file:write('FilterSigma1 ' .. tiltxcorrFilterSigma1 .. '\n')
	file:write('FilterSigma2 ' .. tiltxcorrFilterSigma2 .. '\n')
	if tiltxcorrExcludeCentralPeak then file:write('ExcludeCentralPeak\n') end
	if tiltxcorrBordersInXandY_use then
      file:write('BordersInXandY $tiltxcorrBordersInXandY\n') end
	if tiltxcorrXMinAndMax_use then
      file:write('XMinAndMax $tiltxcorrXMinAndMax\n') end
	if tiltxcorrYMinAndMax_use then
      file:write('YMinAndMax $tiltxcorrYMinAndMax\n') end
	if tiltxcorrPadsInXandY_use then
      file:write('PadsInXandY $tiltxcorrPadsInXandY\n') end
	if tiltxcorrTapersInXandY_use then
      file:write('TapersInXandY $tiltxcorrTapersInXandY\n') end
	if tiltxcorrStartingEndingViews_use then
      file:write('StartingEndingViews $tiltxcorrStartingEndingViews\n') end
	if tiltxcorrCumulativeCorrelation then
      file:write('CumulativeCorrelation\n') end
	if tiltxcorrAbsoluteCosineStretch then
      file:write('AbsoluteCosineStretch\n') end
	if tiltxcorrNoCosineStretch then file:write('NoCosineStretch\n') end
	if tiltxcorrTestOutput then file:write('TestOutput ${base}_test.img\n') end
	file:close()
end

local function writeXfToXgCom(inputFile)
	local comName = 'xftoxg.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN XFTOXG\n')
	file:write('####CreatedVersion#### 1.0.0\n')
	file:write('$xftoxg -StandardInput\n')
	file:write('InputFile ' .. filename .. '.prexf\n')
	file:write('GOutputFile ' .. filename .. '.prexg\n')
	file:write('NumberToFit ' .. xftoxgNumberToFit .. '\n')
	if xftoxgReferenceSection_use then
      file:write('ReferenceSection ' .. xftoxgReferenceSection .. '\n') end
	if xftoxgOrderOfPolynomialFit_use
      then file:write('PolynomialFit ' .. xftoxgPolynomialFit .. '\n') end
	if xftoxgHybridFits_use then
      file:write('HybridFits ' .. xftoxgHybridFits .. '\n') end
	if xftoxgRangeOfAnglesInAverage_use then
      file:write('RangeOfAnglesInAvg ' .. xftoxgRangeOfAnglesInAvg .. '\n') end
	file:close()
end

local function writeNewstackCom(inputFile)
	local comName = 'newstack.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO PRODUCE A PRE-ALIGNED STACK\n')
	file:write('####CreatedVersion#### 1.0.0\n')
	file:write('$newstack -StandardInput\n')
	file:write('InputFile ' .. inputFile .. '\n')
	file:write('OutputFile ' .. filename .. '.preali\n')
	file:write('TransformFile ' .. filename .. '.prexg\n')
	file:write('ModeToOutput ' .. newstackModeToOutput .. '\n')
	file:write('FloatDensities ' .. newstackFloatDensities .. '\n')
	if newstackContrastBlackWhite_use then
      file:write('ContrastBlackWhite ' .. newstackContrastBlackWhite .. '\n')
   end
	if newstackScaleMinAndMax_use then
      file:write('ScaleMinAndMax ' .. newstackScaleMinAndMax .. '\n') end
	file:close()
end

local function writeOpen2ScatterCom(inputFile)
	local comName1 = 'model2point.com'
	local comName2 = 'point2model.com'
	local filename = string.sub(inputFile, 1, -4)
	local file1 = assert(io.open(comName1, 'w'))
	local file2 = assert(io.open(comName2, 'w'))
	file1:write('# THIS IS A COMMAND FILE TO RUN MODEL2POINT\n')
	file1:write('$model2point -StandardInput\n')
	file1:write('InputFile ' .. filename .. '_erase.fid\n')
	file1:write('OutputFile ' .. filename .. '_erase.fid.txt\n')
	if model2pointFloatingPoint_use then file1:write('FloatingPoint\n') end
	if model2pointScaledCoordinates_use then
      file1:write('ScaledCoordinates\n') end
	if model2pointObjectAndContour_use then
      file1:write('ObjectAndContour\n') end
	if model2pointContour_use then file1:write('Contour\n') end
	if model2pointNumberedFromZero_use then
      file1:write('NumberedFromZero\n') end
	file1:close()
	file2:write('# THIS IS A COMMAND FILE TO RUN POINT2MODEL\n')
	file2:write('$point2model -StandardInput\n')
	file2:write('InputFile ' .. filename .. '_erase.fid.txt\n')
	file2:write('OutputFile ' .. filename .. '_erase.scatter.fid\n')
	if point2modelOpenContours_use then file2:write('OpenContours\n') end
	if point2modelScatteredPoints_use then file2:write('ScatteredPoints\n') end
	if point2modelPointsPerContour_use then
      file2:write('PointsPerContour ' .. point2modelPointsPerContour .. '\n')
   end
	if point2modelPlanarContours_use then file2:write('PlanarContours\n') end
	if point2modelNumberedFromZero_use then
      file2:write('NumberedFromZero\n') end
	file2:write('CircleSize ' .. point2modelCircleSize .. '\n') 
	if point2modelSphereRadius_use then
      file2:write('SphereRadius ' .. point2modelSphereRadius .. '\n') end
	file2:write('ColorOfObject ' .. point2modelColorOfObject .. '\n')
	file2:write('ImageForCoordinates ' .. filename .. '.ali\n')
	file2:close()
end

local function writeGoldCom(inputFile)
	local comName = 'gold_ccderaser.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN CCDERASER\n')
	file:write('####CreatedVersion#### 3.7.2\n')
	file:write('$ccderaser -StandardInput\n')
	file:write('InputFile ' .. filename .. '.ali\n')
	file:write('OutputFile ' .. filename .. '_erase.ali\n')
	file:write('ModelFile ' .. filename .. '_erase.fid\n')
	file:write('CircleObjects ' .. gccderaserCircleObjects .. '\n')
	file:write('BetterRadius ' .. gccderaserBetterRadius .. '\n')
	if gccderaserMergePatches then file:write('MergePatches\n') end
	file:write('PolynomialOrder ' .. gccderaserPolynomialOrder .. '\n')
	if gccderaserExcludeAdjacent then file:write('ExcludeAdjacent\n') end
	file:close()
end

local function writeTiltCom(inputFile, nx, ny)
	local comName = 'tilt.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# Command file to run Tilt\n')
	file:write('####CreatedVersion#### 4.0.15\n')
	file:write('$tilt -StandardInput\n')
	file:write('InputProjections ' .. filename .. '.ali\n')
	file:write('OutputFile ' .. filename .. '_full.rec\n')
	file:write('ActionIfGPUFails ' .. tiltActionIfGPUFails .. '\n')
	if tiltAdjustOrigin_use then file:write('AdjustOrigin \n') end
	file:write('FULLIMAGE ' .. nx .. ' ' .. ny .. '\n')
	file:write('IMAGEBINNED 1\n')
	if tiltLOG_use then file:write('LOG ' .. tiltLOG .. '\n') end
	file:write('MODE ' .. tiltMODE .. '\n')
	if tiltOFFSET_use then file:write('OFFSET ' .. tiltOFFSET .. '\n') end
	if tiltPARALLEL_use then file:write('PARALLEL\n') 
	elseif tiltPERPENDICULAR_use then file:write('PERPENDICULAR \n')
	else std.err:write('Error! Please make sure either PARALLEL or PERPENDICULAR'
                      .. ' is chosen in the configuration file (Not Both!)\n') 
   end
	file:write('RADIAL ' .. tiltRADIAL .. '\n')
	file:write('SCALE ' .. tiltSCALE .. '\n')
	file:write('SHIFT ' .. tiltSHIFT .. '\n')
	if tiltSLICE_use then file:write('SLICE ' .. tiltSLICE .. '\n') end
	if tiltSUBSETSTART_use then
      file:write('SUBSETSTART ' .. tiltSUBSETSTART .. '\n') end
	file:write('THICKNESS ' .. tiltTHICKNESS .. '\n')
	file:write('TILTFILE ' .. filename .. '.tlt\n')
	if tiltUseGPU_use then file:write('UseGPU ' .. tiltUseGPU .. '\n') end
	if tiltWIDTH_use then file:write('WIDTH ' .. tiltWIDTH .. '\n') end
	if tiltXAXISTILT_use then
      file:write('XAXISTILT ' .. tiltXAXISTILT .. '\n') end
	if tiltXTILTFILE_use then
      file:write('XTILTFILE ' .. filename .. '.xtilt\n') end
	file:close()
end

local function approximateDefocus(inputFile)
	local struct = assert(require 'struct')
	local file = assert(io.open(inputFile, 'rb'))
	local sum = 0
	local defoci = {}
	file:seek('set', 8)
	z = struct.unpack('i4', file:read(4))
	file:seek('set', 1052)
	for i = 1, z do
		defoci[i] = struct.unpack('f', file:read(4))
		sum = sum + defoci[i]
		file:seek('cur', 124)
	end
	file:close()
	return sum / z
end

local function writeCTFPlotterCom(inputFile, tiltAxis, pixelSize)
	local comName = 'ctfplotter.com'
	local filename = string.sub(inputFile, 1, -4)
	expectDef = approximateDefocus(inputFile)
   expectDef = string.format('%.2f', expectDef * -1000)
	local file = assert(io.open(comName, 'w'))
	file:write('# command file to run ctfplotter\n')
	file:write('####CreatedVersion#### 3.12.20\n')
	file:write('$ctfplotter -StandardInput\n')
	file:write('InputStack ' .. inputFile .. '\n')
	file:write('AngleFile ' .. filename .. '.tlt\n')
   if ctfInvertTiltAngles_use then
      file:write('InvertTiltAngles\n') end
   file:write('OffsetToAdd ' .. ctfOffsetToAdd .. '\n')
	file:write('DefocusFile ' .. filename .. '.defocus\n')
	file:write('AxisAngle ' .. tiltAxis .. '\n')
	file:write('PixelSize ' .. pixelSize .. '\n')
	file:write('ExpectedDefocus ' .. expectDef .. '\n')
	file:write('AngleRange ' .. ctfAngleRange .. '\n')
   file:write('AutoFitRangeAndStep ' .. ctfAutoFitRangeAndStep .. '\n')
	file:write('Voltage ' .. ctfVoltage .. '\n')
	file:write('SphericalAberration ' .. ctfSphericalAberration .. '\n')
	file:write('AmplitudeContrast ' .. ctfAmplitudeContrast .. '\n')
	file:write('DefocusTol ' .. ctfDefocusTol .. '\n')
	file:write('PSResolution ' .. ctfPSResolution .. '\n')
	file:write('TileSize ' .. ctfTileSize .. '\n')
	file:write('LeftDefTol ' .. ctfLeftDefTol .. '\n')
	file:write('RightDefTol ' .. ctfRightDefTol .. '\n')
	file:write('ConfigFile ' .. ctfConfigFile .. '\n')
	file:write('FrequencyRangeToFit ' .. ctfFrequencyRangeToFit .. '\n')
	if ctfVaryExponentInFit_use then file:write('VaryExponentInFit\n') end
	file:write('SaveAndExit\n')
	file:close()
end

local function writeCTFCorrectCom(inputFile,pixelSize)
	local comName = 'ctfcorrection.com'
	local filename = string.sub(inputFile,1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# Command file to run ctfphaseflip\n')
	file:write('####CreatedVersion#### 3.12.20\n')
	file:write('$ctfphaseflip -StandardInput\n')
	file:write('InputStack ' .. filename .. '.ali\n')
	file:write('AngleFile ' .. filename .. '.tlt\n')
   if ctfInvertTiltAngles_use then
      file:write('InvertTiltAngles\n') end
	file:write('OutputFileName ' .. filename .. '_ctfcorr.ali\n')
	file:write('DefocusFile ' .. filename .. '.defocus\n')
	file:write('Voltage ' .. ctfVoltage .. '\n')
	file:write('SphericalAberration ' .. ctfSphericalAberration .. '\n')
	file:write('DefocusTol ' .. ctfDefocusTol .. '\n')
	file:write('PixelSize ' .. pixelSize .. '\n')
	file:write('AmplitudeContrast ' .. ctfAmplitudeContrast .. '\n')
	file:write('InterpolationWidth ' .. ctfInterpolationWidth .. '\n')
	file:close()
end

local function writeNADEED3DCom()
   local comName = 'nad_eed_3d.com'
   local file = assert(io.open(comName, 'w'))
   file:write('# Command file to run nad_eed_3d\n')
   file:write('####CreatedVersion#### 3.12.20\n')
   file:write('$nad_eed_3d -k 2.56 -n 15 INPUTFILE OUTPUTFILE\n')
   file:close()
end

function comWriter.write(inputFile, tiltAxis, nx, ny, pixelSize, configFile)
   if configFile then
      localConfig = loadfile(configFile)
      if localConfig then localConfig() end
   end
   writeCcderaserCom(inputFile)
   writeTiltXCorrCom(inputFile, tiltAxis)
   writeXfToXgCom(inputFile)
   writeNewstackCom(inputFile)
   writeOpen2ScatterCom(inputFile)
   writeGoldCom(inputFile)
   writeTiltCom(inputFile, nx, ny)
   writeCTFPlotterCom(inputFile, tiltAxis, pixelSize)
   writeCTFCorrectCom(inputFile,pixelSize)
   writeNADEED3DCom()
end

return comWriter
