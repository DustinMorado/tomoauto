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
local tomoAutoDir = os.getenv('TOMOAUTOROOT')
package.cpath = package.cpath .. ';' .. tomoAutoDir .. '/lib/?.so;'
package.path = package.path .. ';' .. tomoAutoDir .. '/lib/?.lua;'
local lfs = assert(require 'lfs')
local globalConfig = assert(require 'globalConfig')

local comWriter = {}
local function writeCcderaserCom(inputFile)
	local comName = 'ccderaser.com'
	local filename = string.sub(inputFile, 1, -4)
	local file=assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN CCDERASER\n')
	file:write('####CreatedVersion#### 3.7.2\n')
	file:write('$ccderaser -StandardInput\n')
	file:write(string.format(
      'InputFile %s\n', inputFile)) 
	file:write(string.format(
      'OutputFile %s_fixed.st\n', filename)) 
	file:write('FindPeaks\n')
	file:write(string.format(
      'PeakCriterion %s\n',         ccderaserPeakCriterion))
	file:write(string.format(
      'DiffCriterion %s\n',         ccderaserDiffCriterion))
   file:write(string.format(
      'BigDiffCriterion %s\n',      ccderaserBigDiffCriterion))
   file:write(string.format(
      'GiantCriterion %s\n',        ccderaserGiantCriterion))
   file:write(string.format(
      'ExtraLargeRadius %s\n',      ccderaserExtraLargeRadius))
	file:write(string.format(
      'GrowCriterion %s\n',         ccderaserGrowCriterion))
	file:write(string.format(
      'EdgeExclusionWidth %s\n',    ccderaserEdgeExclusionWidth))
	file:write(string.format(
      'PointModel %s_peak.mod\n',   filename))
	file:write(string.format(
      'MaximumRadius %s\n',         ccderaserMaximumRadius)) 
	file:write(string.format(
      'AnnulusWidth %s\n',          ccderaserAnnulusWidth)) 
	file:write(string.format(
      'XYScanSize %s\n',            ccderaserXYScanSize)) 
	file:write(string.format(
      'ScanCriterion %s\n',         ccderaserScanCriterion))
	file:write(string.format(
      'BorderSize %s\n',            ccderaserBorderSize)) 
	file:write(string.format(
      'PolynomialOrder %s\n',       ccderaserPolynomialOrder)) 
	file:close()
end

local function writeTiltXCorrCom(inputFile, header)
	local comName = 'tiltxcorr.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN TILTXCORR\n')
	file:write('####CreatedVersion#### 3.4.4\n')
	file:write('$tiltxcorr -StandardInput\n')
	file:write(string.format(
      'InputFile %s\n', inputFile)) 
	file:write(string.format(
      'OutputFile %s.prexf\n',         filename)) 
	file:write(string.format(
      'TiltFile %s.rawtlt\n',          filename)) 
	file:write(string.format(
      'RotationAngle %s\n',            header.tilt_axis)) 
	file:write(string.format(
      'AngleOffset %s\n',              tiltxcorrAngleOffset)) 
	file:write(string.format(
      'FilterRadius2 %s\n',            tiltxcorrFilterRadius2)) 
	file:write(string.format(
      'FilterSigma1 %s\n',             tiltxcorrFilterSigma1)) 
	file:write(string.format(
      'FilterSigma2 %s\n',             tiltxcorrFilterSigma2)) 

	if tiltxcorrExcludeCentralPeak then
      file:write(string.format(
         'ExcludeCentralPeak\n'))
   end

	if tiltxcorrBordersInXandY_use then
      file:write(string.format(
         'BordersInXandY %s\n',        tiltxcorrBordersInXandY))
   end

	if tiltxcorrXMinAndMax_use then
      file:write(string.format(
         'XMinAndMax %s\n',            tiltxcorrXMinAndMax))
   end

	if tiltxcorrYMinAndMax_use then
      file:write(string.format(
         'YMinAndMax %s\n',            tiltxcorrYMinAndMax))
   end

	if tiltxcorrPadsInXandY_use then
      file:write(string.format(
         'PadsInXandY %s\n',           tiltxcorrPadsInXandY))
   end

	if tiltxcorrTapersInXandY_use then
      file:write(string.format(
         'TapersInXandY %s\n',         tiltxcorrTapersInXandY))
   end

	if tiltxcorrStartingEndingViews_use then
      file:write(string.format(
         'StartingEndingViews %s\n',   tiltxcorrStartingEndingViews))
   end

	if tiltxcorrCumulativeCorrelation then
      file:write(string.format(
         'CumulativeCorrelation\n'))
   end

	if tiltxcorrAbsoluteCosineStretch then
      file:write(string.format(
         'AbsoluteCosineStretch\n'))
   end

	if tiltxcorrNoCosineStretch then
      file:write(string.format(
         'NoCosineStretch\n'))
   end

	if tiltxcorrTestOutput then
      file:write(string.format(
         'TestOutput %s_test.img\n', filename))
   end

	file:close()
end

local function writeXfToXgCom(inputFile)
	local comName = 'xftoxg.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO RUN XFTOXG\n')
	file:write('####CreatedVersion#### 1.0.0\n')
	file:write('$xftoxg -StandardInput\n')
	file:write(string.format(
		'InputFile %s.prexf\n',          filename)) 
	file:write(string.format(
		'GOutputFile %s.prexg\n',        filename))
	file:write(string.format(
		'NumberToFit %s\n',              xftoxgNumberToFit)) 

	if xftoxgReferenceSection_use then
      file:write(string.format(
		   'ReferenceSection %s\n',      xftoxgReferenceSection)) 
   end

	if xftoxgOrderOfPolynomialFit_use then
      file:write(string.format(
		   'PolynomialFit %s\n',         xftoxgPolynomialFit)) 
   end

	if xftoxgHybridFits_use then
      file:write(string.format(
		   'HybridFits %s\n',            xftoxgHybridFits)) 
   end

	if xftoxgRangeOfAnglesInAverage_use then
      file:write(string.format(
   		'RangeOfAnglesInAvg %s\n',    xftoxgRangeOfAnglesInAvg)) 
   end

	file:close()
end

local function writePreNewstackCom(inputFile)
	local comName = 'prenewstack.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write('# THIS IS A COMMAND FILE TO PRODUCE A PRE-ALIGNED STACK\n')
	file:write('####CreatedVersion#### 1.0.0\n')
	file:write('$newstack -StandardInput\n')
	file:write(string.format(
		'InputFile %s\n',                inputFile))
	file:write(string.format(
		'OutputFile %s.preali\n',        filename))
	file:write(string.format(
		'TransformFile %s.prexg\n',      filename))

   if prenewstackModeToOutput_use then
	   file:write(string.format(
		   'ModeToOutput %s\n',          prenewstackModeToOutput))
   end

   file:write(string.format(
      'BinByFactor %s\n',              prenewstackBinByFactor))
   file:write(string.format(
      'ImagesAreBinned %s\n',          prenewstackImagesAreBinned))

   if prenewstackFloatDensities_use then
	   file:write(string.format(
		   'FloatDensities %s\n',        prenewstackFloatDensities)) 
   end

	if prenewstackContrastBlackWhite_use then
      file:write(string.format(
		   'ContrastBlackWhite %s\n',    prenewstackContrastBlackWhite)) 
   end

	if prenewstackScaleMinAndMax_use then
      file:write(string.format(
   		'ScaleMinAndMax %s\n',        prenewstackScaleMinAndMax))
   end

	file:close()
end

local function writeRaptorCom(inputFile, header)
   local comName = 'raptor1.com'
   local filename = string.sub(inputFile, 1,-4)
   local file = assert(io.open(comName, 'w'))
   file:write('# THIS IS A COMMAND FILE TO RUN RAPTOR\n')
   file:write('$RAPTOR -StandardInput\n')
   file:write('RaptorExecPath ' .. raptorExecPath .. '\n')
   file:write('InputPath ' .. lfs.currentdir() .. '\n')
   file:write('InputFile ' .. filename .. '.preali\n')
   file:write('OutputPath ' .. lfs.currentdir() .. '/raptor1\n')
   file:write('Diameter ' .. header.fidPx .. '\n')
   if raptorMarkersPerImage_use then
      file:write('MarkersPerImage ' .. raptorMarkersPerImage .. '\n')
   end
   file:write('TrackingOnly\n')
   if raptorAnglesInHeader_use then
      file:write('AnglesInHeader\n')
   end
   if raptorBinning_use then
      file:write('Binning ' .. raptorBinning .. '\n')
   end
   if raptorxRay_use then
      file:write('xRay\n')
   end
   file:close()
end

local function writeTiltAlignCom(inputFile, header)
   local comName = 'tiltalign.com'
   local filename = string.sub(inputFile, 1, -4)
   local file = assert(io.open(comName, 'w'))
   file:write('# THIS IS A COMMAND FILE TO RUN TILTALIGN\n')
   file:write('####CreatedVersion#### 3.10.4\n')
   file:write('$tiltalign -StandardInput\n')
   file:write(string.format(
      'ModelFile %s.fid\n', filename))
   file:write(string.format(
      'ImageFile %s.preali\n', filename))
   file:write(string.format(
      'ImagesAreBinned %d\n', tiltAlignImagesAreBinned))
   file:write(string.format(
      'OutputModelFile %s.3dmod\n', filename))
   file:write(string.format(
      'OutputResidualFile %s.resid\n', filename))
   file:write(string.format(
      'OutputFidXYZFile %sfid.xyz\n', filename))
   file:write(string.format(
      'OutputTiltFile %s.tlt\n', filename))
   file:write(string.format(
      'OutputXAxisTiltFile %s.xtilt\n', filename))
   file:write(string.format(
      'OutputTransformFile %s.tltxf\n', filename))
   file:write(string.format(
      'RotationAngle %4.2f\n', header.tilt_axis))
   file:write(string.format(
      'SeparateGroup %d-%d\n', 1, header.split_angle))
   file:write(string.format(
      'TiltFile %s.rawtlt\n', filename))
   
   if tiltAlignAngleOffset_use then
      file:write(string.format(
         'AngleOffset %4.2f\n', tiltAlignAngleOffset))
   end
   if tiltAlignRotOption_use then
      file:write(string.format(
         'RotOption %d\n', tiltAlignRotOption))
   end
   if tiltAlignRotDefaultGrouping_use then
      file:write(string.format(
         'RotDefaultGrouping %d\n', tiltAlignRotDefaultGrouping))
   end

   if tiltAlignTiltOption_use then
      file:write(string.format(
         'TiltOption %d\n', tiltAlignTiltOption))
   end
   if tiltAlignTiltDefaultGrouping_use then
      file:write(string.format(
         'TiltDefaultGrouping %d\n', tiltAlignTiltDefaultGrouping))
   end
   if tiltAlignMagReferenceView_use then
      file:write(string.format(
         'MagReferenceView %d\n', tiltAlignMagReferenceView))
   end
   if tiltAlignMagOption_use then
      file:write(string.format(
         'MagOption %d\n', tiltAlignMagOption))
   end
   if tiltAlignMagDefaultGrouping_use then
      file:write(string.format(
         'MagDefaultGrouping %d\n', tiltAlignMagDefaultGrouping))
   end

   if tiltAlignXStretchOption_use then
      file:write(string.format(
         'XStretchOption %d\n', tiltAlignXStretchOption))
   end
   if tiltAlignSkewOption_use then
      file:write(string.format(
         'SkewOption %d\n', tiltAlignSkewOption))
   end
   if tiltAlignXStretchDefaultGrouping_use then
      file:write(string.format(
         'XStretchDefaultGrouping %d\n', tiltAlignXStretchDefaultGrouping))
   end
   if tiltAlignSkewDefaultGrouping_use then
      file:write(string.format(
         'SkewDefaultGrouping %d\n', tiltAlignSkewDefaultGrouping))
   end
   if tiltAlignBeamTiltOption_use then
      file:write(string.format(
         'BeamTiltOption %d\n', tiltAlignBeamTiltOption))
   end

   if tiltAlignResidualReportCriterion_use then
      file:write(string.format(
         'ResidualReportCriterion %4.2f\n', tiltAlignResidualReportCriterion))
   end
   file:write(string.format(
      'SurfacesToAnalyze %d\n', tiltAlignSurfacesToAnalyze))
   file:write(string.format(
      'MetroFactor %4.2f\n', tiltAlignMetroFactor))
   file:write(string.format(
      'MaximumCycles %d\n', tiltAlignMaximumCycles))
   file:write(string.format(
      'KFactorScaling %4.2f\n', tiltAlignKFactorScaling))

   if tiltAlignAxisZShift_use then
      file:write(string.format(
         'AxisZShift %4.2f\n', tiltAlignAxisZShift))
   end
   if tiltAlignShiftZFromOriginal_use then
      file:write(string.format('ShiftZFromOriginal \n'))
   end

   if tiltAlignLocalAlignments_use then
      file:write(string.format('LocalAlignments\n'))
      file:write(string.format(
         'OutputLocalFile %slocal.xf\n', filename))
      file:write(string.format(
         'MinSizeOrOverlapXandY %s\n', tiltAlignMinSizeOrOverlapXandY))
      
      file:write(string.format(
         'MinFidsTotalAndEachSurface %s\n', 
         tiltAlignMinFidsTotalAndEachSurface))
      if tiltAlignFixXYZCoordinates_use then
         file:write(string.format('FixXYZCoordinates\n'))
      end
      file:write(string.format(
         'LocalOutputOptions %s\n', tiltAlignLocalOutputOptions))
      file:write(string.format(
         'LocalRotOption %d\n', tiltAlignLocalRotOption))
      file:write(string.format(
         'LocalRotDefaultGrouping %d\n', tiltAlignLocalRotDefaultGrouping))
      file:write(string.format(
         'LocalTiltOption %d\n', tiltAlignLocalTiltOption))
      file:write(string.format(
         'LocalTiltDefaultGrouping %d\n', tiltAlignLocalTiltDefaultGrouping))
      file:write(string.format(
         'LocalMagReferenceView %d\n', tiltAlignLocalMagReferenceView))
      file:write(string.format(
         'LocalMagOption %d\n', tiltAlignLocalMagOption))
      file:write(string.format(
         'LocalMagDefaultGrouping %d\n', tiltAlignLocalMagDefaultGrouping))
      file:write(string.format(
         'LocalXStretchOption %d\n', tiltAlignLocalXStretchOption))
      file:write(string.format(
         'LocalXStretchDefaultGrouping %d\n',
         tiltAlignLocalXStretchDefaultGrouping))
      file:write(string.format(
         'LocalSkewOption %d\n', tiltAlignLocalSkewOption))
      file:write(string.format(
         'LocalSkewDefaultGrouping %d\n', tiltAlignLocalSkewDefaultGrouping))
      file:write(string.format(
         'NumberOfLocalPatchesXandY %s\n', tiltAlignNumberOfLocalPatchesXandY))
      file:write(string.format(
         'OutputZFactorFile %s.zfac\n', filename))
      if tiltAlignRobustFitting_use then
         file:write(string.format('RobustFitting\n'))
      end
   end
   file:close()
end
   
local function writeXfProductCom(inputFile)
   local comName = 'xfproduct.com'
   local filename = string.sub(inputFile, 1, -4)
   local file = assert(io.open(comName, 'w'))
   file:write('# THIS IS A COMMAND FILE TO RUN XFPRODUCT\n')
   file:write('$xfproduct -StandardInput\n')
   file:write(string.format('InputFile1 %s.prexg\n', filename))
   file:write(string.format('InputFile2 %s.tltxf\n', filename))
   file:write(string.format('OutputFile %s_fid.xf\n', filename))
end

local function writeNewstackCom(inputFile)
   local comName = 'newstack.com'
   local filename = string.sub(inputFile, 1, -4)
   local file = assert(io.open(comName, 'w'))
   file:write('# THIS IS A COMMAND FILE TO RUN NEWSTACK\n')
   file:write('$newstack -StandardInput\n')
   file:write(string.format('InputFile %s\n', inputFile))
   file:write(string.format('OutputFile %s.ali\n', filename))
   file:write(string.format('TransformFile %s.xf\n', filename))
   file:write(string.format('TaperAtFill %s\n', newstackTaperAtFill))
   if newstackAdjustOrigin_use then
      file:write(string.format('AdjustOrigin\n'))
   end
   file:write(string.format('OffsetsInXandY %s\n', newstackOffsetsInXandY))
   if newstackDistortionField_use then
      file:write(string.format('DistortionField %s.idf\n', filename))
   end
   file:write(string.format('ImagesAreBinned %d\n', newstackImagesAreBinned))
   file:write(string.format('BinByFactor %d\n', newstackBinByFactor))
   if newstackGradientFile_use then
      file:write(string.format('GradientFile %s.maggrad\n', filename))
   end
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

local function writeTiltCom(inputFile, header, Opts)
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

	file:write('FULLIMAGE ' .. header.nx .. ' ' .. header.ny .. '\n')
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

   if Opts.s then
      tiltSUBSETSTART_use, tiltSUBSETSTART = true, '0 0'
   end

   if tiltSUBSETSTART_use then
      file:write('SUBSETSTART ' .. tiltSUBSETSTART .. '\n') 
   end

   if Opts.z_ then
      tiltTHICKNESS = Opts.z_
   end
	
   file:write('THICKNESS ' .. tiltTHICKNESS .. '\n')
   
   file:write('TILTFILE ' .. filename .. '.tlt\n')

   if Opts.g then
      tiltUseGPU_use, tiltUseGPU = true, 0
   end

	if tiltUseGPU_use then file:write('UseGPU ' .. tiltUseGPU .. '\n') end

	if tiltWIDTH_use then file:write('WIDTH ' .. tiltWIDTH .. '\n') end

	if tiltXAXISTILT_use then
      file:write('XAXISTILT ' .. tiltXAXISTILT .. '\n') end

	if tiltXTILTFILE_use then
      file:write('XTILTFILE ' .. filename .. '.xtilt\n') end

	file:close()
end

local function writeCTFPlotterCom(inputFile, header, Opts)
	local comName = 'ctfplotter.com'
	local filename = string.sub(inputFile, 1, -4)
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
	file:write('AxisAngle ' .. header.tilt_axis .. '\n')
	file:write('PixelSize ' .. header.pixel_size .. '\n')
	header.defocus = header.defocus * 1000
	file:write('ExpectedDefocus ' .. header.defocus .. '\n')
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
   if header.fType == 'Fei' then
      ctfConfigFile = '/usr/local/ImodCalib/CTFnoise'
      ctfConfigFile = ctfConfigFile .. '/CCDbackground/polara-CCD-2012.ctg'
      ctfFrequencyRangeToFit = '0.1 0.225'
   end
	file:write('ConfigFile ' .. ctfConfigFile .. '\n')
	file:write('FrequencyRangeToFit ' .. ctfFrequencyRangeToFit .. '\n')

	if ctfVaryExponentInFit_use then file:write('VaryExponentInFit\n') end

	file:write('SaveAndExit\n')
	file:close()
end

local function writeCTFCorrectCom(inputFile, header)
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
	file:write('PixelSize ' .. header.pixel_size .. '\n')
	file:write('AmplitudeContrast ' .. ctfAmplitudeContrast .. '\n')
	file:write('InterpolationWidth ' .. ctfInterpolationWidth .. '\n')
	file:close()
end

function comWriter.write(inputFile, header, Opts)
   if Opts.l_ then
      localConfig = loadfile(Opts.l_)
      if localConfig then localConfig() end
   end

   writeCcderaserCom(inputFile)
   writeTiltXCorrCom(inputFile, header)
   writeXfToXgCom(inputFile)
   writePreNewstackCom(inputFile)
   writeRaptorCom(inputFile, header)
   writeTiltAlignCom(inputFile, header)
   writeXfProductCom(inputFile)
   writeNewstackCom(inputFile)
   --writeOpen2ScatterCom(inputFile)
   writeGoldCom(inputFile)
   if Opts.c then
      writeCTFPlotterCom(inputFile, header, Opts)
      writeCTFCorrectCom(inputFile, header)
   end
   if not Opts.t then
      writeTiltCom(inputFile, header, Opts)
   end
end

return comWriter
