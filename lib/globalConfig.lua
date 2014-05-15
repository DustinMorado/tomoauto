--[[==========================================================================# 
#                               globalConfig.lua                              #
#-----------------------------------------------------------------------------#
# This is the central configuration file for eTomo_auto it is a long file     #
# and it has been attempted at great lengths to document this file as         #
# completely as possible; however, if you have any more questions, please     #
# refer to the manpages of the desired program. This file is organized in the # 
# manner in which eTomo_auto is run.  The defaults in this file are from the  #
# defaults in eTomo and not necessarily the ones in the specific man pages.   #
#==========================================================================--]]
--[[==========================================================================#
# Step 1: Pre-Processing                                                      #
#-----------------------------------------------------------------------------#
# Commands: ccderaser                                                         #
#==========================================================================--]]
-- These are the options for the ccderaser command used for pre-processing to
-- remove x-ray abnormalities on the CCD camera.

-- PeakCriterion: 
-- Number of standard deviations above local mean for erasing peak based on
-- intensity.
ccderaserPeakCriterion  =  10.0

-- DiffCriterion:
-- Number of standard deviations above mean pixel-to-pixel difference for
-- erasing a peak based on these differences.
ccderaserDiffCriterion  =  8.0

-- GrowCriterion:
-- Number of standard deviations above mean for adding points to the peak.
ccderaserGrowCriterion  =  4.0

-- ScanCriterion:
-- Number of standard deviations above the mean of the scan area used to pick
-- out possible peaks initially.
ccderaserScanCriterion  =  3.0

-- MaximumRadius:
-- Maximum radius of peak area to erase.
ccderaserMaximumRadius = 4.2

-- AnnulusWidth:
-- Difference between outer and inner radius of the annulus around a peak in
-- which to calculate local mean and standard deviation.
ccderaserAnnulusWidth = 2.0

-- XYScanSize:
-- Size of regions to compute mean and standard deviation in for initial scans.
ccderaserXYScanSize = 100

-- EdgeExclusionWidth:
-- Width of area to exclude on all edges of image in pixels.
ccderaserEdgeExclusionWidth = 4

-- BorderSize:
-- Size of border around points in patch, which contains the points which will
-- be fit to.
ccderaserBorderSize = 2

-- PolynomialOrder:
-- Order of polynomial fit to border points. The order can be between 0 and 3,
-- where 0 will simply replace the pixels with the mean of the border points
-- instead of fitting to them.
ccderaserPolynomialOrder = 2

-- BigDiffCriterion:
-- An extra-large peak will be erased only if the value for the maximum
-- difference between adjacent pixels, averaged over the most extreme one-fourth
-- of the pixels in the patch, exceeds this criterion, evaluated as the number
-- of SDs above the mean absolute difference between adjacent pixels in the scan
-- area.
ccderaserBigDiffCriterion = 19.0

-- GiantCriterion:
-- Criterion # of SDs above local mean for erasing extra-large peak based on
-- intensity. 
ccderaserGiantCriterion = 12.0

-- ExtraLargeRadius:
-- Maximum radius of extra-large peak area to erase.
ccderaserExtraLargeRadius = 8.0

--[[==========================================================================#
# Step 2: Coarse Alignment                                                    #
#-----------------------------------------------------------------------------#
# Commands: tiltxcorr, newstack                                               #
#==========================================================================--]]
-- These are the options for the tiltxcorr command used to calculate the 
-- cross-correlation to create initial transformations for the coarse alignment.

-- AngleOffset:
-- Amount to add to all entered tilt angles. If the specimen is significantly
-- tilted at zero tilt, then the amount of cosine stretching become inaccurate
-- at high tilt. Sharper correlations can be obtained by adding this angle
-- offset, which is the same as the offset needed in Tiltalign or Tilt to make
-- the specimen flat in the reconstruction.
tiltxcorrAngleOffset = 0.0

-- FilterRadius2:
-- High spatial frequencies in the cross-correlation will be attenuated by a
-- Gaussian curve that is 1 at this cutoff radius and falls off above this
-- radius with a standard deviation specified by FilterSigma2.
tiltxcorrFilterRadius2 = 0.25

-- FilterSigma1:
-- Sigma value to filter low frequencies in the correlations with a frequency
-- and decays up to 1 with the given sigma value.  
tiltxcorrFilterSigma1 = 0.03

-- FilterSigma2:
-- Sigma value for the Gaussian rolloff below and above the cutoff frequencies
-- specified by FilterRadius1 and FilterRadius2.
tiltxcorrFilterSigma2 = 0.05

-- ExcludeCentralPeak:
-- Exclude central correlation peak due to fixed pattern noise in the images.
-- This option will misalign images that are already nearly aligned.
tiltxcorrExcludeCentralPeak = nil

-- BordersInXandY:
-- Number of pixels to trim off each edge in X and in Y (the default is to use
-- the whole image).
tiltxcorrBordersInXandY_use = nil
tiltxcorrBordersInXandY = "0 0"

-- XMinAndMax:
-- Starting and ending X coordinates of a region to correlate, based on the
-- position of the region at zero tilt.  This entry will override an X border
-- value entered with BordersInXandY.
tiltxcorrXMinAndMax_use = nil
tiltxcorrXMinAndMax = "0 0"

-- YMinAndMax:
-- Starting and ending Y coordinates of a region to correlate. This entry will
-- override a Y border value entered with BordersInXandY.
tiltxcorrYMinAndMax_use = nil
tiltxcorrYMinAndMax = "0 0"

-- PadsInXandY:
-- Number of pixels to pad images in X and in Y. The default is 5% of the image
-- dimensions up to 20 pixels.
tiltxcorrPadsInXandY_use = nil
tiltxcorrPadsInXandY = "20 20" 

-- TapersInXandY: Number of pixels to taper images in X and Y. The default is 10%
-- of the image dimensions up to 100 pixels.
tiltxcorrTapersInXandY_use = nil
tiltxcorrTapersInXandY = "100 100"

-- StartingEndingViews:
-- Starting and ending view numbers, numbered from 1, for doing a subset of
-- views.
tiltxcorrStartingEndingViews_use = nil
tiltxcorrStartingEndingViews = "1 129"
 
-- CumulativeCorrelation:
-- Use this option to add up previously aligned pictures to get the reference
-- for the next alignment. Alignments will start at low tilt and work up to high
-- tilt.
tiltxcorrCumulativeCorrelation = nil

-- AbsoluteCosineStretch:
-- Stretch each image added into the cumulative sum by 1 over the cosine of its
-- tilt angle.
tiltxcorrAbsoluteCosineStretch = nil

-- NoCosineStretch:
-- Do not do any cosine stretching for correlations or for accumulating into the
-- reference (this option overrides AbsoluteCosineStretch).
tiltxcorrNoCosineStretch = nil

-- TestOutput:
-- Specify a filename with this option to have two padded, tapered images and
-- the cross-correlation saved for every pair of images that are correlated.
tiltxcorrTestOutput = nil

-- These are the options for the xftoxg command used to take a list of xf
-- transformations and generates a list of xg xforms to apply to align the
-- sections.

-- NumberToFit:
-- Number of adjacent sections to fit, 0 for global alignment, or 1 for fit to
-- all sections
xftoxgNumberToFit = 0

-- ReferenceSection:
-- Do a global alignment to the given section; this will give the reference
-- section a unit transform and keep it from being transformed. Sections are
-- numbered from 1.
xftoxgReferenceSection_use = nil
xftoxgReferenceSection = 64

-- OrderOfPolynomialFit:
-- Order of the polynomial fit to the data. The default is 1 (linear fit).
xftoxgOrderOfPolynomialFit_use = nil
xftoxgOrderOfPolynomialFit = 1

-- HybridFits:
-- Number of parameters to eliminate trends for with a hybrid alignment: 2 for
-- translations only, 3 for rotations also, 4 for size changes also.
xftoxgHybridFits_use = nil
xftoxgHybridFits = 2

-- RangeOfAnglesInAverage:
-- Compute the global average center position, and the center position for local
-- fits, using the largest group of sections whose rotation angles fall within
-- the given range.
xftoxgRangeOfAnglesInAverage_use = nil
xftoxgRangeofAnglesInAverage = 20.0

-- These are the options for the newstack command to apply the xforms produced
-- and create a new image stack.

-- ModeToOutput:
-- The storage mode of the output file; 0 for byte, 1 for 16-bit signed integer,
-- 6 for 16-bit unsigned integer, or 2 for 32-bit floating point. The default is
-- the mode of the first input file.
prenewstackModeToOutput_use = nil
prenewstackModeToOutput = 6

-- BinByFactor: 
-- Use oridinary binning to reduce images in size by the given factor, or use
-- antialias filtering to reduce images by this factor.
prenewstackBinByFactor = 1

-- ImagesAreBinned:
-- The current binning of the images, so that the distortion field can be
-- applied correctly.
prenewstackImagesAreBinned = 1

-- LinearInterpolation:
-- Use linear instead of cubic interpolation to transform images. Linear
-- interpolation is more suitable when images are very noisy, but cubic
-- interpolation will preserve fine detail better when noise is not an issue.
prenewstackLinearInterpolation_use = nil

-- FloatDensities:
-- Adjust densities of sections individually.  Enter 1 for each section to fill
-- the data range, 2 to scale sections to common mean and standard deviation, 3
-- to shift sections to a common mean without scaling, or 4 to shift sections to
-- a common mean then rescale the minimum and maximum densities to the Min and
-- Max values specified with the -scale option.
prenewstackFloatDensities_use = nil
prenewstackFloatDensities = 2

-- ContrastBlackWhite:
-- Rescale densities to match the contrast seen in 3dmod with the given black
-- and white values. This works properly only when the output file will be
-- bytes. It will not work if the data were loaded into 3dmod with intensity
-- scaling; use mrcbyte in that case.
prenewstackContrastBlackWhite_use = nil
prenewstackContrastBlackWhite = "0 255"

-- ScaleMinAndMax:
-- Rescale the densities of all sections by the same factors so that the
-- original minimum and maximum density will be mapped to the Min and Max values
-- that are entered.
prenewstackScaleMinAndMax_use = nil
prenewstackScaleMinAndMax = "0 255"

--[[==========================================================================#
# Step 3: RAPTOR automated fiducial model algorithm                           #
#-----------------------------------------------------------------------------#
# Commands: RAPTOR                                                            #
#==========================================================================--]]
-- These are the options for the RAPTOR command used to automatically create
-- a gold tracking model and then align the model.

-- RaptorExecPath:
-- Path where RAPTOR binaries are located (REQUIRED)
raptorExecPath = "/usr/local/IMOD/bin/realbin/"

-- AnglesInHeader:
-- If this option is specified, RAPTOR will extract tilt angles from the header
-- of the input stack. Otherwise RAPTOR requires a .rawtlt file.
raptorAnglesInHeader_use = true

-- Markers:
-- This is the most critical parameter. Here it is set incredibly high, which
-- makes it run very slowly, you can try lowering it to see how fast you can
-- get it without many of the alignments failing.
raptorMarkersPerImage_use = nil
raptorMarkersPerImage = 50

-- Binning:
-- This option causes RAPTOR to bin the image stack before computing the
-- alignment. The binning does not affect the value of Diameter.
raptorBinning_use = nil
raptorBinning = 2

-- xRay:
-- if this option is specified long, straight line features will be attempted to
-- be removed to help the marker identification process.
raptorxRay_use = nil

--[[==========================================================================#
# Step 4: Alignment by use of fiducial model                                  #
#-----------------------------------------------------------------------------#
# Commands: tiltalign                                                         #
#==========================================================================--]]
-- These are the options for the tiltalign command that solves for the
-- displacements, rotations, tilts and magnification differences of a tilt 
-- series. 

-- ImagesAreBinned:
-- The current binning of the images relative to the original data.
tiltAlignImagesAreBinned = 1

-- AngleOffset:
-- Amount to add to all entered tilt angles.
tiltAlignAngleOffset_use = nil
tiltAlignAngleOffset = 0.0

-- RotOption:
-- Type of rotation solution: 0 for all rots fixed at initial angle
-- 1 for each view having an independent rotation; 2 to enter general mapping of
-- rotation variables; 3 or 4 for automapping; -1 single rotation variable
tiltAlignRotOption_use = true
tiltAlignRotOption = 1

-- RotDefaultGrouping:
-- Default group size when automapping rotation variables
tiltAlignRotDefaultGrouping_use = true
tiltAlignRotDefaultGrouping = 5

-- TiltOption:
-- Type of tilt angle solution. See tiltalign manual page.
tiltAlignTiltOption_use = true
tiltAlignTiltOption = 5

-- TiltDefaultGrouping:
-- Average default group size when automapping tilt variables
tiltAlignTiltDefaultGrouping_use = true
tiltAlignTiltDefaultGrouping =  5

-- MagReferenceView:
-- Number of reference view whose magnification whos magnification will be fixed
-- at 1.0
tiltAlignMagReferenceView_use = true
tiltAlignMagReferenceView = 1

-- MagOption:
-- Type of magnification solution. See tiltalign manual page.
tiltAlignMagOption_use = true
tiltAlignMagOption = 1

-- MagDefaultGrouping:
-- Default group size when automapping magnification
tiltAlignMagDefaultGrouping_use = true
tiltAlignMagDefaultGrouping = 4

-- XStretchOption: 
-- Type of X-stretch solution. See tiltalign manual page.
tiltAlignXStretchOption_use = true
tiltAlignXStretchOption = 3

-- SkewOption:
-- Type of skew solution. See tiltalign manual.
tiltAlignSkewOption_use = true
tiltAlignSkewOption = 3

-- XStretchDefaultGrouping: 
-- Default average group size when automapping X stretch variables.
tiltAlignXStretchDefaultGrouping_use = true
tiltAlignXStretchDefaultGrouping = 7

-- SkewDefaultGrouping:
-- Default group size when automapping skew variables
tiltAlignSkewDefaultGrouping_use = true
tiltAlignSkewDefaultGrouping = 11

-- BeamTiltOption:
-- Type of solution for non-perpendicularity between tilt axis and beam axis.
-- See tiltalign manual page.
tiltAlignBeamTiltOption_use = true
tiltAlignBeamTiltOption = 0

-- ResidualReportCriterion:
-- Criterion number of standard deviations above mean residual error that should
-- be reported.
tiltAlignResidualReportCriterion_use = true
tiltAlignResidualReportCriterion = 3.0

-- SurfacesToAnalyze:
-- 0, 1, or 2 to fit points to none, one or two surfaces. This entry has no
-- effect on the global alignment solution.
tiltAlignSurfacesToAnalyze = 2

-- MetroFactor:
-- How large the variable metric minimization step 
tiltAlignMetroFactor = 0.25

-- MaximumCycles:
-- Limit on the number of cycles for METRO
tiltAlignMaximumCycles = 1000

-- KFactorScaling:
-- Amount to scale the K factor that controls how many points are down-weighted
-- in the robust fitting.
tiltAlignKFactorScaling = 1.0

-- AxisZShift:
-- Amount to shift the tilt axis in Z, relative to the centroid in Z of the
-- fiducial points or relative to the original Z axis.
tiltAlignAxisZShift_use = true
tiltAlignAxisZShift = 0.0

-- ShiftZFromOriginal:
-- Apply Z shift relative to the original tilt axis location.
tiltAlignShiftZFromOriginal_use = true

-- LocalAlignments:
-- Do alignments with subsets of points in local areas.
tiltAlignLocalAlignments_use = true

-- MinSizeOrOverlapXandY:
-- Either the minimum size of each patch in X and Y or the minimum fractional
-- overlap between patches.
tiltAlignMinSizeOrOverlapXandY = '0.5,0.5'

-- MinFidsTotalAndEachSurface:
-- Minimum total number of fiducials, and minimum present on each surface if two
-- surfaces are assumed.
tiltAlignMinFidsTotalAndEachSurface = '8,3'

-- FixXYZCoordinates:
-- Fix the coordinates of the fiducials at their values from the global
-- solution.
tiltAlignFixXYZCoordinates_use = nil

-- LocalOutputOptions:
-- These three entries control the output of results for each local alignment.
-- See tilt align manual page.
tiltAlignLocalOutputOptions = '1,0,1'

-- LocalRotOption:
-- Type of local rotation solution.
tiltAlignLocalRotOption = 3

-- LocalRotDefaultGrouping:
-- Default group size when automapping local rotation variables
tiltAlignLocalRotDefaultGrouping = 6

-- LocalTiltOption:
-- Type of local tilt angle solution; have same meanings as for global solution.
tiltAlignLocalTiltOption = 5

-- LocalTiltDefaultGrouping:
-- Average default group size when automapping local tilt variables.
tiltAlignLocalTiltDefaultGrouping = 6

-- LocalMagReferenceView:
-- Number of reference view whose local mag will be fixed at 1.0.
tiltAlignLocalMagReferenceView = 1

-- LocalMagOption:
-- Type of local magnification solution. Same as for global solution.
tiltAlignLocalMagOption = 3

-- LocalMagDefaultGrouping:
-- Default group size when automapping local magnification variables.
tiltAlignLocalMagDefaultGrouping = 7

-- LocalXStretchOption:
-- Type of local X-stretch solution. Same as for global solution.
tiltAlignLocalXStretchOption = 3

-- LocalXStretchDefaultGrouping:
-- Default average group size when automapping local X stretch variables.
tiltAlignLocalXStretchDefaultGrouping = 11

-- LocalSkewOption:
-- Type of local skew solution. Same as for global solution.
tiltAlignLocalSkewOption = 3

-- LocalSkewDefaultGrouping:
tiltAlignLocalSkewDefaultGrouping = 11

-- NumberOfLocalPatchesXandY:
-- Number of local patches in X and in Y in which to obtain a solution from the
-- fiducials located in that patch.
tiltAlignNumberOfLocalPatchesXandY = '5,5'

-- RobustFitting
-- Use a robust fitting method that gives less weight to points with residuals
-- higher than the median residuals, and no weight to the most extreme points.
tiltAlignRobustFitting_use = true

-- TODO: I need to fill these in before I push a release version

newstackTaperAtFill = '1,0'
newstackAdjustOrigin_use = true
newstackOffsetsInXandY = '0.0,0.0'
newstackDistortionField_use = nil
newstackImagesAreBinned = 1
newstackBinByFactor = 1
newstackGradientFile_use = nil

--[[==========================================================================#
# Step 4: CTF Correction                                                      #
#-----------------------------------------------------------------------------#
# Commands: CTFplotter, CTFphaseflip                                          #
#==========================================================================--]]
-- These are the options for the CTFplotter command used to estimate the      
-- defocus and CTF curve to later correct for phase flipping.

-- InvertTiltAngles:
-- Invert the sign of the tilt angles to compensate for a left-handed coordinate
-- system in the microscope.  When the sign of the tilt angles and the value of
-- the tilt axis rotation angle are such that reconstructions are generated with
-- inverted hand-edness, then this option is needed to keep power spectra for
-- off-center tiles from being shifted in the wrong direction.
ctfInvertTiltAngles_use = nil

-- OffsetToAdd:
-- A Floating point number such that the program must analyze data values where
-- 0 corresponds to no electrons recorded.  Use this option to specify a value
-- to add to your input stack that will make values positive and proportional to
-- recorded electrons.  The value will not be added to noise files; they are
-- required to be positive.
ctfOffsetToAdd = 0.0

-- ConfigFile:
-- The configure file specifies the noise files used to estimate the noise
-- floor, one file per line.  The files can be specified with either absolute
-- paths or with paths relative to the loca- tion of the configure file itself.
ctfConfigFile = '/usr/local/ImodCalib/CTFnoise/K2background/polara-K2-2013.ctg'

-- PSResolution:
-- The number of points over which CTF will be computed.  The Nyquist frequency
-- is divided into equal intervals delineated by these points.  The default is
-- 101.
ctfPSResolution = 101

-- TileSize:
-- The tile size each strip will be tessellated into.  The size is in pixels and
-- the tiles are square.  Each view is first divided into strips that are
-- considered to have constant defocus.  The deafult is 256.
ctfTileSize = 256

-- Voltage:
-- Microscope voltage in kV.
ctfVoltage = 300

-- SphericalAberration:
-- Microscope spherical aberration in millimeters
ctfSphericalAberration = 2.0

-- DefocusTol:
-- Defocus tolerance in nanometers defining the center strips.  The center
-- strips are taken from the central region of a view that has defocus
-- difference less than this tolerance.  These kind of center strips from all
-- views within AngleRange are considered to have a constant defocus and are
-- used to compute the initial CTF after being further tessellated into tiles.
-- The default is 200.
ctfDefocusTol = 200

-- AmplitudeContrast:
-- The fraction of amplitude contrast. For Cryo-EM, it should be between 0.07
-- and 0.14.  The default is 0.07.
ctfAmplitudeContrast = 0.07

-- LeftDefTol:
-- Defocus tolerance in nanometers for strips to the left of the center strip.
-- When non-center strips are included in the aver- age, strips to the left of
-- center are included if their defocus difference is less than the given value.
-- The default is 2000.
ctfLeftDefTol = 2000

-- RightDefTol:
-- Defocus tolerance in nanometers for strips to the right of the center strip.
-- When non-center strips are included in the aver- age, strips to the right of
-- center are included if their defocus difference is less than the given value.
-- The default is 2000.
ctfRightDefTol = 2000

-- AngleRange:
-- When -autoFit is entered, this entry sets the extent over which steps will be
-- taken in autofitting.
ctfAngleRange = '-40.0 40.0'

-- AutoFitRangeAndStep:
-- Do initial autofitting over the whole tilt series with the given range of
-- angles and step size between ranges.  A value of zero for the step will make
-- it fit to each single image separate, regardless of the value for the range.
-- This autofitting differs from that invoked through the Angles dialog in
-- several respects: 1) All tiles will be used for fits; the "All tiles" radio
-- button will be selected at the end. 2) Three fitting iterations will be done,
-- with the expected defocus used the first time and the cur- rent defocus
-- estimate used for the next two iterations.  3) The size of the range is
-- determined by the parameter entered here, not by the starting and ending
-- angles entered with the -range option.
ctfAutoFitRangeAndStep = '10.0 10.0'

-- FrequencyRangeToFit:
-- Starting and ending frequencies of range to fit in power spec- trum.  The two
-- values will be used to set the "X1 starts" and "X2 ends" fields in the
-- fitting dialog.
ctfFrequencyRangeToFit = '0.05 0.225'

-- VaryExponentInFit:
-- Vary exponent of CTF function when fitting a CTF-like curve
ctfVaryExponentInFit_use = 1

-- SaveAndExit:
-- Save defocus values to file and exit after autofitting.  The program will not
-- ask for confirmation before removing existing entries in the defocus table.
-- This is mandatory for automation

-- These are the options for the ctfphaseflip command to correct the CTF

-- InterpolationWidth:
-- The distance in pixels between the center lines of two consecu- tive strips.
-- A pixel inside the region between those two center lines resides in both
-- strips. As the two strips are corrected separately, that pixel will have 2
-- corrected values. The final value for that pixel is a linear interpolation of
-- the 2 cor- rected values.
ctfInterpolationWidth = 20
 
--[[==========================================================================#
# Step 5: Erase Gold                                                          #
#-----------------------------------------------------------------------------#
# Commands: model2point, point2model, ccderaser                               #
#==========================================================================--]]
-- These are the options for the model2point command used to make a point file
-- of the model 

-- FloatingPoint:
-- Output model coordinates as floating point; otherwise the nearest integer
-- value is output.
model2pointFloatingPoint_use = nil

-- ScaledCoordinates:
-- Output coordinates in model coordinate system, scaled by the pixel size and
-- offset by origin values.  The default is to output index coordinates
-- corresponding to the pixel coordinates in the image.
model2pointScaledCoordinates_use = 1

-- ObjectAndContour:
-- Output object and contour numbers for each point (numbered from 1)
model2pointObjectAndContour_use = 1

-- Contour:
-- Output contour number for each point (numbered from 1)
model2pointContour_use = nil

-- NumberedFromZero:
-- Output object and contour numbers starting from 0 instead of 1
model2pointNumberedFromZero_use = nil

-- These are the options for the point2model command used to make a model file
-- from the just generated point file

-- OpenContours:
-- The default is to make all objects be closed contour type.  This option and
-- -scat can be used to make all objects be open or scattered, respectively.
point2modelOpenContours_use = nil

-- ScatteredPoints:
-- Make objects be scattered point type
point2modelScatteredPoints_use = 1

-- PointsPerContour:
-- Maximum number of points per contour.  The default is to put all points into
-- one contour.  This option is not allowed if the point file has contour
-- numbers.
point2modelPointsPerContour_use = nil
point2modelPointsPerContour = 1

-- PlanarContours:
-- Start a new contour at each new Z value encountered when reading sequentially
-- through the lines of input.  This option is not allowed if the point file has
-- contour numbers.
point2modelPlanarContours_use = nil

-- NumberedFromZero:
-- Objects and contours are numbered from 0 instead of 1
point2modelNumberedFromZero_use = nil

-- CircleSize:
-- Turn on display of circles of this size (radius) at each point.  If the
-- points form open contours that progress through Z, this option will let you
-- see them in the Zap window of 3dmod without having to edit the object.
point2modelCircleSize = 3

-- SphereRadius:
-- Turn on display of spheres of this radius at each point.  Use this option to
-- see scattered points in 3dmod without having to edit the object.
point2modelSphereRadius_use = 1 point2modelSphereRadius = 2

-- ColorOfObject:
-- Color to make an object; enter red, green, and blue values ranging from 0 to
-- 255.  To assign colors to multiple objects, enter this option multiple times.
-- (Successive entries accumulate)
point2modelColorOfObject = "0 255 0"

-- These are the options for the ccderaser command used to erase the fiducial
-- markers from the aligned stack

-- CircleObjects:
-- List of objects that contain scattered points for replacing pixels within a
-- circle around each point.  The sphere radius, which can be an individual
-- value for each point, is used to indicate the size of circle to replace.
-- Ranges can be entered, and / to specify all objects.
gccderaserCircleObjects = "/"

-- BetterRadius:
-- For circle objects, this entry specifies a radius to use for points without
-- an individual point size instead of the object's default sphere radius.  This
-- entry is floating point and can be used to overcome the limitations of having
-- an integer default sphere radius.  If there are multiple circle objects,
-- enter one value to apply to all objects or a value for each object.
gccderaserBetterRadius = 13.25

-- MergePatches:
-- Merge patches in the model if they touch each other, as long as the resulting
-- patch is still within the maximum radius. Patches from objects with points to
-- be replaced on all sections are ignored. This option should be used if an
-- output model from automatic peak finding is modified and used as an input
-- model.
gccderaserMergePatches = 1

-- PolynomialOrder:
-- Order of polynomial fit to border points. The order can be between 0 and 3,
-- where 0 will simply replace the pixels with the mean of the border points
-- instead of fitting to them.
gccderaserPolynomialOrder = 0

-- ExcludeAdjacent:
-- Exclude points adjacent to patch points from the fit; in other words, compute
-- the polynomial fit to points that do not touch the ones being replaced.
gccderaserExcludeAdjacent = 1

--[[==========================================================================#
# Step 6: Tomogram Generation                                                 #
#-----------------------------------------------------------------------------# 
# Commands: tilt                                                              #
#==========================================================================--]]
-- These are the options for the tilt command used to create a tomographic
-- reconstruction from the R-weighted backprojection. It can be split and ran in
-- parallel on multiple CPUs or on the GPU.  

-- ActionIfGPUFails:
-- The action to take when the GPU cannot be used after being requested: 0 to
-- take no action, 1 to issue a warning prefixed with MESSAGE:, and 2 to exit
-- with an error.  Enter 2 numbers: the first for the action when the GPU is
-- requested by the UseGPU option; the second for the action when the GPU is
-- requested only by the environment variable IMOD_USE_GPU.
tiltActionIfGPUFails = "1, 2"

-- AdjustOrigin:
-- Adjust origin for shifts with the SHIFT option and size changes with WIDTH
-- and SLICES, and base the origin on that of the aligned stack.  With this
-- option, reconstructions in PERPENDICULAR mode of different size and location
-- will have congruent coordinate systems and will load models interchangeably.
-- In addition, reconstructions from different sized projection stacks will have
-- congruent coordinates provided that the origin was adjusted when making the
-- projection stack (e.g., with the -origin option to Newstack).  The default is
-- to produce legacy origin values that are not adjusted for these operations,
-- with the origin in X and Y in the center of the volume.
tiltAdjustOrigin_use = 1

-- FULLIMAGE:
-- Use this entry to specify the full size in X and Y of the original stack of
-- tilted views, so that a subset of the aligned stack can be handled properly
-- when using a global X-axis tilt or local alignments.
-- Now read from the header

-- IMAGEBINNED:
-- If the input images have been binned, this entry can be entered to specify
-- the binning and have various other dimensions scaled down by this factor.
-- Values entered with SHIFT, OFFSET, THICKNESS, WIDTH, FULLIMAGESIZE, SLICE,
-- and SUBSETSTART will be scaled. These entries thus do not need to be changed
-- when the input binning is changed.
tiltIMAGEBINNED = 1

-- LOG:
-- This entry allows one to generate a reconstruction using the logarithm of the
-- densities in the input file, with the entered value added before taking the
-- logarithm.
tiltLOG_use = 1 tiltLOG = 0.0

-- MODE:
-- This entry allows one to specify the data mode of the output file, which is 2
-- by default.  Be sure to use an appropriate SCALE entry so that data will be
-- scaled to the proper range.
tiltMODE = 1

-- OFFSET:
-- This entry can contain two numbers, DELANG and DELXX.  An offset of DELANG
-- degrees will be applied to all tilt angles.  DELANG positive rotates
-- reconstructed sections anticlockwise.  A DELXX entry indicates that the tilt
-- axis would be offset in a stack of full-sized projection images, cutting the
-- X-axis at  NX/2. + DELXX instead of NX/2.  The DELXX entry is optional and
-- defaults to 0 when omitted.  If the tilt axis is offset from the center
-- because the projection images are a non-centered subset of the full images,
-- use the SUBSETSTART entry instead.  If the projection images are a
-- non-centered subset with the tilt axis centered in them, then using this
-- entry together with SUBSETSTART and FULLIMAGE should produce a correct
-- result.
tiltOFFSET_use = nil tiltOFFSET = "0.0 0.0"

-- PARALLEL:
-- Output slices parallel to the plane of the zero tilt projection.  This option
-- cannot be used with direct writing of data to a single output file from
-- parallel Tilt runs.  It inverts the handedness of the reconstruction.
tiltPARALLEL_use = nil

-- PERPENDICULAR:
-- Output slices perpendicular to the plane of the specimen. This output is the
-- default since it corresponds to the way in which slices are computed.
if tiltPARALLEL_use then 
   tiltPERPENDICULAR_use = nil 
else 
   tiltPERPENDICULAR_use = 1 
end

-- RADIAL:
-- This entry controls low-pass filtering with the radial weighting function.The
-- radial weighting function is linear away from the origin out to the distance
-- in reciprocal space specified by the first value, followed by a Gaussian
-- fall-off with a s.d. (sigma) given by the second value. If the cutoff is
-- great than 1 the distances are interpreted as pixels in Fourier space;
-- otherwise they are treated as frequencies in cycles/pixel, which range from 0
-- to 0.5.
tiltRADIAL = "0.35 0.05"

-- SCALE:
-- With this entry, the values in the reconstruction will be scaled by adding
-- the first value then multiplying by the second one. The default is 0,1. After
-- the reconstruction is complete, the program will output the scale values that
-- would make the data range from 10 to 245.
tiltSCALE = "0.0 700.0"

-- SHIFT:
-- This entry allows one to shift the reconstructed slice in X or Z before it is
-- output.  If the X shift is positive, the slice will be shifted to the right,
-- and the output will contain the left part of the whole potentially
-- reconstructable area.  If the Z shift is positive, the slice is shifted
-- upward.  The Z entry is optional and defaults to 0 when omitted.
tiltSHIFT = "0.0 0.0"

-- SLICE:
-- Starting and ending slice number to reconstruct, and interval between slices.
-- The numbers refer to slices in the X/Z plane and correspond to Y coordinates
-- in the projection images.  Slices are numbered from 0.  The interval entry is
-- optional, must be positive, and defaults to 1 when omitted.
tiltSLICE_use = nil
tiltSLICE = "0 2048 1"

-- SUBSETSTART:
-- If the aligned stack contains a subset of the area in the original images,
-- and this area is not centered in X or a global X-axis tilt or local
-- alignments are being used, use this entry to enter the X and Y index
-- coordinates (numbered from 0) of the lower left corner of the subset within
-- the original images. A FULLIMAGE entry must also be included. If the aligned
-- stack is larger than the original images, use negative values.
tiltSUBSETSTART_use = nil
tiltSUBSETSTART = "0 0"

-- THICKNESS:
-- Thickness in Z of reconstructed volume, in pixels
tiltTHICKNESS = 1200

-- UseGPU:
-- Use the GPU (graphical processing unit) for computations if possible; enter 0
-- to use the best GPU on the system, or the number of a specific GPU (numbered
-- from 1).  The GPU can be used for all types of operations as long as there is
-- sufficient memory.
tiltUseGPU_use = nil
tiltUseGPU = 0

-- WIDTH:
-- The width of the output image; the default is the width of the input image.
tiltWIDTH_use = nil
tiltWIDTH = 2048

-- XAXISTILT:
-- This entry allows one to rotate the reconstruction around the X axis, so that
-- a section that appears to be tilted around the X axis can be made flat to fit
-- into a smaller volume.  The angle should be the tilt of the section relative
-- to the X-Y plane in an unrotated reconstruction. For example, if the
-- reconstruction extends 500 slices, and the section is 5 pixels below the
-- middle in the first slice and 5 pixels above the middle in the last slice,
-- the angle should be 1.1 (the arc sine of 10/500).
tiltXAXISTILT_use = nil
tiltXAXISTILT = 5.00

-- XTILTFILE:
-- Use this entry to specify a file containing a list of tilts to be applied
-- around the X axis for the individual views.  A global tilt specified by the
-- XAXISTILT entry, if any, will be subtracted from these tilts. If this file
-- contains all zeros, the program runs the same as if the file was not entered.
tiltXTILTFILE_use = nil
