--[[==========================================================================#
#                               COM_file_writer                               #
#-----------------------------------------------------------------------------#
# This is a lua module for tomoruto that is responsible for writing all of    #
# the command (COM) files for the various programs in IMOD. It is largely     #
# dependent on the global or local configuration files which sets all of the  #
# options for all of the commands.                                            #
#-----------------------------------------------------------------------------#
# Author:  Dustin Morado                                                      #
# Written: Februrary 28th 2014                                                #
# Contact: dustin.morado@uth.tmc.edu                                          #
#-----------------------------------------------------------------------------#
# Arguments: input_filename: Image stack filename <string>                    #
#            header:         Image stack MRC header information <table>       #
#            options_table:  List of options as output by yago <table>        #
#==========================================================================--]]
local tomoauto_directory = os.getenv('TOMOAUTOROOT')
package.cpath = package.cpath .. ';' .. tomoauto_directory .. '/lib/?.so;'
package.path  = package.path .. ';' .. tomoauto_directory .. '/lib/?.lua;'
local lfs = require 'lfs'
local tomoauto_config = require 'tomoauto_config'

local COM_file_writer = {}
local function write_ccderaser(input_filename)
	local command_filename = 'ccderaser.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$ccderaser -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s\n', 
         input_filename
      )
   ) 
   command_file:write(string.format(
         'OutputFile %s_fixed.st\n', 
         basename
      )
   ) 
   command_file:write(string.format(
         'FindPeaks\n'
      )
   )
   command_file:write(string.format(
         'PeakCriterion %s\n', 
         ccderaser_PeakCriterion
      )
   )
   command_file:write(string.format(
         'DiffCriterion %s\n', 
         ccderaser_DiffCriterion
      )
   )
   command_file:write(string.format(
         'BigDiffCriterion %s\n',
         ccderaser_BigDiffCriterion
      )
   )
   command_file:write(string.format(
         'GiantCriterion %s\n',
         ccderaser_GiantCriterion
      )
   )
   command_file:write(string.format(
         'ExtraLargeRadius %s\n',
         ccderaser_ExtraLargeRadius
      )
   )
   command_file:write(string.format(
         'GrowCriterion %s\n',
         ccderaser_GrowCriterion
      )
   )
   command_file:write(string.format(
         'EdgeExclusionWidth %s\n',
         ccderaser_EdgeExclusionWidth
      )
   )
   command_file:write(string.format(
         'PointModel %s_peak.mod\n',
         basename
      )
   )
   command_file:write(string.format(
         'MaximumRadius %s\n',
         ccderaser_MaximumRadius
      )
   ) 
   command_file:write(string.format(
         'AnnulusWidth %s\n',
         ccderaserAnnulusWidth
      )
   ) 
   command_file:write(string.format(
         'XYScanSize %s\n',
         ccderaserXYScanSize
      )
   ) 
   command_file:write(string.format(
         'ScanCriterion %s\n',
         ccderaserScanCriterion
      )
   )
   command_file:write(string.format(
         'BorderSize %s\n',
         ccderaserBorderSize
      )
   ) 
   command_file:write(string.format(
         'PolynomialOrder %s\n',
         ccderaserPolynomialOrder
      )
   ) 
   command_file:close()
end

local function writeTiltXCorrCom(input_filename, header)
	local command_filename = 'tiltxcorr.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$tiltxcorr -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s\n',
         input_filename
      )
   ) 
   command_file:write(string.format(
         'OutputFile %s.prexf\n',
         basename
      )
   ) 
   command_file:write(string.format(
         'TiltFile %s.rawtlt\n',
         basename
      )
   ) 
   command_file:write(string.format(
         'RotationAngle %s\n',
         header.tilt_axis
      )
   ) 
   command_file:write(string.format(
         'AngleOffset %s\n',
         tiltxcorrAngleOffset
      )
   ) 
   command_file:write(string.format(
         'FilterRadius2 %s\n',
         tiltxcorrFilterRadius2
      )
   ) 
   command_file:write(string.format(
         'FilterSigma1 %s\n',
         tiltxcorrFilterSigma1
      )
   ) 
   command_file:write(string.format(
         'FilterSigma2 %s\n',
         tiltxcorrFilterSigma2
      )
   ) 
	if tiltxcorrExcludeCentralPeak then
      command_file:write(string.format(
            'ExcludeCentralPeak\n'
         )
      )
   end
	if tiltxcorrBordersInXandY_use then
      command_file:write(string.format(
            'BordersInXandY %s\n',
            tiltxcorrBordersInXandY
         )
      )
   end
	if tiltxcorrXMinAndMax_use then
      command_file:write(string.format(
            'XMinAndMax %s\n',
            tiltxcorrXMinAndMax
         )
      )
   end
	if tiltxcorrYMinAndMax_use then
      command_file:write(string.format(
            'YMinAndMax %s\n',
            tiltxcorrYMinAndMax
         )
      )
   end
	if tiltxcorrPadsInXandY_use then
      command_file:write(string.format(
            'PadsInXandY %s\n',
            tiltxcorrPadsInXandY
         )
      )
   end
	if tiltxcorrTapersInXandY_use then
      command_file:write(string.format(
            'TapersInXandY %s\n',
            tiltxcorrTapersInXandY
         )
      )
   end
	if tiltxcorrStartingEndingViews_use then
      command_file:write(string.format(
            'StartingEndingViews %s\n',
            tiltxcorrStartingEndingViews
         )
      )
   end
	if tiltxcorrCumulativeCorrelation_use then
      command_file:write(string.format(
            'CumulativeCorrelation\n'
         )
      )
   end
	if tiltxcorrAbsoluteCosineStretch_use then
      command_file:write(string.format(
            'AbsoluteCosineStretch\n'
         )
      )
   end
	if tiltxcorrNoCosineStretch_use then
      command_file:write(string.format(
            'NoCosineStretch\n'
         )
      )
   end
	if tiltxcorrTestOutput_use then
      if tiltxcorrTestOutput then
         command_file:write(string.format(
               'TestOutput %s\n',
               tiltxcorrTestOutput
            )
         )
      else
         command_file:write(string.format(
               'TestOutput %s_test.img\n',
               basename
            )
         )
      end
   end
   command_file:close()
end

local function writeXfToXgCom(input_filename)
	local command_filename  = 'xftoxg.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$xftoxg -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s.prexf\n',
         basename
      )
   ) 
   command_file:write(string.format(
         'GOutputFile %s.prexg\n',
         basename
      )
   )
   command_file:write(string.format(
         'NumberToFit %s\n',
         xftoxgNumberToFit
      )
   ) 
	if xftoxgReferenceSection_use then
      command_file:write(string.format(
            'ReferenceSection %s\n',
            xftoxgReferenceSection
         )
      ) 
   end
	if xftoxgOrderOfPolynomialFit_use then
      command_file:write(string.format(
            'PolynomialFit %s\n',
            xftoxgPolynomialFit
         )
      ) 
   end
	if xftoxgHybridFits_use then
      command_file:write(string.format(
            'HybridFits %s\n',
            xftoxgHybridFits
         )
      ) 
   end
	if xftoxgRangeOfAnglesInAverage_use then
      command_file:write(string.format(
            'RangeOfAnglesInAvg %s\n',
            xftoxgRangeOfAnglesInAvg
         )
      ) 
   end
   command_file:close()
end

local function writePreNewstackCom(input_filename)
	local command_filename = 'prenewstack.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$newstack -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s\n',
         input_filename
      )
   )
   command_file:write(string.format(
         'OutputFile %s.preali\n',
         basename
      )
   )
   command_file:write(string.format(
         'TransformFile %s.prexg\n',
         basename
      )
   )
   if prenewstackModeToOutput_use then
	   command_file:write(string.format(
            'ModeToOutput %s\n',
            prenewstackModeToOutput
         )
      )
   end
   command_file:write(string.format(
         'BinByFactor %s\n',
         prenewstackBinByFactor
      )
   )
   command_file:write(string.format(
         'ImagesAreBinned %s\n',
         prenewstackImagesAreBinned
      )
   )
   if prenewstackFloatDensities_use then
	   command_file:write(string.format(
            'FloatDensities %s\n',
            prenewstackFloatDensities
         )
      ) 
   end
	if prenewstackContrastBlackWhite_use then
      command_file:write(string.format(
            'ContrastBlackWhite %s\n',
            prenewstackContrastBlackWhite
         )
      ) 
   end
	if prenewstackScaleMinAndMax_use then
      command_file:write(string.format(
            'ScaleMinAndMax %s\n',
            prenewstackScaleMinAndMax
         )
      )
   end
   command_file:close()
end

local function writeRaptorCom(input_filename, header)
   local command_filename = 'raptor1.com'
   local basename = string.sub(input_filename, 1,-4)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$RAPTOR -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'RaptorExecPath %s\n',
         raptorExecPath
      )
   )
   command_file:write(string.format(
         'InputPath %s\n',
         lfs.currentdir()
      )
   )
   command_file:write(string.format(
         'InputFile %s.preali\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputPath $s/raptor1\n',
         lfs.currentdir()
      )
   )
   command_file:write(string.format(
         'Diameter %s\n',
         header.fidPx
      )
   )
   if raptorMarkersPerImage_use then
      command_file:write(string.format(
            'MarkersPerImage %s\n',
            raptorMarkersPerImage
         )
      )
   end
   command_file:write(string.format(
         'TrackingOnly\n'
      )
   )
   if raptorAnglesInHeader_use then
      command_file:write(string.format(
            'AnglesInHeader\n'
         )
      )
   end
   if raptorBinning_use then
      command_file:write(string.format(
            'Binning %s\n',
            raptorBinning
         )
      )
   end
   if raptorxRay_use then
      command_file:write(string.format(
            'xRay\n'
         )
      )
   end
   command_file:close()
end

local function writeTiltAlignCom(input_filename, header)
   local command_filename = 'tiltalign.com'
   local basename = string.sub(input_filename, 1, -4)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$tiltalign -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'ModelFile %s.fid\n',
         basename
      )
   )
   command_file:write(string.format(
         'ImageFile %s.preali\n',
         basename
      )
   )
   command_file:write(string.format(
         'ImagesAreBinned %d\n',
         tiltAlignImagesAreBinned
      )
   )
   command_file:write(string.format(
         'OutputModelFile %s.3dmod\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputResidualFile %s.resid\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputFidXYZFile %sfid.xyz\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputTiltFile %s.tlt\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputXAxisTiltFile %s.xtilt\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputTransformFile %s.tltxf\n',
         basename
      )
   )
   command_file:write(string.format(
         'RotationAngle %4.2f\n',
         header.tilt_axis
      )
   )
   command_file:write(string.format(
         'SeparateGroup %d-%d\n',
         1, 
         header.split_angle
      )
   )
   command_file:write(string.format(
         'TiltFile %s.rawtlt\n',
         basename
      )
   )
   if tiltAlignAngleOffset_use then
      command_file:write(string.format(
            'AngleOffset %4.2f\n',
            tiltAlignAngleOffset
         )
      )
   end
   if tiltAlignRotOption_use then
      command_file:write(string.format(
            'RotOption %d\n',
            tiltAlignRotOption
         )
      )
   end
   if tiltAlignRotDefaultGrouping_use then
      command_file:write(string.format(
            'RotDefaultGrouping %d\n',
            tiltAlignRotDefaultGrouping
         )
      )
   end
   if tiltAlignTiltOption_use then
      command_file:write(string.format(
            'TiltOption %d\n',
            tiltAlignTiltOption
         )
      )
   end
   if tiltAlignTiltDefaultGrouping_use then
      command_file:write(string.format(
            'TiltDefaultGrouping %d\n',
            tiltAlignTiltDefaultGrouping
         )
      )
   end
   if tiltAlignMagReferenceView_use then
      command_file:write(string.format(
            'MagReferenceView %d\n',
            tiltAlignMagReferenceView
         )
      )
   end
   if tiltAlignMagOption_use then
      command_file:write(string.format(
            'MagOption %d\n',
            tiltAlignMagOption
         )
      )
   end
   if tiltAlignMagDefaultGrouping_use then
      command_file:write(string.format(
            'MagDefaultGrouping %d\n',
            tiltAlignMagDefaultGrouping
         )
      )
   end
   if tiltAlignXStretchOption_use then
      command_file:write(string.format(
            'XStretchOption %d\n',
            tiltAlignXStretchOption
         )
      )
   end
   if tiltAlignSkewOption_use then
      command_file:write(string.format(
            'SkewOption %d\n',
            tiltAlignSkewOption
         )
      )
   end
   if tiltAlignXStretchDefaultGrouping_use then
      command_file:write(string.format(
            'XStretchDefaultGrouping %d\n',
            tiltAlignXStretchDefaultGrouping
         )
      )
   end
   if tiltAlignSkewDefaultGrouping_use then
      command_file:write(string.format(
            'SkewDefaultGrouping %d\n',
            tiltAlignSkewDefaultGrouping
         )
      )
   end
   if tiltAlignBeamTiltOption_use then
      command_file:write(string.format(
            'BeamTiltOption %d\n',
            tiltAlignBeamTiltOption
         )
      )
   end
   if tiltAlignResidualReportCriterion_use then
      command_file:write(string.format(
            'ResidualReportCriterion %4.2f\n',
            tiltAlignResidualReportCriterion
         )
      )
   end
   command_file:write(string.format(
         'SurfacesToAnalyze %d\n',
         tiltAlignSurfacesToAnalyze
      )
   )
   command_file:write(string.format(
         'MetroFactor %4.2f\n',
         tiltAlignMetroFactor
      )
   )
   command_file:write(string.format(
         'MaximumCycles %d\n',
         tiltAlignMaximumCycles
      )
   )
   command_file:write(string.format(
         'KFactorScaling %4.2f\n',
         tiltAlignKFactorScaling
      )
   )
   if tiltAlignAxisZShift_use then
      command_file:write(string.format(
            'AxisZShift %4.2f\n',
            tiltAlignAxisZShift
         )
      )
   end
   if tiltAlignShiftZFromOriginal_use then
      command_fil :write(string.format(
            'ShiftZFromOriginal \n'
         )
      )
   end
   if tiltAlignLocalAlignments_use then
      command_file:write(string.format(
            'LocalAlignments\n'
         )
      )
      command_file:write(string.format(
            'OutputLocalFile %slocal.xf\n',
            basename
         )
      )
      command_file:write(string.format(
            'MinSizeOrOverlapXandY %s\n',
            tiltAlignMinSizeOrOverlapXandY
         )
      )
      command_file:write(string.format(
            'MinFidsTotalAndEachSurface %s\n',
            tiltAlignMinFidsTotalAndEachSurface
         )
      )
      if tiltAlignFixXYZCoordinates_use then
         command_file:write(string.format(
               'FixXYZCoordinates\n'
            )
         )
      end
      command_file:write(string.format(
            'LocalOutputOptions %s\n',
            tiltAlignLocalOutputOptions
         )
      )
      command_file:write(string.format(
            'LocalRotOption %d\n',
            tiltAlignLocalRotOption
         )
      )
      command_file:write(string.format(
            'LocalRotDefaultGrouping %d\n',
            tiltAlignLocalRotDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalTiltOption %d\n',
            tiltAlignLocalTiltOption
         )
      )
      command_file:write(string.format(
            'LocalTiltDefaultGrouping %d\n',
            tiltAlignLocalTiltDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalMagReferenceView %d\n',
            tiltAlignLocalMagReferenceView
         )
      )
      command_file:write(string.format(
            'LocalMagOption %d\n',
            tiltAlignLocalMagOption
         )
      )
      command_file:write(string.format(
            'LocalMagDefaultGrouping %d\n',
            tiltAlignLocalMagDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalXStretchOption %d\n',
            tiltAlignLocalXStretchOption
         )
      )
      command_file:write(string.format(
            'LocalXStretchDefaultGrouping %d\n',
            tiltAlignLocalXStretchDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalSkewOption %d\n',
            tiltAlignLocalSkewOption
         )
      )
      command_file:write(string.format(
            'LocalSkewDefaultGrouping %d\n',
            tiltAlignLocalSkewDefaultGrouping
         )
      )
      command_file:write(string.format(
            'NumberOfLocalPatchesXandY %s\n',
            tiltAlignNumberOfLocalPatchesXandY
         )
      )
      command_file:write(string.format(
            'OutputZFactorFile %s.zfac\n',
            basename
         )
      )
      if tiltAlignRobustFitting_use then
         command_file:write(string.format(
               'RobustFitting\n'
            )
         )
      end
   end
   command_file:close()
end
   
local function writeXfProductCom(input_filename)
   local command_filename = 'xfproduct.com'
   local basename = string.sub(input_filename, 1, -4)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$xfproduct -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile1 %s.prexg\n',
         basename
      )
   )
   command_file:write(string.format(
         'InputFile2 %s.tltxf\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputFile %s_fid.xf\n',
         basename
      )
   )
   command_file:close()
end

local function writeNewstackCom(input_filename)
   local command_filename = 'newstack.com'
   local basename = string.sub(input_filename, 1, -4)
   local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$newstack -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s\n',
         input_filename
      )
   )
   command_file:write(string.format(
         'OutputFile %s.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'TransformFile %s.xf\n',
         basename
      )
   )
   command_file:write(string.format(
         'TaperAtFill %s\n',
         newstackTaperAtFill
      )
   )
   if newstackAdjustOrigin_use then
      command_file:write(string.format(
            'AdjustOrigin\n'
         )
      )
   end
   command_file:write(string.format(
         'OffsetsInXandY %s\n',
         newstackOffsetsInXandY
      )
   )
   if newstackDistortionField_use then
      command_file:write(string.format(
            'DistortionField %s.idf\n',
            basename
         )
      )
   end
   command_file:write(string.format(
         'ImagesAreBinned %d\n',
         newstackImagesAreBinned
      )
   )
   command_file:write(string.format(
         'BinByFactor %d\n',
         newstackBinByFactor
      )
   )
   if newstackGradientFile_use then
      command_file:write(string.format(
            'GradientFile %s.maggrad\n',
            basename
         )
      )
   end
   command_file:close()
end

local function writeGoldCom(input_filename)
	local command_filename = 'gold_ccderaser.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$ccderaser -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputFile %s.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputFile %s_erase.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'ModelFile %s_erase.fid\n',
         basename
      )
   )
   command_file:write(string.format(
         'CircleObjects %s\n',
         gccderaserCircleObjects
      )
   )
   command_file:write(string.format(
         'BetterRadius %s\n',
         gccderaserBetterRadius
      )
   )
	if gccderaserMergePatches then
      command_file:write(string.format(
            'MergePatches\n'
         )
      )
   end
   command_file:write(string.format(
         'PolynomialOrder %s\n',
         gccderaserPolynomialOrder
      )
   )
	if gccderaserExcludeAdjacent then
      command_file:write(string.format(
            'ExcludeAdjacent\n'
         )
      )
   end
   command_file:close()
end

local function writeTiltCom(input_filename, header, Opts)
	local command_filename = 'tilt.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$tilt -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputProjections %s.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputFile %s_full.rec\n',
         basename
      )
   )
   command_file:write(string.format(
         'ActionIfGPUFails %s\n',
         tiltActionIfGPUFails
      )
   )
	if tiltAdjustOrigin_use then
      command_file:write(string.format(
            'AdjustOrigin \n'
         )
      )
   end
   command_file:write(string.format(
         'FULLIMAGE %s %s\n',
         header.nx, 
         header.ny
      )
   )
   command_file:write(string.format(
         'IMAGEBINNED 1\n'
      )
   )
	if tiltLOG_use then
      command_file:write(string.format(
            'LOG %s\n',
            tiltLOG
         )
      )
   end
   command_file:write(string.format(
         'MODE %s\n',
         tiltMODE
      )
   )
	if tiltOFFSET_use then
      command_file:write(string.format(
            'OFFSET %s\n',
            tiltOFFSET
         )
      )
   end
	if tiltPARALLEL_use then
      command_file:write(string.format(
            'PARALLEL\n'
         )
      ) 
	elseif tiltPERPENDICULAR_use then
      command_file:write(string.format(
            'PERPENDICULAR \n'
         )
      )
	else 
      std.err:write(string.format(
            'Error! Please make sure either PARALLEL or PERPENDICULAR\n\z
            is chosen in the configuration command_file not both!\n'
         )
      )
   end
   command_file:write(string.format(
         'RADIAL %s\n',
         tiltRADIAL
      )
   )
   command_file:write(string.format(
         'SCALE %s\n',
         tiltSCALE
      )
   )
   command_file:write(string.format(
         'SHIFT %s\n',
         tiltSHIFT
      )
   )
	if tiltSLICE_use then
      command_file:write(string.format(
            'SLICE %s\n',
            tiltSLICE
         )
      )
   end
   if tiltSUBSETSTART_use then
      command_file:write(string.format(
            'SUBSETSTART %s\n',
            tiltSUBSETSTART
         )
      ) 
   end
   if Opts.z_ then
      tiltTHICKNESS = Opts.z_
   end
   command_file:write(string.format(
         'THICKNESS %s\n',
         tiltTHICKNESS
      )
   )
   command_file:write(string.format(
         'TILTFILE %s.tlt\n',
         basename
      )
   )
   if Opts.g then
      tiltUseGPU_use, tiltUseGPU = true, 0
   end
	if tiltUseGPU_use then
      command_file:write(string.format(
            'UseGPU %s\n',
            tiltUseGPU
         )
      )
   end
	if tiltWIDTH_use then
      command_file:write(string.format(
            'WIDTH %s\n',
            tiltWIDTH
         )
      )
   end
   if tiltLOCALFILE_use then
      command_file:write(string.format(
            'LOCALFILE %slocal.xf\n',
            basename
         )
      )
   end
	if tiltXAXISTILT_use then
      command_file:write(string.format(
            'XAXISTILT %s\n',
            tiltXAXISTILT
         )
      )
   end
	if tiltXTILTFILE_use then
      command_file:write(string.format(
            'XTILTFILE %s.xtilt\n',
            basename
         )
      )
   end
   if tiltZFACTORFILE_use then
      command_file:write(string.format(
            'ZFACTORFILE %s.zfac\n',
            basename
         )
      )
   end
   command_file:close()
end

local function writeCTFPlotterCom(input_filename, header, Opts)
	local command_filename = 'ctfplotter.com'
	local basename = string.sub(input_filename, 1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$ctfplotter -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputStack %s\n',
         input_filename
      )
   )
   command_file:write(string.format(
         'AngleFile %s.tlt\n',
         basename
      )
   )
   if ctfInvertTiltAngles_use then
      command_file:write(string.format(
            'InvertTiltAngles\n'
         )
      )
   end
   command_file:write(string.format(
         'OffsetToAdd %s\n',
         ctfOffsetToAdd
      )
   )
   command_file:write(string.format(
         'DefocusFile %s.defocus\n',
         basename
      )
   )
   command_file:write(string.format(
         'AxisAngle %s\n',
         header.tilt_axis
      )
   )
   command_file:write(string.format(
         'PixelSize %s\n',
         header.pixel_size
      )
   )
	header.defocus = header.defocus * 1000
   command_file:write(string.format(
         'ExpectedDefocus %s\n',
         header.defocus
      )
   )
   command_file:write(string.format(
         'AngleRange %s\n',
         ctfAngleRange
      )
   )
   command_file:write(string.format(
         'AutoFitRangeAndStep %s\n',
         ctfAutoFitRangeAndStep
      )
   )
   command_file:write(string.format(
         'Voltage %s\n',
         ctfVoltage
      )
   )
   command_file:write(string.format(
         'SphericalAberration %s\n',
         ctfSphericalAberration
      )
   )
   command_file:write(string.format(
         'AmplitudeContrast %s\n',
         ctfAmplitudeContrast
      )
   )
   command_file:write(string.format(
         'DefocusTol %s\n',
         ctfDefocusTol
      )
   )
   command_file:write(string.format(
         'PSResolution %s\n',
         ctfPSResolution
      )
   )
   command_file:write(string.format(
         'TileSize %s\n',
         ctfTileSize
      )
   )
   command_file:write(string.format(
         'LeftDefTol %s\n',
         ctfLeftDefTol
      )
   )
   command_file:write(string.format(
         'RightDefTol %s\n',
         ctfRightDefTol
      )
   )
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
   command_file:write(string.format(
         'ConfigFile ',
         ctfConfigFile
      )
   )
   command_file:write(string.format(
         'FrequencyRangeToFit ',
         ctfFrequencyRangeToFit
      )
   )
	if ctfVaryExponentInFit_use then
      command_file:write(string.format(
            'VaryExponentInFit\n'
         )
      )
   end
   command_file:write(string.format(
         'SaveAndExit\n'
      )
   )
   command_file:close()
end

local function writeCTFCorrectCom(input_filename, header)
	local command_filename = 'ctfcorrection.com'
	local basename = string.sub(input_filename,1, -4)
	local command_file = assert(io.open(command_filename, 'w'))
   command_file:write(string.format(
         '$ctfphaseflip -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputStack %s.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'AngleFile %s.tlt\n',
         basename
      )
   )
   if ctfInvertTiltAngles_use then
      command_file:write(string.format(
            'InvertTiltAngles\n'
         )
      )
   end
   command_file:write(string.format(
         'OutputFileName %s_ctfcorr.ali\n',
         basename
      )
   )
   command_file:write(string.format(
         'DefocusFile %s.defocus\n',
         basename
      )
   )
   command_file:write(string.format(
         'Voltage %s\n',
         ctfVoltage
      )
   )
   command_file:write(string.format(
         'SphericalAberration %s\n',
         ctfSphericalAberration
      )
   )
   command_file:write(string.format(
         'DefocusTol %s\n',
         ctfDefocusTol
      )
   )
   command_file:write(string.format(
         'PixelSize %s\n',
         header.pixel_size
      )
   )
   command_file:write(string.format(
         'AmplitudeContrast %s\n',
         ctfAmplitudeContrast
      )
   )
   command_file:write(string.format(
         'InterpolationWidth %s\n',
         ctfInterpolationWidth
      )
   )
   command_file:close()
end

function comWriter.write(input_filename, header, Opts)
   if Opts.l_ then
      localConfig = loadfile(Opts.l_)
      if localConfig then
         localConfig()
      end
   end

   writeCcderaserCom(input_filename)
   writeTiltXCorrCom(input_filename, header)
   writeXfToXgCom(input_filename)
   writePreNewstackCom(input_filename)
   writeRaptorCom(input_filename, header)
   writeTiltAlignCom(input_filename, header)
   writeXfProductCom(input_filename)
   writeNewstackCom(input_filename)
   writeGoldCom(input_filename)
   if Opts.c then
      writeCTFPlotterCom(input_filename, header, Opts)
      writeCTFCorrectCom(input_filename, header)
   end
   if not Opts.t then
      writeTiltCom(input_filename, header, Opts)
   end
end

return comWriter
