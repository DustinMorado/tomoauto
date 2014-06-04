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
	local comName  = 'ccderaser.com'
	local filename = string.sub(inputFile, 1, -4)
	local file=assert(io.open(comName, 'w'))
	file:write(string.format('$ccderaser -StandardInput\n'))
	file:write(string.format('InputFile %s\n', inputFile)) 
	file:write(string.format('OutputFile %s_fixed.st\n', filename)) 
	file:write(string.format('FindPeaks\n'))
	file:write(string.format('PeakCriterion %s\n', ccderaserPeakCriterion))
	file:write(string.format('DiffCriterion %s\n', ccderaserDiffCriterion))
   file:write(string.format('BigDiffCriterion %s\n', ccderaserBigDiffCriterion))
   file:write(string.format('GiantCriterion %s\n', ccderaserGiantCriterion))
   file:write(string.format('ExtraLargeRadius %s\n', ccderaserExtraLargeRadius))
	file:write(string.format('GrowCriterion %s\n', ccderaserGrowCriterion))
	file:write(string.format('EdgeExclusionWidth %s\n', ccderaserEdgeExclusionWidth))
	file:write(string.format('PointModel %s_peak.mod\n', filename))
	file:write(string.format('MaximumRadius %s\n', ccderaserMaximumRadius)) 
	file:write(string.format('AnnulusWidth %s\n', ccderaserAnnulusWidth)) 
	file:write(string.format('XYScanSize %s\n', ccderaserXYScanSize)) 
	file:write(string.format('ScanCriterion %s\n', ccderaserScanCriterion))
	file:write(string.format('BorderSize %s\n', ccderaserBorderSize)) 
	file:write(string.format('PolynomialOrder %s\n', ccderaserPolynomialOrder)) 
	file:close()
end

local function writeTiltXCorrCom(inputFile, header)
	local comName  = 'tiltxcorr.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$tiltxcorr -StandardInput\n'))
	file:write(string.format('InputFile %s\n', inputFile)) 
	file:write(string.format('OutputFile %s.prexf\n', filename)) 
	file:write(string.format('TiltFile %s.rawtlt\n', filename)) 
	file:write(string.format('RotationAngle %s\n', header.tilt_axis)) 
	file:write(string.format('AngleOffset %s\n', tiltxcorrAngleOffset)) 
	file:write(string.format('FilterRadius2 %s\n', tiltxcorrFilterRadius2)) 
	file:write(string.format('FilterSigma1 %s\n', tiltxcorrFilterSigma1)) 
	file:write(string.format('FilterSigma2 %s\n', tiltxcorrFilterSigma2)) 
	if tiltxcorrExcludeCentralPeak then
      file:write(string.format('ExcludeCentralPeak\n'))
   end
	if tiltxcorrBordersInXandY_use then
      file:write(string.format('BordersInXandY %s\n', tiltxcorrBordersInXandY))
   end
	if tiltxcorrXMinAndMax_use then
      file:write(string.format('XMinAndMax %s\n', tiltxcorrXMinAndMax))
   end
	if tiltxcorrYMinAndMax_use then
      file:write(string.format('YMinAndMax %s\n', tiltxcorrYMinAndMax))
   end
	if tiltxcorrPadsInXandY_use then
      file:write(string.format('PadsInXandY %s\n', tiltxcorrPadsInXandY))
   end
	if tiltxcorrTapersInXandY_use then
      file:write(string.format('TapersInXandY %s\n', tiltxcorrTapersInXandY))
   end
	if tiltxcorrStartingEndingViews_use then
      file:write(string.format('StartingEndingViews %s\n', tiltxcorrStartingEndingViews))
   end
	if tiltxcorrCumulativeCorrelation_use then
      file:write(string.format('CumulativeCorrelation\n'))
   end
	if tiltxcorrAbsoluteCosineStretch_use then
      file:write(string.format('AbsoluteCosineStretch\n'))
   end
	if tiltxcorrNoCosineStretch_use then
      file:write(string.format('NoCosineStretch\n'))
   end
	if tiltxcorrTestOutput_use then
      if tiltxcorrTestOutput then
         file:write(string.format('TestOutput %s\n', tiltxcorrTestOutput))
      else
         file:write(string.format('TestOutput %s_test.img\n', filename))
      end
   end
	file:close()
end

local function writeXfToXgCom(inputFile)
	local comName  = 'xftoxg.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$xftoxg -StandardInput\n'))
	file:write(string.format('InputFile %s.prexf\n', filename)) 
	file:write(string.format('GOutputFile %s.prexg\n', filename))
	file:write(string.format('NumberToFit %s\n', xftoxgNumberToFit)) 
	if xftoxgReferenceSection_use then
      file:write(string.format('ReferenceSection %s\n', xftoxgReferenceSection)) 
   end
	if xftoxgOrderOfPolynomialFit_use then
      file:write(string.format('PolynomialFit %s\n', xftoxgPolynomialFit)) 
   end
	if xftoxgHybridFits_use then
      file:write(string.format('HybridFits %s\n', xftoxgHybridFits)) 
   end
	if xftoxgRangeOfAnglesInAverage_use then
      file:write(string.format('RangeOfAnglesInAvg %s\n', xftoxgRangeOfAnglesInAvg)) 
   end
	file:close()
end

local function writePreNewstackCom(inputFile)
	local comName = 'prenewstack.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$newstack -StandardInput\n'))
	file:write(string.format('InputFile %s\n', inputFile))
	file:write(string.format('OutputFile %s.preali\n', filename))
	file:write(string.format('TransformFile %s.prexg\n', filename))
   if prenewstackModeToOutput_use then
	   file:write(string.format('ModeToOutput %s\n', prenewstackModeToOutput))
   end
   file:write(string.format('BinByFactor %s\n', prenewstackBinByFactor))
   file:write(string.format('ImagesAreBinned %s\n', prenewstackImagesAreBinned))
   if prenewstackFloatDensities_use then
	   file:write(string.format('FloatDensities %s\n', prenewstackFloatDensities)) 
   end
	if prenewstackContrastBlackWhite_use then
      file:write(string.format('ContrastBlackWhite %s\n', prenewstackContrastBlackWhite)) 
   end
	if prenewstackScaleMinAndMax_use then
      file:write(string.format('ScaleMinAndMax %s\n', prenewstackScaleMinAndMax))
   end
	file:close()
end

local function writeRaptorCom(inputFile, header)
   local comName = 'raptor1.com'
   local filename = string.sub(inputFile, 1,-4)
   local file = assert(io.open(comName, 'w'))
   file:write(string.format('$RAPTOR -StandardInput\n'))
   file:write(string.format('RaptorExecPath %s\n', raptorExecPath))
   file:write(string.format('InputPath %s\n', lfs.currentdir()))
   file:write(string.format('InputFile %s.preali\n', filename))
   file:write(string.format('OutputPath $s/raptor1\n', lfs.currentdir()))
   file:write(string.format('Diameter %s\n', header.fidPx))
   if raptorMarkersPerImage_use then
      file:write(string.format('MarkersPerImage %s\n', raptorMarkersPerImage))
   end
   file:write(string.format('TrackingOnly\n'))
   if raptorAnglesInHeader_use then
      file:write(string.format('AnglesInHeader\n'))
   end
   if raptorBinning_use then
      file:write(string.format('Binning %s\n', raptorBinning))
   end
   if raptorxRay_use then
      file:write(string.format('xRay\n'))
   end
   file:close()
end

local function writeTiltAlignCom(inputFile, header)
   local comName = 'tiltalign.com'
   local filename = string.sub(inputFile, 1, -4)
   local file = assert(io.open(comName, 'w'))
   file:write('$tiltalign -StandardInput\n')
   file:write(string.format('ModelFile %s.fid\n', filename))
   file:write(string.format('ImageFile %s.preali\n', filename))
   file:write(string.format('ImagesAreBinned %d\n', tiltAlignImagesAreBinned))
   file:write(string.format('OutputModelFile %s.3dmod\n', filename))
   file:write(string.format('OutputResidualFile %s.resid\n', filename))
   file:write(string.format('OutputFidXYZFile %sfid.xyz\n', filename))
   file:write(string.format('OutputTiltFile %s.tlt\n', filename))
   file:write(string.format('OutputXAxisTiltFile %s.xtilt\n', filename))
   file:write(string.format('OutputTransformFile %s.tltxf\n', filename))
   file:write(string.format('RotationAngle %4.2f\n', header.tilt_axis))
   file:write(string.format('SeparateGroup %d-%d\n', 1, header.split_angle))
   file:write(string.format('TiltFile %s.rawtlt\n', filename))
   if tiltAlignAngleOffset_use then
      file:write(string.format('AngleOffset %4.2f\n', tiltAlignAngleOffset))
   end
   if tiltAlignRotOption_use then
      file:write(string.format('RotOption %d\n', tiltAlignRotOption))
   end
   if tiltAlignRotDefaultGrouping_use then
      file:write(string.format('RotDefaultGrouping %d\n', tiltAlignRotDefaultGrouping))
   end
   if tiltAlignTiltOption_use then
      file:write(string.format('TiltOption %d\n', tiltAlignTiltOption))
   end
   if tiltAlignTiltDefaultGrouping_use then
      file:write(string.format('TiltDefaultGrouping %d\n', tiltAlignTiltDefaultGrouping))
   end
   if tiltAlignMagReferenceView_use then
      file:write(string.format('MagReferenceView %d\n', tiltAlignMagReferenceView))
   end
   if tiltAlignMagOption_use then
      file:write(string.format('MagOption %d\n', tiltAlignMagOption))
   end
   if tiltAlignMagDefaultGrouping_use then
      file:write(string.format('MagDefaultGrouping %d\n', tiltAlignMagDefaultGrouping))
   end
   if tiltAlignXStretchOption_use then
      file:write(string.format('XStretchOption %d\n', tiltAlignXStretchOption))
   end
   if tiltAlignSkewOption_use then
      file:write(string.format('SkewOption %d\n', tiltAlignSkewOption))
   end
   if tiltAlignXStretchDefaultGrouping_use then
      file:write(string.format('XStretchDefaultGrouping %d\n', tiltAlignXStretchDefaultGrouping))
   end
   if tiltAlignSkewDefaultGrouping_use then
      file:write(string.format('SkewDefaultGrouping %d\n', tiltAlignSkewDefaultGrouping))
   end
   if tiltAlignBeamTiltOption_use then
      file:write(string.format('BeamTiltOption %d\n', tiltAlignBeamTiltOption))
   end
   if tiltAlignResidualReportCriterion_use then
      file:write(string.format('ResidualReportCriterion %4.2f\n', tiltAlignResidualReportCriterion))
   end
   file:write(string.format('SurfacesToAnalyze %d\n', tiltAlignSurfacesToAnalyze))
   file:write(string.format('MetroFactor %4.2f\n', tiltAlignMetroFactor))
   file:write(string.format('MaximumCycles %d\n', tiltAlignMaximumCycles))
   file:write(string.format('KFactorScaling %4.2f\n', tiltAlignKFactorScaling))
   if tiltAlignAxisZShift_use then
      file:write(string.format('AxisZShift %4.2f\n', tiltAlignAxisZShift))
   end
   if tiltAlignShiftZFromOriginal_use then
      file:write(string.format('ShiftZFromOriginal \n'))
   end
   if tiltAlignLocalAlignments_use then
      file:write(string.format('LocalAlignments\n'))
      file:write(string.format('OutputLocalFile %slocal.xf\n', filename))
      file:write(string.format('MinSizeOrOverlapXandY %s\n', tiltAlignMinSizeOrOverlapXandY))
      file:write(string.format('MinFidsTotalAndEachSurface %s\n', tiltAlignMinFidsTotalAndEachSurface))
      if tiltAlignFixXYZCoordinates_use then
         file:write(string.format('FixXYZCoordinates\n'))
      end
      file:write(string.format('LocalOutputOptions %s\n', tiltAlignLocalOutputOptions))
      file:write(string.format('LocalRotOption %d\n', tiltAlignLocalRotOption))
      file:write(string.format('LocalRotDefaultGrouping %d\n', tiltAlignLocalRotDefaultGrouping))
      file:write(string.format('LocalTiltOption %d\n', tiltAlignLocalTiltOption))
      file:write(string.format('LocalTiltDefaultGrouping %d\n', tiltAlignLocalTiltDefaultGrouping))
      file:write(string.format('LocalMagReferenceView %d\n', tiltAlignLocalMagReferenceView))
      file:write(string.format('LocalMagOption %d\n', tiltAlignLocalMagOption))
      file:write(string.format('LocalMagDefaultGrouping %d\n', tiltAlignLocalMagDefaultGrouping))
      file:write(string.format('LocalXStretchOption %d\n', tiltAlignLocalXStretchOption))
      file:write(string.format('LocalXStretchDefaultGrouping %d\n', tiltAlignLocalXStretchDefaultGrouping))
      file:write(string.format('LocalSkewOption %d\n', tiltAlignLocalSkewOption))
      file:write(string.format('LocalSkewDefaultGrouping %d\n', tiltAlignLocalSkewDefaultGrouping))
      file:write(string.format('NumberOfLocalPatchesXandY %s\n', tiltAlignNumberOfLocalPatchesXandY))
      file:write(string.format('OutputZFactorFile %s.zfac\n', filename))
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
   file:write(string.format('InputFile1 %s.prexg\n', filename))
   file:write(string.format('InputFile2 %s.tltxf\n', filename))
   file:write(string.format('OutputFile %s_fid.xf\n', filename))
   file:close()
end

local function writeNewstackCom(inputFile)
   local comName = 'newstack.com'
   local filename = string.sub(inputFile, 1, -4)
   local file = assert(io.open(comName, 'w'))
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
   file:close()
end

local function writeGoldCom(inputFile)
	local comName = 'gold_ccderaser.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$ccderaser -StandardInput\n'))
	file:write(string.format('InputFile %s.ali\n', filename))
	file:write(string.format('OutputFile %s_erase.ali\n', filename))
	file:write(string.format('ModelFile %s_erase.fid\n', filename))
	file:write(string.format('CircleObjects %s\n', gccderaserCircleObjects))
	file:write(string.format('BetterRadius %s\n', gccderaserBetterRadius))
	if gccderaserMergePatches then
      file:write(string.format('MergePatches\n'))
   end
	file:write(string.format('PolynomialOrder %s\n', gccderaserPolynomialOrder))
	if gccderaserExcludeAdjacent then
      file:write(string.format('ExcludeAdjacent\n'))
   end
	file:close()
end

local function writeTiltCom(inputFile, header, Opts)
	local comName = 'tilt.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$tilt -StandardInput\n'))
	file:write(string.format('InputProjections %s.ali\n', filename))
	file:write(string.format('OutputFile %s_full.rec\n', filename))
	file:write(string.format('ActionIfGPUFails %s\n', tiltActionIfGPUFails))
	if tiltAdjustOrigin_use then
      file:write(string.format('AdjustOrigin \n'))
   end
	file:write(string.format('FULLIMAGE %s %s\n', header.nx, header.ny))
	file:write(string.format('IMAGEBINNED 1\n'))
	if tiltLOG_use then
      file:write(string.format('LOG %s\n', tiltLOG))
   end
	file:write(string.format('MODE %s\n', tiltMODE))
	if tiltOFFSET_use then
      file:write(string.format('OFFSET %s\n', tiltOFFSET))
   end
	if tiltPARALLEL_use then
      file:write(string.format('PARALLEL\n')) 
	elseif tiltPERPENDICULAR_use then
      file:write(string.format('PERPENDICULAR \n'))
	else std.err:write(string.format('Error! Please make sure either PARALLEL or PERPENDICULAR\n\zis chosen in the configuration file not both!\n'))
   end
	file:write(string.format('RADIAL %s\n', tiltRADIAL))
	file:write(string.format('SCALE %s\n', tiltSCALE))
	file:write(string.format('SHIFT %s\n', tiltSHIFT))
	if tiltSLICE_use then
      file:write(string.format('SLICE %s\n', tiltSLICE))
   end
   if tiltSUBSETSTART_use then
      file:write(string.format('SUBSETSTART %s\n', tiltSUBSETSTART)) 
   end
   if Opts.z_ then
      tiltTHICKNESS = Opts.z_
   end
   file:write(string.format('THICKNESS %s\n', tiltTHICKNESS))
   file:write(string.format('TILTFILE %s.tlt\n', filename))
   if Opts.g then
      tiltUseGPU_use, tiltUseGPU = true, 0
   end
	if tiltUseGPU_use then
      file:write(string.format('UseGPU %s\n', tiltUseGPU))
   end
	if tiltWIDTH_use then
      file:write(string.format('WIDTH %s\n', tiltWIDTH))
   end
   if tiltLOCALFILE_use then
      file:write(string.format('LOCALFILE %slocal.xf\n', filename))
   end
	if tiltXAXISTILT_use then
      file:write(string.format('XAXISTILT %s\n', tiltXAXISTILT))
   end
	if tiltXTILTFILE_use then
      file:write(string.format('XTILTFILE %s.xtilt\n', filename))
   end
   if tiltZFACTORFILE_use then
      file:write(string.format('ZFACTORFILE %s.zfac\n', filename))
   end
	file:close()
end

local function writeCTFPlotterCom(inputFile, header, Opts)
	local comName = 'ctfplotter.com'
	local filename = string.sub(inputFile, 1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$ctfplotter -StandardInput\n'))
	file:write(string.format('InputStack %s\n',  inputFile  '\n'))
	file:write(string.format('AngleFile %s.tlt\n',  filename  '.tlt\n'))
   if ctfInvertTiltAngles_use then
      file:write(string.format('InvertTiltAngles\n'))
   end
   file:write(string.format('OffsetToAdd %s\n',  ctfOffsetToAdd))
	file:write(string.format('DefocusFile %s.defocus\n',  filename))
	file:write(string.format('AxisAngle %s\n', header.tilt_axis))
	file:write(string.format('PixelSize %s\n', header.pixel_size))
	header.defocus = header.defocus * 1000
	file:write(string.format('ExpectedDefocus %s\n', header.defocus))
	file:write(string.format('AngleRange %s\n', ctfAngleRange))
   file:write(string.format('AutoFitRangeAndStep %s\n', ctfAutoFitRangeAndStep))
	file:write(string.format('Voltage %s\n', ctfVoltage))
	file:write(string.format('SphericalAberration %s\n', ctfSphericalAberration))
	file:write(string.format('AmplitudeContrast %s\n', ctfAmplitudeContrast))
	file:write(string.format('DefocusTol %s\n',  ctfDefocusTol))
	file:write(string.format('PSResolution %s\n',  ctfPSResolution))
	file:write(string.format('TileSize %s\n',  ctfTileSize))
	file:write(string.format('LeftDefTol %s\n',  ctfLeftDefTol))
	file:write(string.format('RightDefTol %s\n',  ctfRightDefTol))
   if header.fType == 'Fei' then
      ctfConfigFile = '/usr/local/ImodCalib/CTFnoise'
      ctfConfigFile = ctfConfigFile .. '/CCDbackground/polara-CCD-2012.ctg'
      ctfFrequencyRangeToFit = '0.1 0.225'
   elseif header.nx > 2000 then
      ctfConfigFile = '/usr/local/ImodCalib/CTFnoise'
      ctfConfigFile = ctfConfigFile .. '/CCDbackground/polara-K2-4K-2014.ctg'
      ctfFrequencyRangeToFit = ctfFrequencyRangeToFit
   else
      ctfConfigFile = ctfConfigFile
      ctfFrequencyRangeToFit = ctfFrequencyRangeToFit
   end
	file:write(string.format('ConfigFile ', ctfConfigFile))
	file:write(string.format('FrequencyRangeToFit ', ctfFrequencyRangeToFit))
	if ctfVaryExponentInFit_use then
      file:write(string.format('VaryExponentInFit\n'))
   end
	file:write(string.format('SaveAndExit\n'))
	file:close()
end

local function writeCTFCorrectCom(inputFile, header)
	local comName = 'ctfcorrection.com'
	local filename = string.sub(inputFile,1, -4)
	local file = assert(io.open(comName, 'w'))
	file:write(string.format('$ctfphaseflip -StandardInput\n'))
	file:write(string.format('InputStack %s.ali\n', filename))
	file:write(string.format('AngleFile %s.tlt\n', filename))
   if ctfInvertTiltAngles_use then
      file:write(string.format('InvertTiltAngles\n'))
   end
	file:write(string.format('OutputFileName %s_ctfcorr.ali\n', filename))
	file:write(string.format('DefocusFile %s.defocus\n', filename))
	file:write(string.format('Voltage %s\n', ctfVoltage))
	file:write(string.format('SphericalAberration %s\n', ctfSphericalAberration))
	file:write(string.format('DefocusTol %s\n', ctfDefocusTol))
	file:write(string.format('PixelSize %s\n', header.pixel_size))
	file:write(string.format('AmplitudeContrast %s\n', ctfAmplitudeContrast))
	file:write(string.format('InterpolationWidth %s\n', ctfInterpolationWidth))
	file:close()
end

function comWriter.write(inputFile, header, Opts)
   if Opts.l_ then
      localConfig = loadfile(Opts.l_)
      if localConfig then
         localConfig()
      end
   end

   writeCcderaserCom(inputFile)
   writeTiltXCorrCom(inputFile, header)
   writeXfToXgCom(inputFile)
   writePreNewstackCom(inputFile)
   writeRaptorCom(inputFile, header)
   writeTiltAlignCom(inputFile, header)
   writeXfProductCom(inputFile)
   writeNewstackCom(inputFile)
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
