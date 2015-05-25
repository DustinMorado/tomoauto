--- Writes IMOD command files.
--
-- This module writes all of the command (COM) files for the various programs in
-- IMOD. It is largely dependent on the global and optional local configuration
-- files which set all of the options for all of the programs.
--
-- Dependencies: `MRC_IO_lib`, `tomoauto_config`
--
-- @module COM_file_lib
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.10

local COM_file_lib = {}

local lfs = require 'lfs'
local MRC_IO_lib = require 'MRC_IO_lib'
local tomoauto_config = require 'tomoauto_config'

local function write_ccderaser(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_ccderaser.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$ccderaser -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s\n\n', input_filename))
    command_file:write(string.format('OutputFile %s_fixed.st\n\n', basename))
    command_file:write(string.format('FindPeaks\n\n'))
    command_file:write(string.format('PeakCriterion %s\n\n',
        ccderaser_PeakCriterion))
    command_file:write(string.format('DiffCriterion %s\n\n',
        ccderaser_DiffCriterion))
    command_file:write(string.format('BigDiffCriterion %s\n\n',
        ccderaser_BigDiffCriterion))
    command_file:write(string.format('GiantCriterion %s\n\n',
        ccderaser_GiantCriterion))
    command_file:write(string.format('ExtraLargeRadius %s\n\n',
        ccderaser_ExtraLargeRadius))
    command_file:write(string.format('GrowCriterion %s\n\n',
        ccderaser_GrowCriterion))
    command_file:write(string.format('EdgeExclusionWidth %s\n\n',
        ccderaser_EdgeExclusionWidth))
    command_file:write(string.format('PointModel %s_peak.mod\n\n', basename))
    command_file:write(string.format('MaximumRadius %s\n\n',
        ccderaser_MaximumRadius))
    command_file:write(string.format('AnnulusWidth %s\n\n',
        ccderaser_AnnulusWidth))
    command_file:write(string.format('XYScanSize %s\n\n', ccderaser_XYScanSize))
    command_file:write(string.format('ScanCriterion %s\n\n',
        ccderaser_ScanCriterion))
    command_file:write(string.format('BorderSize %s\n\n', ccderaser_BorderSize))
    command_file:write(string.format('PolynomialOrder %s\n\n',
        ccderaser_PolynomialOrder))
    command_file:close()
end

local function write_tiltxcorr(input_filename, header)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_tiltxcorr.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$tiltxcorr -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s\n\n', input_filename))
    command_file:write(string.format('OutputFile %s.prexf\n\n', basename))
    command_file:write(string.format('TiltFile %s.rawtlt\n\n', basename))
    command_file:write(string.format('RotationAngle %s\n\n', header.tilt_axis))
    command_file:write(string.format('AngleOffset %s\n\n',
        tiltxcorr_AngleOffset))
    command_file:write(string.format('FilterRadius2 %s\n\n',
        tiltxcorr_FilterRadius2))
    command_file:write(string.format('FilterSigma1 %s\n\n',
        tiltxcorr_FilterSigma1))
    command_file:write(string.format('FilterSigma2 %s\n\n',
        tiltxcorr_FilterSigma2))
        if tiltxcorr_ExcludeCentralPeak_use then
        command_file:write(string.format('ExcludeCentralPeak\n\n'))
    end
        if tiltxcorr_BordersInXandY_use then
        command_file:write(string.format('BordersInXandY %s\n\n',
            tiltxcorr_BordersInXandY))
    end
        if tiltxcorr_XMinAndMax_use then
        command_file:write(string.format('XMinAndMax %s\n\n',
            tiltxcorr_XMinAndMax))
    end
        if tiltxcorr_YMinAndMax_use then
        command_file:write(string.format('YMinAndMax %s\n\n',
            tiltxcorr_YMinAndMax))
    end
        if tiltxcorr_PadsInXandY_use then
        command_file:write(string.format('PadsInXandY %s\n\n',
            tiltxcorr_PadsInXandY))
    end
        if tiltxcorr_TapersInXandY_use then
        command_file:write(string.format('TapersInXandY %s\n\n',
            tiltxcorr_TapersInXandY))
    end
        if tiltxcorr_StartingEndingViews_use then
        command_file:write(string.format('StartingEndingViews %s\n\n',
            tiltxcorr_StartingEndingViews))
    end
        if tiltxcorr_CumulativeCorrelation_use then
        command_file:write(string.format('CumulativeCorrelation\n\n'))
    end
        if tiltxcorr_AbsoluteCosineStretch_use then
        command_file:write(string.format('AbsoluteCosineStretch\n\n'))
    end
        if tiltxcorr_NoCosineStretch_use then
        command_file:write(string.format('NoCosineStretch\n\n'))
    end
        if tiltxcorr_TestOutput_use then
        if tiltxcorr_TestOutput then
            command_file:write(string.format('TestOutput %s\n\n',
            tiltxcorr_TestOutput))
        else
            command_file:write(string.format('TestOutput %s_test.img\n\n',
            basename))
        end
    end
    command_file:close()
end

local function write_xftoxg(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename  = string.format('%s_xftoxg.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$xftoxg -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s.prexf\n\n', basename))
    command_file:write(string.format('GOutputFile %s.prexg\n\n', basename))
    command_file:write(string.format('NumberToFit %s\n\n', xftoxg_NumberToFit))
        if xftoxg_ReferenceSection_use then
        command_file:write(string.format('ReferenceSection %s\n\n',
            xftoxg_ReferenceSection))
    end
        if xftoxg_OrderOfPolynomialFit_use then
        command_file:write(string.format('PolynomialFit %s\n\n',
            xftoxg_PolynomialFit))
    end
        if xftoxg_HybridFits_use then
        command_file:write(string.format('HybridFits %s\n\n', xftoxg_HybridFits))
    end
        if xftoxg_RangeOfAnglesInAverage_use then
        command_file:write(string.format('RangeOfAnglesInAvg %s\n\n',
            xftoxg_RangeOfAnglesInAvg))
    end
    command_file:close()
end

local function write_prenewstack(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_prenewstack.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$newstack -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s\n\n', input_filename))
    command_file:write(string.format('OutputFile %s.preali\n\n', basename))
    command_file:write(string.format('TransformFile %s.prexg\n\n', basename))
    if prenewstack_ModeToOutput_use then
        command_file:write(string.format('ModeToOutput %s\n\n',
            prenewstack_ModeToOutput))
    end
    command_file:write(string.format('BinByFactor %s\n\n',
        prenewstack_BinByFactor))
    command_file:write(string.format('ImagesAreBinned %s\n\n',
        prenewstack_ImagesAreBinned))
    if prenewstack_FloatDensities_use then
        command_file:write(string.format('FloatDensities %s\n\n',
            prenewstack_FloatDensities))
    end
        if prenewstack_ContrastBlackWhite_use then
        command_file:write(string.format('ContrastBlackWhite %s\n\n',
            prenewstack_ContrastBlackWhite))
    end
        if prenewstack_ScaleMinAndMax_use then
        command_file:write(string.format('ScaleMinAndMax %s\n\n',
            prenewstack_ScaleMinAndMax))
    end
    command_file:close()
end

local function write_RAPTOR(input_filename, header)
    local basename = string.sub(input_filename, 1,-4)
    local command_filename = string.format('%s_RAPTOR.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$RAPTOR -StandardInput\n\n'))
    command_file:write(string.format('RaptorExecPath %s\n\n', RAPTOR_ExecPath))
    command_file:write(string.format('InputPath %s\n\n', lfs.currentdir()))
    command_file:write(string.format('InputFile %s.preali\n\n', basename))
    command_file:write(string.format('OutputPath %s/%s_RAPTOR\n\n',
        lfs.currentdir(), basename))
    command_file:write(string.format('Diameter %s\n\n',
        header.fiducial_diameter_px))
    if RAPTOR_MarkersPerImage_use then
        command_file:write(string.format('MarkersPerImage %s\n\n',
            RAPTOR_MarkersPerImage))
    end
    command_file:write(string.format('TrackingOnly\n\n'))
    if RAPTOR_AnglesInHeader_use then
        command_file:write(string.format('AnglesInHeader\n\n'))
    end
    if RAPTOR_Binning_use then
        command_file:write(string.format('Binning %s\n\n', RAPTOR_Binning))
    end
    if RAPTOR_xRay_use then
        command_file:write(string.format('xRay\n\n'))
    end
    command_file:close()
end

local function write_autofidseed(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_autofidseed.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$autofidseed -StandardInput\n\n'))
    command_file:write(string.format('TrackCommandFile %s_beadtrack.com\n\n',
        basename))
    command_file:write(string.format('MinSpacing %f\n\n',
        autofidseed_MinSpacing))
    command_file:write(string.format('PeakStorageFraction %f\n\n',
        autofidseed_PeakStorageFraction))
    command_file:write(string.format('TargetNumberOfBeads %d\n\n',
        autofidseed_TargetNumberOfBeads))
    command_file:close()
end

local function write_beadtrack(input_filename, header)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_beadtrack.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))
    command_file:write(string.format('$beadtrack -StandardInput\n\n'))
    command_file:write(string.format('InputSeedModel %s.seed\n\n', basename))
    command_file:write(string.format('OutputModel %s.fid\n\n', basename))
    command_file:write(string.format('PrealignTransformFile %s.prexg\n\n',
        basename))
    command_file:write(string.format('ImageFile %s.preali\n\n', basename))
    command_file:write(string.format('RotationAngle %4.1f\n\n',
        header.tilt_axis ))
    command_file:write(string.format('TiltFile %s.rawtlt\n\n', basename))
    command_file:write(string.format('BeadDiameter %s\n\n',
        header.fiducial_diameter_px))
    command_file:write(string.format('RoundsOfTracking %d\n\n',
        beadtrack_RoundsOfTracking))
    command_file:write(string.format('TiltDefaultGrouping %d\n\n',
        beadtrack_TiltDefaultGrouping))
    command_file:write(string.format('MagDefaultGrouping %d\n\n',
        beadtrack_MagDefaultGrouping))
    command_file:write(string.format('RotDefaultGrouping %d\n\n',
        beadtrack_RotDefaultGrouping))
    command_file:write(string.format('BoxSizeXandY %s\n\n',
        beadtrack_BoxSizeXandY))
    if beadtrack_FillGaps_use then
        command_file:write(string.format('FillGaps\n\n'))
        command_file:write(string.format('MaxGapSize %d\n\n',
            beadtrack_MaxGapSize))
    end
    if beadtrack_LocalAreaTracking_use then
        command_file:write(string.format('LocalAreaTracking %d\n\n',
            beadtrack_LocalAreaTracking))
        command_file:write(string.format('LocalAreaTargetSize %d\n\n',
            beadtrack_LocalAreaTargetSize))
        command_file:write(string.format('MinBeadsInArea %d\n\n',
            beadtrack_MinBeadsInArea))
        command_file:write(string.format('MinOverlapBeads %d\n\n',
            beadtrack_MinOverlapBeads))
    end
    command_file:write(string.format('MinViewsForTiltalign %d\n\n',
        beadtrack_MinViewsForTiltalign))
    command_file:write(string.format('MinTiltRangeToFindAxis %f\n\n',
        beadtrack_MinTiltRangeToFindAxis))
    command_file:write(string.format('MaxBeadsToAverage %d\n\n',
        beadtrack_MaxBeadsToAverage))
    command_file:write(string.format('PointsToFitMaxAndMin %s\n\n',
        beadtrack_PointsToFitMaxAndMin))
    command_file:write(string.format('DensityRescueFractionAndSD %s\n\n',
        beadtrack_DensityRescueFractionAndSD))
    command_file:write(string.format('DistanceRescueCriterion %f\n\n',
        beadtrack_DistanceRescueCriterion))
    command_file:write(string.format('RescueRelaxationDensityAndDistance %s\n\n',
        beadtrack_RescueRelaxationDensityAndDistance))
    command_file:write(string.format('PostFitRescueResidual %f\n\n',
        beadtrack_PostFitRescueResidual))
    command_file:write(string.format('DensityRelaxationPostFit %f\n\n',
        beadtrack_DensityRelaxationPostFit))
    command_file:write(string.format('MaxRescueDistance %f\n\n',
        beadtrack_MaxRescueDistance))
    command_file:write(string.format('ResidualsToAnalyzeMaxAndMin %s\n\n',
        beadtrack_ResidualsToAnalyzeMaxAndMin))
    command_file:write(string.format('DeletionCriterionMinAndSD %s\n\n',
        beadtrack_DeletionCriterionMinAndSD))
    if beadtrack_SobelFilterCentering_use then
        command_file:write(string.format('SobelFilterCentering\n\n'))
        command_file:write(string.format('KernelSigmaForSobel %5.2f\n\n',
            beadtrack_KernelSigmaForSobel))
    end
    command_file:close()
end

local function write_tiltalign(input_filename, header)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_tiltalign.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$tiltalign -StandardInput\n\n'))
    command_file:write(string.format('ModelFile %s.fid\n\n', basename))
    command_file:write(string.format('ImageFile %s.preali\n\n', basename))
    command_file:write(string.format('ImagesAreBinned %d\n\n',
        tiltalign_ImagesAreBinned))
    command_file:write(string.format('OutputModelFile %s.3dmod\n\n', basename))
    command_file:write(string.format('OutputResidualFile %s.resid\n\n',
        basename))
    command_file:write(string.format('OutputFidXYZFile %s_fid.xyz\n\n', basename))
    command_file:write(string.format('OutputTiltFile %s.tlt\n\n', basename))
    command_file:write(string.format('OutputXAxisTiltFile %s.xtilt\n\n',
        basename))
    command_file:write(string.format('OutputTransformFile %s.tltxf\n\n',
        basename))
    command_file:write(string.format('RotationAngle %4.2f\n\n',
        header.tilt_axis))
    --[[ Commenting out for now because no longer collecting bidirectionally
    command_file:write(string.format('SeparateGroup %d-%d\n\n', 1,
        header.split_angle))
    --]]
    command_file:write(string.format('TiltFile %s.rawtlt\n\n', basename))
    if tiltalign_AngleOffset_use then
        command_file:write(string.format('AngleOffset %4.2f\n\n',
            tiltalign_AngleOffset))
    end
    if tiltalign_RotOption_use then
        command_file:write(string.format('RotOption %d\n\n', tiltalign_RotOption))
    end
    if tiltalign_RotDefaultGrouping_use then
        command_file:write(string.format('RotDefaultGrouping %d\n\n',
            tiltalign_RotDefaultGrouping))
    end
    if tiltalign_TiltOption_use then
        command_file:write(string.format('TiltOption %d\n\n',
            tiltalign_TiltOption))
    end
    if tiltalign_TiltDefaultGrouping_use then
        command_file:write(string.format('TiltDefaultGrouping %d\n\n',
            tiltalign_TiltDefaultGrouping))
    end
    if tiltalign_MagReferenceView_use then
        command_file:write(string.format('MagReferenceView %d\n\n',
            tiltalign_MagReferenceView))
    end
    if tiltalign_MagOption_use then
        command_file:write(string.format('MagOption %d\n\n', tiltalign_MagOption))
    end
    if tiltalign_MagDefaultGrouping_use then
        command_file:write(string.format('MagDefaultGrouping %d\n\n',
            tiltalign_MagDefaultGrouping))
    end
    if tiltalign_XStretchOption_use then
        command_file:write(string.format('XStretchOption %d\n\n',
            tiltalign_XStretchOption))
    end
    if tiltalign_SkewOption_use then
        command_file:write(string.format('SkewOption %d\n\n',
            tiltalign_SkewOption))
    end
    if tiltalign_XStretchDefaultGrouping_use then
        command_file:write(string.format('XStretchDefaultGrouping %d\n\n',
            tiltalign_XStretchDefaultGrouping))
    end
    if tiltalign_SkewDefaultGrouping_use then
        command_file:write(string.format('SkewDefaultGrouping %d\n\n',
            tiltalign_SkewDefaultGrouping))
    end
    if tiltalign_BeamTiltOption_use then
        command_file:write(string.format('BeamTiltOption %d\n\n',
            tiltalign_BeamTiltOption))
    end
    if tiltalign_ResidualReportCriterion_use then
        command_file:write(string.format('ResidualReportCriterion %4.2f\n\n',
            tiltalign_ResidualReportCriterion))
    end
    command_file:write(string.format('SurfacesToAnalyze %d\n\n',
        tiltalign_SurfacesToAnalyze))
    command_file:write(string.format('MetroFactor %4.2f\n\n',
        tiltalign_MetroFactor))
    command_file:write(string.format('MaximumCycles %d\n\n',
        tiltalign_MaximumCycles))
    command_file:write(string.format('KFactorScaling %4.2f\n\n',
        tiltalign_KFactorScaling))
    if tiltalign_AxisZShift_use then
        command_file:write(string.format('AxisZShift %4.2f\n\n',
            tiltalign_AxisZShift))
    end
    if tiltalign_ShiftZFromOriginal_use then
        command_file:write(string.format('ShiftZFromOriginal \n\n'))
    end
    if tiltalign_LocalAlignments_use then
        command_file:write(string.format('LocalAlignments\n\n'))
        command_file:write(string.format('OutputLocalFile %slocal.xf\n\n',
            basename))
        command_file:write(string.format('MinSizeOrOverlapXandY %s\n\n',
            tiltalign_MinSizeOrOverlapXandY))
        command_file:write(string.format('MinFidsTotalAndEachSurface %s\n\n',
            tiltalign_MinFidsTotalAndEachSurface))
        if tiltalign_FixXYZCoordinates_use then
            command_file:write(string.format('FixXYZCoordinates\n\n'))
        end
        command_file:write(string.format('LocalOutputOptions %s\n\n',
            tiltalign_LocalOutputOptions))
        command_file:write(string.format('LocalRotOption %d\n\n',
            tiltalign_LocalRotOption))
        command_file:write(string.format('LocalRotDefaultGrouping %d\n\n',
            tiltalign_LocalRotDefaultGrouping))
        command_file:write(string.format('LocalTiltOption %d\n\n',
            tiltalign_LocalTiltOption))
        command_file:write(string.format('LocalTiltDefaultGrouping %d\n\n',
            tiltalign_LocalTiltDefaultGrouping))
        command_file:write(string.format('LocalMagReferenceView %d\n\n',
            tiltalign_LocalMagReferenceView))
        command_file:write(string.format('LocalMagOption %d\n\n',
            tiltalign_LocalMagOption))
        command_file:write(string.format('LocalMagDefaultGrouping %d\n\n',
            tiltalign_LocalMagDefaultGrouping))
        command_file:write(string.format('LocalXStretchOption %d\n\n',
            tiltalign_LocalXStretchOption))
        command_file:write(string.format('LocalXStretchDefaultGrouping %d\n\n',
            tiltalign_LocalXStretchDefaultGrouping))
        command_file:write(string.format('LocalSkewOption %d\n\n',
            tiltalign_LocalSkewOption))
        command_file:write(string.format('LocalSkewDefaultGrouping %d\n\n',
            tiltalign_LocalSkewDefaultGrouping))
        command_file:write(string.format('NumberOfLocalPatchesXandY %s\n\n',
            tiltalign_NumberOfLocalPatchesXandY))
        command_file:write(string.format('OutputZFactorFile %s.zfac\n\n',
            basename))
        if tiltalign_RobustFitting_use then
            command_file:write(string.format('RobustFitting\n\n'))
        end
    end
    command_file:close()
end

local function write_xfproduct(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_xfproduct.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$xfproduct -StandardInput\n\n'))
    command_file:write(string.format('InputFile1 %s.prexg\n\n', basename))
    command_file:write(string.format('InputFile2 %s.tltxf\n\n', basename))
    command_file:write(string.format('OutputFile %s_fid.xf\n\n', basename))
    command_file:close()
end

local function write_newstack(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_newstack.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$newstack -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s\n\n', input_filename))
    command_file:write(string.format('OutputFile %s.ali\n\n', basename))
    command_file:write(string.format('TransformFile %s.xf\n\n', basename))
    command_file:write(string.format('TaperAtFill %s\n\n', newstack_TaperAtFill))
    if newstack_AdjustOrigin_use then
        command_file:write(string.format('AdjustOrigin\n\n'))
    end
    command_file:write(string.format('OffsetsInXandY %s\n\n',
        newstack_OffsetsInXandY))
    if newstack_DistortionField_use then
        command_file:write(string.format('DistortionField %s.idf\n\n', basename))
    end
    command_file:write(string.format('ImagesAreBinned %d\n\n',
        newstack_ImagesAreBinned))
    command_file:write(string.format('BinByFactor %d\n\n', newstack_BinByFactor))
    if newstack_GradientFile_use then
        command_file:write(string.format('GradientFile %s.maggrad\n\n', basename))
    end
    command_file:close()
end

local function write_ctfplotter(input_filename, header)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_ctfplotter.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$ctfplotter -StandardInput\n\n'))
    command_file:write(string.format('InputStack %s\n\n', input_filename))
    command_file:write(string.format('AngleFile %s.tlt\n\n', basename))
    if ctfplotter_InvertTiltAngles_use then
        command_file:write(string.format('InvertTiltAngles\n\n'))
    end
    command_file:write(string.format('OffsetToAdd %s\n\n',
        ctfplotter_OffsetToAdd))
    command_file:write(string.format('DefocusFile %s.defocus\n\n', basename))
    command_file:write(string.format('AxisAngle %s\n\n', header.tilt_axis))
    command_file:write(string.format('PixelSize %s\n\n', header.pixel_size))
    command_file:write(string.format('ExpectedDefocus %d\n\n',
        header.defocus * 1000))
    command_file:write(string.format('AngleRange %s\n\n', ctfplotter_AngleRange))
    command_file:write(string.format('AutoFitRangeAndStep %s\n\n',
        ctfplotter_AutoFitRangeAndStep))
    command_file:write(string.format('Voltage %s\n\n', ctfplotter_Voltage))
    command_file:write(string.format('SphericalAberration %s\n\n',
        ctfplotter_SphericalAberration))
    command_file:write(string.format('AmplitudeContrast %s\n\n',
        ctfplotter_AmplitudeContrast))
    command_file:write(string.format('DefocusTol %s\n\n', ctfplotter_DefocusTol))
    command_file:write(string.format('PSResolution %s\n\n',
        ctfplotter_PSResolution))
    command_file:write(string.format('TileSize %s\n\n', ctfplotter_TileSize))
    command_file:write(string.format('LeftDefTol %s\n\n', ctfplotter_LeftDefTol))
    command_file:write(string.format('RightDefTol %s\n\n',
        ctfplotter_RightDefTol))
    if header.file_type == 'Fei' then
        ctfplotter_ConfigFile = string.format('%s%s',
            '/usr/local/ImodCalib/CTFnoise', '/CCDbackground/polara-CCD-2012.ctg')
        ctfplotter_FrequencyRangeToFit = '0.1 0.225'
    elseif header.nx > 3000 then
        ctfplotter_ConfigFile = string.format('%s%s',
            '/usr/local/ImodCalib/CTFnoise',
            '/K24Kbackground/polara-K2-4K-2014.ctg')
        ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
    else
        ctfplotter_ConfigFile = ctfplotter_ConfigFile
        ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
    end
    command_file:write(string.format('ConfigFile %s\n\n', ctfplotter_ConfigFile))
    command_file:write(string.format('FrequencyRangeToFit %s\n\n',
        ctfplotter_FrequencyRangeToFit))
        if ctfplotter_VaryExponentInFit_use then
        command_file:write(string.format('VaryExponentInFit\n\n'))
    end
    command_file:write(string.format('SaveAndExit\n\n'))
    command_file:close()
end

local function write_ctfplotter_check(input_filename, header)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_ctfplotter.com.check', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$ctfplotter -StandardInput\n\n'))
    command_file:write(string.format('InputStack %s\n\n', input_filename))
    command_file:write(string.format('AngleFile %s.tlt\n\n', basename))
    if ctfplotter_InvertTiltAngles_use then
        command_file:write(string.format('InvertTiltAngles\n\n'))
    end
    command_file:write(string.format('OffsetToAdd %s\n\n',
        ctfplotter_OffsetToAdd))
    command_file:write(string.format('DefocusFile %s.defocus\n\n', basename))
    command_file:write(string.format('AxisAngle %s\n\n', header.tilt_axis))
    command_file:write(string.format('PixelSize %s\n\n', header.pixel_size))
    command_file:write(string.format('ExpectedDefocus %d\n\n',
        header.defocus * 1000))
    command_file:write(string.format('AngleRange %s\n\n', ctfplotter_AngleRange))
    command_file:write(string.format('AutoFitRangeAndStep %s\n\n',
        ctfplotter_AutoFitRangeAndStep))
    command_file:write(string.format('Voltage %s\n\n', ctfplotter_Voltage))
    command_file:write(string.format('SphericalAberration %s\n\n',
        ctfplotter_SphericalAberration))
    command_file:write(string.format('AmplitudeContrast %s\n\n',
        ctfplotter_AmplitudeContrast))
    command_file:write(string.format('DefocusTol %s\n\n', ctfplotter_DefocusTol))
    command_file:write(string.format('PSResolution %s\n\n',
        ctfplotter_PSResolution))
    command_file:write(string.format('TileSize %s\n\n', ctfplotter_TileSize))
    command_file:write(string.format('LeftDefTol %s\n\n', ctfplotter_LeftDefTol))
    command_file:write(string.format('RightDefTol %s\n\n',
        ctfplotter_RightDefTol))
    if header.file_type == 'Fei' then
        ctfplotter_ConfigFile = string.format('%s%s',
            '/usr/local/ImodCalib/CTFnoise', '/CCDbackground/polara-CCD-2012.ctg')
        ctfplotter_FrequencyRangeToFit = '0.1 0.225'
    elseif header.nx > 3000 then
        ctfplotter_ConfigFile = string.format('%s%s',
            '/usr/local/ImodCalib/CTFnoise',
            '/K24Kbackground/polara-K2-4K-2014.ctg')
        ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
    else
        ctfplotter_ConfigFile = ctfplotter_ConfigFile
        ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
    end
    command_file:write(string.format('ConfigFile %s\n\n', ctfplotter_ConfigFile))
    command_file:write(string.format('FrequencyRangeToFit %s\n\n',
        ctfplotter_FrequencyRangeToFit))
        if ctfplotter_VaryExponentInFit_use then
        command_file:write(string.format('VaryExponentInFit\n\n'))
    end
    command_file:write(string.format('#SaveAndExit\n\n'))
    command_file:close()
end

local function write_ctfphaseflip(input_filename, header)
    local basename = string.sub(input_filename,1, -4)
    local command_filename = string.format('%s_ctfphaseflip.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$ctfphaseflip -StandardInput\n\n'))
    command_file:write(string.format('InputStack %s.ali\n\n', basename))
    command_file:write(string.format('AngleFile %s.tlt\n\n', basename))
    if ctfphaseflip_InvertTiltAngles_use then
        command_file:write(string.format('InvertTiltAngles\n\n'))
    end
    command_file:write(string.format('OutputFileName %s_ctfcorr.ali\n\n',
        basename))
    command_file:write(string.format('DefocusFile %s.defocus\n\n', basename))
    command_file:write(string.format('Voltage %s\n\n', ctfphaseflip_Voltage))
    command_file:write(string.format('SphericalAberration %s\n\n',
        ctfphaseflip_SphericalAberration))
    command_file:write(string.format('DefocusTol %s\n\n',
        ctfphaseflip_DefocusTol))
    command_file:write(string.format('PixelSize %s\n\n', header.pixel_size))
    command_file:write(string.format('AmplitudeContrast %s\n\n',
        ctfphaseflip_AmplitudeContrast))
    command_file:write(string.format('InterpolationWidth %s\n\n',
        ctfphaseflip_InterpolationWidth))
    command_file:close()
end

local function write_xfmodel(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_xfmodel.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$xfmodel -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s.fid\n\n', basename))
    command_file:write(string.format('OutputFile %s_erase.fid\n\n', basename))
    command_file:write(string.format('XformsToApply %s.tltxf\n\n', basename))
    command_file:close()
end

local function write_gold_ccderaser(input_filename)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_gold_ccderaser.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$ccderaser -StandardInput\n\n'))
    command_file:write(string.format('InputFile %s.ali\n\n', basename))
    command_file:write(string.format('OutputFile %s_erase.ali\n\n', basename))
    command_file:write(string.format('ModelFile %s_erase.fid\n\n', basename))
    command_file:write(string.format('CircleObjects %s\n\n',
        gold_ccderaser_CircleObjects))
    command_file:write(string.format('BetterRadius %s\n\n',
        gold_ccderaser_BetterRadius))
    if gold_ccderaser_MergePatches_use then
        command_file:write(string.format('MergePatches\n\n'))
    end
    command_file:write(string.format('PolynomialOrder %s\n\n',
        gold_ccderaser_PolynomialOrder))
    if gold_ccderaser_ExcludeAdjacent_use then
        command_file:write(string.format('ExcludeAdjacent\n\n'))
    end
    command_file:close()
end

local function write_tilt(input_filename, header, options_table)
    local basename = string.sub(input_filename, 1, -4)
    local command_filename = string.format('%s_tilt.com', basename)
    local command_file = assert(io.open(command_filename, 'w'))

    command_file:write(string.format('$tilt -StandardInput\n\n'))
    command_file:write(string.format('InputProjections %s.ali\n\n', basename))
    command_file:write(string.format('OutputFile %s_full.rec\n\n', basename))
    command_file:write(string.format('ActionIfGPUFails %s\n\n',
        tilt_ActionIfGPUFails))
        if tilt_AdjustOrigin_use then
        command_file:write(string.format('AdjustOrigin \n\n'))
    end
    command_file:write(string.format('FULLIMAGE %s %s\n\n',
        header.nx, header.ny))
    command_file:write(string.format('IMAGEBINNED 1\n\n'))
        if tilt_LOG_use then
        command_file:write(string.format('LOG %s\n\n', tilt_LOG))
    end
    command_file:write(string.format('MODE %s\n\n', tilt_MODE))
        if tilt_OFFSET_use then
        command_file:write(string.format('OFFSET %s\n\n', tilt_OFFSET))
    end
        if tilt_PARALLEL_use then
            command_file:write(string.format('PARALLEL\n\n'))
        elseif tilt_PERPENDICULAR_use then
            command_file:write(string.format('PERPENDICULAR \n\n'))
        else
            error(string.format(
                'Error! Please make sure either PARALLEL or PERPENDICULAR\n' ..
                'is chosen in the configuration command_file not both!\n'))
        end
    command_file:write(string.format('RADIAL %s\n\n', tilt_RADIAL))
    command_file:write(string.format('SCALE %s\n\n', tilt_SCALE))
    command_file:write(string.format('SHIFT %s\n\n', tilt_SHIFT))
    if tilt_SLICE_use then
        command_file:write(string.format('SLICE %s\n\n', tilt_SLICE))
    end
    if tilt_SUBSETSTART_use then
        command_file:write(string.format('SUBSETSTART %s\n\n', tilt_SUBSETSTART))
    end
    if options_table.z_ then
        tilt_THICKNESS = options_table.z_
    end
    command_file:write(string.format('THICKNESS %s\n\n', tilt_THICKNESS))
    command_file:write(string.format('TILTFILE %s.tlt\n\n', basename))
    if options_table.g then
        tilt_UseGPU_use, tilt_UseGPU = true, 0
    end
        if tilt_UseGPU_use then
        command_file:write(string.format('UseGPU %s\n\n', tilt_UseGPU))
    end
        if tilt_WIDTH_use then
        command_file:write(string.format('WIDTH %s\n\n', tilt_WIDTH))
    end
    if tilt_LOCALFILE_use then
        command_file:write(string.format('LOCALFILE %slocal.xf\n\n', basename))
    end
        if tilt_XAXISTILT_use then
        command_file:write(string.format('XAXISTILT %s\n\n', tilt_XAXISTILT))
    end
        if tilt_XTILTFILE_use then
        command_file:write(string.format('XTILTFILE %s.xtilt\n\n', basename))
    end
    if tilt_ZFACTORFILE_use then
        command_file:write(string.format('ZFACTORFILE %s.zfac\n\n', basename))
    end
    command_file:close()
end

local function write_tomo3d(input_filename, header, options_table)
    local basename = string.sub(input_filename, 1, -4)
    local tilt_filename       = basename .. '.tlt'
    local aligned_filename    = basename .. '.ali'
    local reconstruction_filename = basename .. '_tomo3d.rec'
    local command_filename    = basename .. '_tomo3d.sh'
    local command_file = assert(io.open(command_filename, 'w'))

    local z = options_table.z_ or '1200'
    local iterations = options_table.i_ or '30'
    local hamming_filter = 0.35
    local tomo3d_string = string.format(' -a %s -i %s -m %f -z %d',
        tilt_filename, aligned_filename, hamming_filter, z)
    if options_table.g then
        tomo3d_string = string.format('tomo3dhybrid -g 0 %s', tomo3d_string)
    else
        tomo3d_string = string.format('tomo3d %s', tomo3d_string)
    end
    if options_table.s then
        reconstruction_filename = basename .. '_sirt.rec'
        tomo3d_string = string.format('%s -l %d -S -o %s', tomo3d_string,
            iterations, reconstruction_filename)
    else
        tomo3d_string = string.format('%s -o %s', tomo3d_string,
            reconstruction_filename)
    end

    command_file:write(string.format('#!/bin/sh\n\n'))
    if header.mode == 6 then
        command_file:write(string.format('newstack -mo 1 %s %s\n\n', 
            aligned_filename, aligned_filename))
    end
    command_file:write(string.format('%s\n\n', tomo3d_string))
    command_file:close()
    header = nil
    assert(os.execute(string.format('chmod a+x %s', command_filename)))
end

--- Writes necessary IMOD command files.
-- Takes the local functions in this module and writes the command files for
-- tomoauto or generate_command_files
-- @param input_filename MRC image stack to be processed e.g. "image.st"
-- @param fiducial_diameter Size of fiducial markers in nm e.g. "10"
-- @param options_table Table object with option flags from yago
function COM_file_lib.write(input_filename, fiducial_diameter, options_table)
    local basename = string.sub(input_filename, 1, -4)

    local header = MRC_IO_lib.get_required_header(input_filename,
        fiducial_diameter)
        
    if options_table.c then
        if options_table.d_ then
            header.defocus = options_table.d_
        elseif not header.defocus then
            error('You need to enter an appproximate defocus to run with CTF ' ..
            'correction.\n\n')
        end
    end

    if options_table.l_ then
        localConfig = loadfile(options_table.l_)
        if localConfig then
            localConfig()
        end
    end

    if options_table.m_ ~= "reconstruct" then
        local raw_tilt_filename = basename .. '.rawtlt'
        MRC_IO_lib.get_tilt_angles(input_filename, raw_tilt_filename)
        write_ccderaser(input_filename)
        write_tiltxcorr(input_filename, header)
        write_xftoxg(input_filename)
        write_prenewstack(input_filename)

        if options_table.r then
            write_RAPTOR(input_filename, header)
        else
            write_autofidseed(input_filename)
        end

        write_beadtrack(input_filename, header)
        write_tiltalign(input_filename, header)
        write_xfproduct(input_filename)
        write_newstack(input_filename)

        if options_table.c then
            write_ctfplotter(input_filename, header)
            write_ctfplotter_check(input_filename, header)
        end

        if options_table.m_ == "align" then
            header = nil
            return true
        end
    end

    if options_table.c then
        write_ctfphaseflip(input_filename, header)
    end

    write_xfmodel(input_filename)
    write_gold_ccderaser(input_filename)

    if options_table.t then
        write_tomo3d(input_filename, header, options_table)
    else
        write_tilt(input_filename, header, options_table)
    end

    header = nil
end
return COM_file_lib
