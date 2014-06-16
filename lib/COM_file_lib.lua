--[[==========================================================================#
#                               COM_file_lib                                  #
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

local COM_file_lib = {}

--[[===========================================================================#
#                               write_ccderaser                                #
#------------------------------------------------------------------------------#
# Writes ccderaser command file                                                #
#===========================================================================--]]
local function write_ccderaser(input_filename)
	local basename = string.sub(input_filename, 1, -4)
   local command_filename = string.format(
      '%s_ccderaser.com',
      basename
   )
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
         ccderaser_AnnulusWidth
      )
   )
   command_file:write(string.format(
         'XYScanSize %s\n',
         ccderaser_XYScanSize
      )
   )
   command_file:write(string.format(
         'ScanCriterion %s\n',
         ccderaser_ScanCriterion
      )
   )
   command_file:write(string.format(
         'BorderSize %s\n',
         ccderaser_BorderSize
      )
   )
   command_file:write(string.format(
         'PolynomialOrder %s\n',
         ccderaser_PolynomialOrder
      )
   )
   command_file:close()
end

--[[===========================================================================#
#                               write_tiltxcorr                                #
#------------------------------------------------------------------------------#
# Writes the tiltxcorr command file.                                           #
#===========================================================================--]]
local function write_tiltxcorr(input_filename, header)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_tiltxcorr.com',
      basename
   )
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
         tiltxcorr_AngleOffset
      )
   )
   command_file:write(string.format(
         'FilterRadius2 %s\n',
         tiltxcorr_FilterRadius2
      )
   )
   command_file:write(string.format(
         'FilterSigma1 %s\n',
         tiltxcorr_FilterSigma1
      )
   )
   command_file:write(string.format(
         'FilterSigma2 %s\n',
         tiltxcorr_FilterSigma2
      )
   )
	if tiltxcorr_ExcludeCentralPeak_use then
      command_file:write(string.format(
            'ExcludeCentralPeak\n'
         )
      )
   end
	if tiltxcorr_BordersInXandY_use then
      command_file:write(string.format(
            'BordersInXandY %s\n',
            tiltxcorr_BordersInXandY
         )
      )
   end
	if tiltxcorr_XMinAndMax_use then
      command_file:write(string.format(
            'XMinAndMax %s\n',
            tiltxcorr_XMinAndMax
         )
      )
   end
	if tiltxcorr_YMinAndMax_use then
      command_file:write(string.format(
            'YMinAndMax %s\n',
            tiltxcorr_YMinAndMax
         )
      )
   end
	if tiltxcorr_PadsInXandY_use then
      command_file:write(string.format(
            'PadsInXandY %s\n',
            tiltxcorr_PadsInXandY
         )
      )
   end
	if tiltxcorr_TapersInXandY_use then
      command_file:write(string.format(
            'TapersInXandY %s\n',
            tiltxcorr_TapersInXandY
         )
      )
   end
	if tiltxcorr_StartingEndingViews_use then
      command_file:write(string.format(
            'StartingEndingViews %s\n',
            tiltxcorr_StartingEndingViews
         )
      )
   end
	if tiltxcorr_CumulativeCorrelation_use then
      command_file:write(string.format(
            'CumulativeCorrelation\n'
         )
      )
   end
	if tiltxcorr_AbsoluteCosineStretch_use then
      command_file:write(string.format(
            'AbsoluteCosineStretch\n'
         )
      )
   end
	if tiltxcorr_NoCosineStretch_use then
      command_file:write(string.format(
            'NoCosineStretch\n'
         )
      )
   end
	if tiltxcorr_TestOutput_use then
      if tiltxcorr_TestOutput then
         command_file:write(string.format(
               'TestOutput %s\n',
               tiltxcorr_TestOutput
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

--[[===========================================================================#
#                                 write_xftoxg                                 #
#------------------------------------------------------------------------------#
# Writes a command file for xftoxg.                                            #
#===========================================================================--]]
local function write_xftoxg(input_filename)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename  = string.format(
      '%s_xftoxg.com',
      basename
   )
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
         xftoxg_NumberToFit
      )
   )
	if xftoxg_ReferenceSection_use then
      command_file:write(string.format(
            'ReferenceSection %s\n',
            xftoxg_ReferenceSection
         )
      )
   end
	if xftoxg_OrderOfPolynomialFit_use then
      command_file:write(string.format(
            'PolynomialFit %s\n',
            xftoxg_PolynomialFit
         )
      )
   end
	if xftoxg_HybridFits_use then
      command_file:write(string.format(
            'HybridFits %s\n',
            xftoxg_HybridFits
         )
      )
   end
	if xftoxg_RangeOfAnglesInAverage_use then
      command_file:write(string.format(
            'RangeOfAnglesInAvg %s\n',
            xftoxg_RangeOfAnglesInAvg
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                            write_prenewstack                                 #
#------------------------------------------------------------------------------#
# Writes a command file for newstack for coarse alignment.                     #
#===========================================================================--]]
local function write_prenewstack(input_filename)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_prenewstack.com',
      basename
   )
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
   if prenewstack_ModeToOutput_use then
	   command_file:write(string.format(
            'ModeToOutput %s\n',
            prenewstack_ModeToOutput
         )
      )
   end
   command_file:write(string.format(
         'BinByFactor %s\n',
         prenewstack_BinByFactor
      )
   )
   command_file:write(string.format(
         'ImagesAreBinned %s\n',
         prenewstack_ImagesAreBinned
      )
   )
   if prenewstack_FloatDensities_use then
	   command_file:write(string.format(
            'FloatDensities %s\n',
            prenewstack_FloatDensities
         )
      )
   end
	if prenewstack_ContrastBlackWhite_use then
      command_file:write(string.format(
            'ContrastBlackWhite %s\n',
            prenewstack_ContrastBlackWhite
         )
      )
   end
	if prenewstack_ScaleMinAndMax_use then
      command_file:write(string.format(
            'ScaleMinAndMax %s\n',
            prenewstack_ScaleMinAndMax
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                                 write_RAPTOR                                 #
#------------------------------------------------------------------------------#
# Writes a command file for RAPTOR                                             #
#===========================================================================--]]
local function write_RAPTOR(input_filename, header)
   local basename = string.sub(input_filename, 1,-4)
   local command_filename = string.format(
      '%s_RAPTOR.com',
      basename
   )
   local command_file = assert(io.open(command_filename, 'w'))

   command_file:write(string.format(
         '$RAPTOR -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'RaptorExecPath %s\n',
         RAPTOR_ExecPath
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
         'OutputPath %s/%s_RAPTOR\n',
         lfs.currentdir(),
         basename
      )
   )
   command_file:write(string.format(
         'Diameter %s\n',
         header.fiducial_diameter_px
      )
   )
   if RAPTOR_MarkersPerImage_use then
      command_file:write(string.format(
            'MarkersPerImage %s\n',
            RAPTOR_MarkersPerImage
         )
      )
   end
   command_file:write(string.format(
         'TrackingOnly\n'
      )
   )
   if RAPTOR_AnglesInHeader_use then
      command_file:write(string.format(
            'AnglesInHeader\n'
         )
      )
   end
   if RAPTOR_Binning_use then
      command_file:write(string.format(
            'Binning %s\n',
            RAPTOR_Binning
         )
      )
   end
   if RAPTOR_xRay_use then
      command_file:write(string.format(
            'xRay\n'
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                               write_beadtrack                                #
#------------------------------------------------------------------------------#
# Writes a command file for beadtrack                                          #
#===========================================================================--]]
local function write_beadtrack(input_filename, header)
   local basename = string.sub(input_filename, 1, -4)
   local command_filename = string.format(
      '%s_beadtrack.com',
      basename
   )
   local command_file = assert(io.open(command_filename, 'w'))

   command_file:write(string.format(
         '$beadtrack -StandardInput\n'
      )
   )
   command_file:write(string.format(
         'InputSeedModel %s.fid\n',
         basename
      )
   )
   command_file:write(string.format(
         'OutputModel %s_beadtrack.fid\n',
         basename
      )
   )
   command_file:write(string.format(
         'ImageFile %s.preali\n',
         basename
      )
   )
   command_file:write(string.format(
         'RotationAngle %4.1f\n',
         header.tilt_axis 
      )
   )
   command_file:write(string.format(
         'TiltFile %s.rawtlt\n',
         basename
      )
   )
   command_file:write(string.format(
         'BeadDiameter %s\n',
         header.fiducial_diameter_px
      )
   )
   command_file:write(string.format(
         'RoundsOfTracking %d\n',
         beadtrack_RoundsOfTracking
      )
   )
   command_file:write(string.format(
         'TiltDefaultGrouping %d\n',
         beadtrack_TiltDefaultGrouping
      )
   )
   command_file:write(string.format(
         'MagDefaultGrouping %d\n',
         beadtrack_MagDefaultGrouping
      )
   )
   command_file:write(string.format(
         'BoxSizeXandY %s\n',
         beadtrack_BoxSizeXandY
      )
   )
   if beadtrack_FillGaps_use then
      command_file:write(string.format(
            'FillGaps\n'
         )
      )
   end
   if beadtrack_SobelFilterCentering_use then
      command_file:write(string.format(
            'SobelFilterCentering\n'
         )
      )
      command_file:write(string.format(
            'KernelSigmaForSobel %5.2f\n',
            beadtrack_KernelSigmaForSobel
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                               write_tiltalign                                #
#------------------------------------------------------------------------------#
# Writes a command file for tiltalign                                          #
#===========================================================================--]]
local function write_tiltalign(input_filename, header)
   local basename = string.sub(input_filename, 1, -4)
   local command_filename = string.format(
      '%s_tiltalign.com',
      basename
   )
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
         tiltalign_ImagesAreBinned
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
   ---[[
   command_file:write(string.format(
         'SeparateGroup %d-%d\n',
         1,
         header.split_angle
      )
   )
   --]]
   command_file:write(string.format(
         'TiltFile %s.rawtlt\n',
         basename
      )
   )
   if tiltalign_AngleOffset_use then
      command_file:write(string.format(
            'AngleOffset %4.2f\n',
            tiltalign_AngleOffset
         )
      )
   end
   if tiltalign_RotOption_use then
      command_file:write(string.format(
            'RotOption %d\n',
            tiltalign_RotOption
         )
      )
   end
   if tiltalign_RotDefaultGrouping_use then
      command_file:write(string.format(
            'RotDefaultGrouping %d\n',
            tiltalign_RotDefaultGrouping
         )
      )
   end
   if tiltalign_TiltOption_use then
      command_file:write(string.format(
            'TiltOption %d\n',
            tiltalign_TiltOption
         )
      )
   end
   if tiltalign_TiltDefaultGrouping_use then
      command_file:write(string.format(
            'TiltDefaultGrouping %d\n',
            tiltalign_TiltDefaultGrouping
         )
      )
   end
   if tiltalign_MagReferenceView_use then
      command_file:write(string.format(
            'MagReferenceView %d\n',
            tiltalign_MagReferenceView
         )
      )
   end
   if tiltalign_MagOption_use then
      command_file:write(string.format(
            'MagOption %d\n',
            tiltalign_MagOption
         )
      )
   end
   if tiltalign_MagDefaultGrouping_use then
      command_file:write(string.format(
            'MagDefaultGrouping %d\n',
            tiltalign_MagDefaultGrouping
         )
      )
   end
   if tiltalign_XStretchOption_use then
      command_file:write(string.format(
            'XStretchOption %d\n',
            tiltalign_XStretchOption
         )
      )
   end
   if tiltalign_SkewOption_use then
      command_file:write(string.format(
            'SkewOption %d\n',
            tiltalign_SkewOption
         )
      )
   end
   if tiltalign_XStretchDefaultGrouping_use then
      command_file:write(string.format(
            'XStretchDefaultGrouping %d\n',
            tiltalign_XStretchDefaultGrouping
         )
      )
   end
   if tiltalign_SkewDefaultGrouping_use then
      command_file:write(string.format(
            'SkewDefaultGrouping %d\n',
            tiltalign_SkewDefaultGrouping
         )
      )
   end
   if tiltalign_BeamTiltOption_use then
      command_file:write(string.format(
            'BeamTiltOption %d\n',
            tiltalign_BeamTiltOption
         )
      )
   end
   if tiltalign_ResidualReportCriterion_use then
      command_file:write(string.format(
            'ResidualReportCriterion %4.2f\n',
            tiltalign_ResidualReportCriterion
         )
      )
   end
   command_file:write(string.format(
         'SurfacesToAnalyze %d\n',
         tiltalign_SurfacesToAnalyze
      )
   )
   command_file:write(string.format(
         'MetroFactor %4.2f\n',
         tiltalign_MetroFactor
      )
   )
   command_file:write(string.format(
         'MaximumCycles %d\n',
         tiltalign_MaximumCycles
      )
   )
   command_file:write(string.format(
         'KFactorScaling %4.2f\n',
         tiltalign_KFactorScaling
      )
   )
   if tiltalign_AxisZShift_use then
      command_file:write(string.format(
            'AxisZShift %4.2f\n',
            tiltalign_AxisZShift
         )
      )
   end
   if tiltalign_ShiftZFromOriginal_use then
      command_file:write(string.format(
            'ShiftZFromOriginal \n'
         )
      )
   end
   if tiltalign_LocalAlignments_use then
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
            tiltalign_MinSizeOrOverlapXandY
         )
      )
      command_file:write(string.format(
            'MinFidsTotalAndEachSurface %s\n',
            tiltalign_MinFidsTotalAndEachSurface
         )
      )
      if tiltalign_FixXYZCoordinates_use then
         command_file:write(string.format(
               'FixXYZCoordinates\n'
            )
         )
      end
      command_file:write(string.format(
            'LocalOutputOptions %s\n',
            tiltalign_LocalOutputOptions
         )
      )
      command_file:write(string.format(
            'LocalRotOption %d\n',
            tiltalign_LocalRotOption
         )
      )
      command_file:write(string.format(
            'LocalRotDefaultGrouping %d\n',
            tiltalign_LocalRotDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalTiltOption %d\n',
            tiltalign_LocalTiltOption
         )
      )
      command_file:write(string.format(
            'LocalTiltDefaultGrouping %d\n',
            tiltalign_LocalTiltDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalMagReferenceView %d\n',
            tiltalign_LocalMagReferenceView
         )
      )
      command_file:write(string.format(
            'LocalMagOption %d\n',
            tiltalign_LocalMagOption
         )
      )
      command_file:write(string.format(
            'LocalMagDefaultGrouping %d\n',
            tiltalign_LocalMagDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalXStretchOption %d\n',
            tiltalign_LocalXStretchOption
         )
      )
      command_file:write(string.format(
            'LocalXStretchDefaultGrouping %d\n',
            tiltalign_LocalXStretchDefaultGrouping
         )
      )
      command_file:write(string.format(
            'LocalSkewOption %d\n',
            tiltalign_LocalSkewOption
         )
      )
      command_file:write(string.format(
            'LocalSkewDefaultGrouping %d\n',
            tiltalign_LocalSkewDefaultGrouping
         )
      )
      command_file:write(string.format(
            'NumberOfLocalPatchesXandY %s\n',
            tiltalign_NumberOfLocalPatchesXandY
         )
      )
      command_file:write(string.format(
            'OutputZFactorFile %s.zfac\n',
            basename
         )
      )
      if tiltalign_RobustFitting_use then
         command_file:write(string.format(
               'RobustFitting\n'
            )
         )
      end
   end
   command_file:close()
end

--[[===========================================================================#
#                               write_xfproduct                                #
#------------------------------------------------------------------------------#
# Write the command file to run xfproduct.                                     #
#===========================================================================--]]
local function write_xfproduct(input_filename)
   local basename = string.sub(input_filename, 1, -4)
   local command_filename = string.format(
      '%s_xfproduct.com',
      basename
   )
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

--[[===========================================================================#
#                                write_newstack                                #
#------------------------------------------------------------------------------#
# Write the command file to run newstack for the final alignment.              #
#===========================================================================--]]
local function write_newstack(input_filename)
   local basename = string.sub(input_filename, 1, -4)
   local command_filename = string.format(
      '%s_newstack.com',
      basename
   )
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
         newstack_TaperAtFill
      )
   )
   if newstack_AdjustOrigin_use then
      command_file:write(string.format(
            'AdjustOrigin\n'
         )
      )
   end
   command_file:write(string.format(
         'OffsetsInXandY %s\n',
         newstack_OffsetsInXandY
      )
   )
   if newstack_DistortionField_use then
      command_file:write(string.format(
            'DistortionField %s.idf\n',
            basename
         )
      )
   end
   command_file:write(string.format(
         'ImagesAreBinned %d\n',
         newstack_ImagesAreBinned
      )
   )
   command_file:write(string.format(
         'BinByFactor %d\n',
         newstack_BinByFactor
      )
   )
   if newstack_GradientFile_use then
      command_file:write(string.format(
            'GradientFile %s.maggrad\n',
            basename
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                               write_ctfplotter                               #
#------------------------------------------------------------------------------#
# Write a command file to run ctfplotter.                                      #
#===========================================================================--]]
local function write_ctfplotter(input_filename, header)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_ctfplotter.com',
      basename
   )
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
   if ctfplotter_InvertTiltAngles_use then
      command_file:write(string.format(
            'InvertTiltAngles\n'
         )
      )
   end
   command_file:write(string.format(
         'OffsetToAdd %s\n',
         ctfplotter_OffsetToAdd
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
         ctfplotter_AngleRange
      )
   )
   command_file:write(string.format(
         'AutoFitRangeAndStep %s\n',
         ctfplotter_AutoFitRangeAndStep
      )
   )
   command_file:write(string.format(
         'Voltage %s\n',
         ctfplotter_Voltage
      )
   )
   command_file:write(string.format(
         'SphericalAberration %s\n',
         ctfplotter_SphericalAberration
      )
   )
   command_file:write(string.format(
         'AmplitudeContrast %s\n',
         ctfplotter_AmplitudeContrast
      )
   )
   command_file:write(string.format(
         'DefocusTol %s\n',
         ctfplotter_DefocusTol
      )
   )
   command_file:write(string.format(
         'PSResolution %s\n',
         ctfplotter_PSResolution
      )
   )
   command_file:write(string.format(
         'TileSize %s\n',
         ctfplotter_TileSize
      )
   )
   command_file:write(string.format(
         'LeftDefTol %s\n',
         ctfplotter_LeftDefTol
      )
   )
   command_file:write(string.format(
         'RightDefTol %s\n',
         ctfplotter_RightDefTol
      )
   )
   if header.file_type == 'Fei' then
      ctfplotter_ConfigFile = string.format(
         '%s%s',
         '/usr/local/ImodCalib/CTFnoise',
         '/CCDbackground/polara-CCD-2012.ctg'
      )
      ctfplotter_FrequencyRangeToFit = '0.1 0.225'
   elseif header.nx > 3000 then
      ctfplotter_ConfigFile = string.format(
         '%s%s',
         '/usr/local/ImodCalib/CTFnoise',
         '/K24Kbackground/polara-K2-4K-2014.ctg'
      )
      ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
   else
      ctfplotter_ConfigFile = ctfplotter_ConfigFile
      ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
   end
   command_file:write(string.format(
         'ConfigFile %s\n',
         ctfplotter_ConfigFile
      )
   )
   command_file:write(string.format(
         'FrequencyRangeToFit %s\n',
         ctfplotter_FrequencyRangeToFit
      )
   )
	if ctfplotter_VaryExponentInFit_use then
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

--[[===========================================================================#
#                               write_final_ctfplotter                         #
#------------------------------------------------------------------------------#
# Write a command file to run ctfplotter.                                      #
#===========================================================================--]]
function COM_file_lib.write_final_ctfplotter(input_filename, header)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_ctfplotter.com',
      basename
   )
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
   if ctfplotter_InvertTiltAngles_use then
      command_file:write(string.format(
            'InvertTiltAngles\n'
         )
      )
   end
   command_file:write(string.format(
         'OffsetToAdd %s\n',
         ctfplotter_OffsetToAdd
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
         ctfplotter_AngleRange
      )
   )
   command_file:write(string.format(
         'Voltage %s\n',
         ctfplotter_Voltage
      )
   )
   command_file:write(string.format(
         'SphericalAberration %s\n',
         ctfplotter_SphericalAberration
      )
   )
   command_file:write(string.format(
         'AmplitudeContrast %s\n',
         ctfplotter_AmplitudeContrast
      )
   )
   command_file:write(string.format(
         'DefocusTol %s\n',
         ctfplotter_DefocusTol
      )
   )
   command_file:write(string.format(
         'PSResolution %s\n',
         ctfplotter_PSResolution
      )
   )
   command_file:write(string.format(
         'TileSize %s\n',
         ctfplotter_TileSize
      )
   )
   command_file:write(string.format(
         'LeftDefTol %s\n',
         ctfplotter_LeftDefTol
      )
   )
   command_file:write(string.format(
         'RightDefTol %s\n',
         ctfplotter_RightDefTol
      )
   )
   if header.file_type == 'Fei' then
      ctfplotter_ConfigFile = string.format(
         '%s%s',
         '/usr/local/ImodCalib/CTFnoise',
         '/CCDbackground/polara-CCD-2012.ctg'
      )
      ctfplotter_FrequencyRangeToFit = '0.1 0.225'
   elseif header.nx > 3000 then
      ctfplotter_ConfigFile = string.format(
         '%s%s',
         '/usr/local/ImodCalib/CTFnoise',
         '/K24Kbackground/polara-K2-4K-2014.ctg'
      )
      ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
   else
      ctfplotter_ConfigFile = ctfplotter_ConfigFile
      ctfplotter_FrequencyRangeToFit = ctfplotter_FrequencyRangeToFit
   end
   command_file:write(string.format(
         'ConfigFile %s\n',
         ctfplotter_ConfigFile
      )
   )
   command_file:write(string.format(
         'FrequencyRangeToFit %s\n',
         ctfplotter_FrequencyRangeToFit
      )
   )
	if ctfplotter_VaryExponentInFit_use then
      command_file:write(string.format(
            'VaryExponentInFit\n'
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                              write_ctfphaseflip                              #
#------------------------------------------------------------------------------#
# A function to write the command file to run ctfphaseflip.                    #
#===========================================================================--]]
local function write_ctfphaseflip(input_filename, header)
	local basename = string.sub(input_filename,1, -4)
	local command_filename = string.format(
      '%s_ctfphaseflip.com',
      basename
   )
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
   if ctfphaseflip_InvertTiltAngles_use then
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
         ctfphaseflip_Voltage
      )
   )
   command_file:write(string.format(
         'SphericalAberration %s\n',
         ctfphaseflip_SphericalAberration
      )
   )
   command_file:write(string.format(
         'DefocusTol %s\n',
         ctfphaseflip_DefocusTol
      )
   )
   command_file:write(string.format(
         'PixelSize %s\n',
         header.pixel_size
      )
   )
   command_file:write(string.format(
         'AmplitudeContrast %s\n',
         ctfphaseflip_AmplitudeContrast
      )
   )
   command_file:write(string.format(
         'InterpolationWidth %s\n',
         ctfphaseflip_InterpolationWidth
      )
   )
   command_file:close()
end

--[[===========================================================================#
#                             write_gold_ccderaser                             #
#------------------------------------------------------------------------------#
# A function to write the command file to run ccderaser to erase gold.         #
#===========================================================================--]]
local function write_gold_ccderaser(input_filename)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_gold_ccderaser.com',
      basename
   )
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
         gold_ccderaser_CircleObjects
      )
   )
   command_file:write(string.format(
         'BetterRadius %s\n',
         gold_ccderaser_BetterRadius
      )
   )
   if gold_ccderaser_MergePatches_use then
      command_file:write(string.format(
            'MergePatches\n'
         )
      )
   end
   command_file:write(string.format(
         'PolynomialOrder %s\n',
         gold_ccderaser_PolynomialOrder
      )
   )
   if gold_ccderaser_ExcludeAdjacent_use then
      command_file:write(string.format(
            'ExcludeAdjacent\n'
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                                  write_tilt                                  #
#------------------------------------------------------------------------------#
# A function to write the command file to run tilt.                            #
#===========================================================================--]]
local function write_tilt(input_filename, header, options_table)
	local basename = string.sub(input_filename, 1, -4)
	local command_filename = string.format(
      '%s_tilt.com',
      basename
   )
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
         tilt_ActionIfGPUFails
      )
   )
	if tilt_AdjustOrigin_use then
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
	if tilt_LOG_use then
      command_file:write(string.format(
            'LOG %s\n',
            tilt_LOG
         )
      )
   end
   command_file:write(string.format(
         'MODE %s\n',
         tilt_MODE
      )
   )
	if tilt_OFFSET_use then
      command_file:write(string.format(
            'OFFSET %s\n',
            tilt_OFFSET
         )
      )
   end
	if tilt_PARALLEL_use then
      command_file:write(string.format(
            'PARALLEL\n'
         )
      )
	elseif tilt_PERPENDICULAR_use then
      command_file:write(string.format(
            'PERPENDICULAR \n'
         )
      )
	else
      error(string.format(
            'Error! Please make sure either PARALLEL or PERPENDICULAR\n\z
            is chosen in the configuration command_file not both!\n'
         ), 0
      )
   end
   command_file:write(string.format(
         'RADIAL %s\n',
         tilt_RADIAL
      )
   )
   command_file:write(string.format(
         'SCALE %s\n',
         tilt_SCALE
      )
   )
   command_file:write(string.format(
         'SHIFT %s\n',
         tilt_SHIFT
      )
   )
	if tilt_SLICE_use then
      command_file:write(string.format(
            'SLICE %s\n',
            tilt_SLICE
         )
      )
   end
   if tilt_SUBSETSTART_use then
      command_file:write(string.format(
            'SUBSETSTART %s\n',
            tilt_SUBSETSTART
         )
      )
   end
   if options_table.z_ then
      tilt_THICKNESS = options_table.z_
   end
   command_file:write(string.format(
         'THICKNESS %s\n',
         tilt_THICKNESS
      )
   )
   command_file:write(string.format(
         'TILTFILE %s.tlt\n',
         basename
      )
   )
   if options_table.g then
      tilt_UseGPU_use, tilt_UseGPU = true, 0
   end
	if tilt_UseGPU_use then
      command_file:write(string.format(
            'UseGPU %s\n',
            tilt_UseGPU
         )
      )
   end
	if tilt_WIDTH_use then
      command_file:write(string.format(
            'WIDTH %s\n',
            tilt_WIDTH
         )
      )
   end
   if tilt_LOCALFILE_use then
      command_file:write(string.format(
            'LOCALFILE %slocal.xf\n',
            basename
         )
      )
   end
	if tilt_XAXISTILT_use then
      command_file:write(string.format(
            'XAXISTILT %s\n',
            tilt_XAXISTILT
         )
      )
   end
	if tilt_XTILTFILE_use then
      command_file:write(string.format(
            'XTILTFILE %s.xtilt\n',
            basename
         )
      )
   end
   if tilt_ZFACTORFILE_use then
      command_file:write(string.format(
            'ZFACTORFILE %s.zfac\n',
            basename
         )
      )
   end
   command_file:close()
end

--[[===========================================================================#
#                                    write                                     #
#------------------------------------------------------------------------------#
# A function that uses all of the above local functions and writes all of the  #
# command files needed to process a tilt series.                               #
#------------------------------------------------------------------------------#
# Author:  Dustin Morado                                                       #
# Written: February 28th 2014                                                  #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#===========================================================================--]]
function COM_file_lib.write(input_filename, header, options_table)
   if options_table.l_ then
      localConfig = loadfile(options_table.l_)
      if localConfig then
         localConfig()
      end
   end

   write_ccderaser(input_filename)
   write_tiltxcorr(input_filename, header)
   write_xftoxg(input_filename)
   write_prenewstack(input_filename)
   write_RAPTOR(input_filename, header)
   write_beadtrack(input_filename, header)
   write_tiltalign(input_filename, header)
   write_xfproduct(input_filename)
   write_newstack(input_filename)
   write_gold_ccderaser(input_filename)
   if options_table.c then
      write_ctfplotter(input_filename, header)
      write_ctfphaseflip(input_filename, header)
   end
   if not options_table.t then
      write_tilt(input_filename, header, options_table)
   end
end

--[[===========================================================================#
#                             write_reconstruction                             #
#------------------------------------------------------------------------------#
# A function that uses the above local functions and writes all of the command #
# files needed to only reconstruct an aligned tilt series.                     #
#------------------------------------------------------------------------------#
# Author:  Dustin Morado                                                       #
# Written: June 11th 2014                                                      #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#===========================================================================--]]
function COM_file_lib.write_reconstruction(
   input_filename,
   header,
   options_table
)
   if options_table.l_ then
      localConfig = loadfile(options_table.l_)
      if localConfig then
         localConfig()
      end
   end
   write_gold_ccderaser(input_filename)
   if options_table.c then
      write_ctfphaseflip(input_filename, header)
   end
   if not options_table.t then
      write_tilt(input_filename, header, options_table)
   end
end

return COM_file_lib