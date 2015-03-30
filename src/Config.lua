--- tomoauto configuration.
--
-- @module Config
-- @author Dustin Morado
-- @license GPLv3
-- @release 0.2.20

local Config = {}

--- Extracts the basname from a file path
-- Removes the preceding file path as well as removes the final suffix
-- @tparam string filename file path
-- @treturn string file basename with path and final suffix removed
local get_basename = function(filename)
    local PATH_SEP = string.sub(package.config, 1, 1)
    local regex = '[^'..PATH_SEP..']*'..PATH_SEP
    local basename = string.gsub(filename, regex, '')
    basename = string.gsub(basename, '(.*)%.%w+$', '%1')
    return basename
end

local backup_if_exists = function(filename)
    local file = io.open(filename, 'r')
    if file then
        file:close()
        local backup_filename = filename..'.bak'
        local backup_file = io.open(backup_filename, 'r')
        if backup_file then
            backup_file:close()
            assert(os.execute('rm '..backup_filename))
        end
        assert(os.execute('mv '..filename..' '..backup_filename))
    end
end

local write_com_file = function(self, filename)
    local basename = get_basename(filename)
    local com_filename = basename..'_'..self.Name..'.com'
    backup_if_exists(com_filename)
    com_file = assert(io.open(com_filename, 'w'))
    com_file:write(self.CommandLine..'\n')
    for i = 1, #self.Lookup do
        local opt = self.Lookup[i]
        if self[opt].use then
            if type(self[opt].value) == 'function' then
                com_file:write(opt..'\t'..self[opt].value()..'\n')
            elseif type(self[opt].value) == 'table' then
                com_file:write(opt..'\t'..table.concat(self[opt].value, '\t')..
                    '\n')
            elseif self[opt].value then
                com_file:write(opt..'\t'..self[opt].value..'\n')
            else
                com_file:write(opt..'\n')
            end
        end
    end
    com_file:close()
end

local write_tomo3d = function(self, filename)
    local basename = get_basename(filename)
    local com_filename = basename..'_'..self.Name..'.sh'
    backup_if_exists(com_filename)
    com_file = assert(io.open(com_filename, 'w'))
    com_file:write(self.CommandLine..'\n')
    local com_string = self.Name..' '
    for i = 1, #self.Lookup do
        local opt = self.Lookup[i][1]
        if self[opt].use then
            com_string = com_string..self.Lookup[i][2]..' '
            if type(self[opt].value) == 'function' then
                com_string = com_string..self[opt].value()..' '
            elseif type(self[opt].value) == 'table' then
                com_string = com_string..'"'..table.concat(self[opt].value, ' ')
                    ..'" '
            elseif self[opt].value then
                com_string = com_string..self[opt].value..' '
            else
                com_string = com_string
            end
        end
    end
    com_string = com_string..'\n'
    com_file:write(com_string)
    com_file:close()
end

local write_MOTIONCORR = function(self, filename)
    local basename = get_basename(filename)
    local com_filename = basename..'_'..self.Name..'.sh'
    backup_if_exists(com_filename)
    com_file = assert(io.open(com_filename, 'w'))
    com_file:write(self.CommandLine..'\n')
    local com_string = self.Name..' '
    com_string = com_string..filename..' '
    for i = 1, #self.Lookup do
        local opt = self.Lookup[i][1]
        if self[opt].use then
            com_string = com_string..self.Lookup[i][2]..' '
            if type(self[opt].value) == 'function' then
                com_string = com_string..self[opt].value()..' '
            elseif type(self[opt].value) == 'table' then
                com_string = com_string..'"'..table.concat(self[opt].value, ' ')
                    ..'" '
            elseif self[opt].value then
                com_string = com_string..self[opt].value..' '
            else
                com_string = com_string
            end
        end
    end
    com_string = com_string..'\n'
    com_file:write(com_string)
    com_file:close()
end

local write_CTFFIND4 = function(self, filename)
    local basename = get_basename(filename)
    local com_filename = basename..'_'..self.Name..'.sh'
    backup_if_exists(com_filename)
    com_file = assert(io.open(com_filename, 'w'))
    com_file:write(self.CommandLine..' << EOF\n')
    for i = 1, #self.Lookup do
        local opt = self.Lookup[i]
        if self[opt].use then
            if type(self[opt].value) == 'function' then
                com_file:write(self[opt].value()..'\n')
            elseif self[opt].value then
                com_file:write(self[opt].value..'\n')
            else
                com_file:write('\n')
            end
        end
    end
    com_file:write('EOF\n')
    com_file:close()
end

Config.ccderaser = {
    Name = 'ccderaser',
    CommandLine = '$ccderaser -StandardInput',
    InputFile = {
        use   = true,
        value = function()
            return filename
        end
    },
    OutputFile = {
        use   = true,
        value = function()
            return basename..'_fixed.st'
        end
    },
    PieceListFile = {
        use   = false,
        value = nil
    },
    OverlapsForModel = {
        use   = false,
        value = nil
    },
    FindPeaks = {
        use   = true,
        value = nil
    },
    PeakCriterion = {
        use   = true,
        value = 10.0
    },
    DiffCriterion = {
        use   = true,
        value = 8.0
    },
    GrowCriterion = {
        use   = true,
        value = 4.0
    },
    ScanCriterion = {
        use   = true,
        value = 3.0
    },
    MaximumRadius = {
        use   = true,
        value = 4.2
    },
    GiantCriterion = {
        use   = true,
        value = 12.0
    },
    ExtraLargeRadius = {
        use   = true,
        value = 8.0
    },
    BigDiffCriterion = {
        use   = true,
        value = 19.0
    },
    MaxPixelsInDiffPatch = {
        use   = false,
        value = nil
    },
    OuterRadius = {
        use   = false,
        value = nil
    },
    AnnulusWidth = {
        use   = true,
        value = 2.0
    },
    XYScanSize = {
        use   = true,
        value = 100
    },
    EdgeExclusionWidth = {
        use   = true,
        value = 4
    },
    PointModel = {
        use   = true,
        value = function()
            return basename..'_peak.mod'
        end
    },
    ModelFile = {
        use   = false,
        value = nil
    },
    LineObjects = {
        use   = false,
        value = nil
    },
    BoundaryObjects = {
        use   = false,
        value = nil
    },
    AllSectionObjects = {
        use   = false,
        value = nil
    },
    CircleObjects = {
        use   = false,
        value = nil
    },
    BetterRadius = {
        use   = false,
        value = nil
    },
    ExpandCircleIterations = {
        use   = false,
        value = nil
    },
    MergePatches = {
        use   = false,
        value = nil
    },
    BorderSize = {
        use   = true,
        value = 2
    },
    PolynomialOrder = {
        use   = true,
        value = 2
    },
    ExcludeAdjacent = {
        use   = false,
        value = nil
    },
    TrialMode = {
        use   = false,
        value = nil
    },
    Verbose = {
        use   = false,
        value = nil
    },
    ProcessID = {
        use   = false,
        value = nil
    },
    write = write_command_file,
}

Config.tiltxcorr = {
    Name = 'tiltxcorr',
    CommandLine = '$tiltxcorr -StandardInput',
    InputFile = {
		use   = true,
		value = function()
            return basename..'.st'
        end
    },
    PieceListFile = {
		use   = false,
		value = nil
	},
    OutputFile = {
		use   = true,
		value = function()
            return basename..'.prexf'
        end
    },
    RotationAngle = {
		use   = true,
		value = function()
            return Config.header.tilt_axis
        end
    },
    FirstTiltAngle = {
		use   = false,
		value = nil
	},
    TiltIncrement = {
		use   = false,
		value = nil
	},
    TiltFile = {
		use   = true,
		value = function()
            return basename..'.rawtlt'
        end
    },
    TiltAngles = {
		use   = false,
		value = nil
	},
    AngleOffset = {
		use   = false,
		value = nil
	},
    ReverseOrder = {
		use   = false,
		value = nil
	},
    FilterRadius1 = {
		use   = false,
		value = nil
	},
    FilterRadius2 = {
		use   = true,
		value = 0.25
    },
    FilterSigma1 = {
		use   = true,
		value = 0.03
    },
    FilterSigma2 = {
		use   = true,
		value = 0.05
    },
    ExcludeCentralPeak = {
		use   = false,
		value = nil
	},
    CentralPeakExclusionCriteria = {
		use   = false,
		value = nil
	},
    ShiftLimitsXandY = {
		use   = false,
		value = nil
	},
    RectangularLimits = {
		use   = false,
		value = nil
	},
    CorrelationCoefficient = {
		use   = false,
		value = nil
	},
    BordersInXandY = {
		use   = false,
		value = nil
	},
    XMinAndMax = {
		use   = false,
		value = nil
	},
    YMinAndMax = {
		use   = false,
		value = nil
	},
    BoundaryModel = {
		use   = false,
		value = nil
	},
    BoundaryObject = {
		use   = false,
		value = nil
	},
    BinningToApply = {
		use   = false,
		value = nil
	},
    AntialiasFilter = {
		use   = false,
		value = nil
	},
    LeaveTiltAxisShifted = {
		use   = false,
		value = nil
	},
    PadsInXandY = {
		use   = false,
		value = nil
	},
    TapersInXandY = {
		use   = false,
		value = nil
	},
    StartingEndingViews = {
		use   = false,
		value = nil
	},
    SkipViews = {
		use   = false,
		value = nil
	},
    BreakAtViews = {
		use   = false,
		value = nil
	},
    CumulativeCorrelation = {
		use   = false,
		value = nil
	},
    AbsoluteCosineStretch = {
		use   = false,
		value = nil
	},
    NoCosineStretch = {
		use   = false,
		value = nil
	},
    IterateCorrelations = {
		use   = false,
		value = nil
	},
    SearchMagChanges = {
		use   = false,
		value = nil
	},
    ViewsWithMagChanges = {
		use   = false,
		value = nil
	},
    MagnificationLimits = {
		use   = false,
		value = nil
	},
    SizeOfPatchesXandY = {
		use   = false,
		value = nil
	},
    NumberOfPatchesXandY = {
		use   = false,
		value = nil
	},
    OverlapPatchesXandY = {
		use   = false,
		value = nil
	},
    SeedModel = {
		use   = false,
		value = nil
	},
    SeedObject = {
		use   = false,
		value = nil
	},
    LengthAndOverlap = {
		use   = false,
		value = nil
	},
    PrealignmentTransformFile = {
		use   = false,
		value = nil
	},
    ImagesAreBinned = {
		use   = false,
		value = nil
	},
    UnalignedSizeXandY = {
		use   = false,
		value = nil
	},
    FindWarpTransforms = {
		use   = false,
		value = nil
	},
    RawAndAlignedPair = {
		use   = false,
		value = nil
	},
    AppendToWarpFile = {
		use   = false,
		value = nil
	},
    TestOutput = {
		use   = false,
		value = nil
	},
    VerboseOutput = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.xftoxg = {
    Name = 'xftoxg',
    CommandLine = '$xftoxg -StandardInput',
    InputFile = {
		use   = true,
		value = function()
            return basename..'.prexf'
        end
	},
    GOutputFile = {
		use   = true,
		value = function()
            return basename..'.prexg'
        end
	},
    NumberToFit = {
		use   = true,
		value = 0
	},
    ReferenceSection = {
		use   = false,
		value = nil
	},
    OrderOfPolynomialFit = {
		use   = false,
		value = nil
	},
    HybridFits = {
		use   = false,
		value = nil
	},
    RangeOfAnglesInAverage = {
		use   = false,
		value = nil
	},
    RobustFit = {
		use   = false,
		value = nil
	},
    KFactorScaling = {
		use   = false,
		value = nil
	},
    MaximumIterations = {
		use   = false,
		value = nil
	},
    IterationParams = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.prenewstack = {
    Name = 'prenewstack',
    CommandLine = '$newstack -StandardInput',
    InputFile = {
        use   = true,
		value = function()
            return basename..'.st'
        end
	},
    OutputFile = {
        use   = true,
		value = function()
            return basename..'.preali'
        end
	},
    FileOfInputs = {
		use   = false,
		value = nil
	},
    FileOfOutputs = {
		use   = false,
		value = nil
	},
    SplitStartingNumber = {
		use   = false,
		value = nil
	},
    AppendExtension = {
		use   = false,
		value = nil
	},
    SectionsToRead = {
		use   = false,
		value = nil
	},
    NumberedFromOne = {
		use   = false,
		value = nil
	},
    ExcludeSections = {
		use   = false,
		value = nil
	},
    TwoDirectionTiltSeries = {
		use   = false,
		value = nil
	},
    SkipSectionIncrement = {
		use   = false,
		value = nil
	},
    NumberToOutput = {
		use   = false,
		value = nil
	},
    ReplaceSections = {
		use   = false,
		value = nil
	},
    BlankOutput = {
		use   = false,
		value = nil
	},
    OffsetsInXandY = {
		use   = false,
		value = nil
	},
    ApplyOffsetsFirst = {
		use   = false,
		value = nil
	},
    TransformFile = {
		use   = true,
		value = function()
            return basename..'.prexg'
        end
	},
    UseTransformLines = {
		use   = false,
		value = nil
	},
    OneTrasformPerFile = {
		use   = false,
		value = nil
	},
    RotateByAngle = {
		use   = false,
		value = nil
	},
    ExpandByFactor = {
		use   = false,
		value = nil
	},
    ShrinkByFactor = {
		use   = false,
		value = nil
	},
    AntialiasFilter = {
		use   = false,
		value = nil
	},
    BinByFactor = {
		use   = false,
		value = nil
	},
    DistortionField = {
		use   = false,
		value = nil
	},
    ImagesAreBinned = {
		use   = false,
		value = nil
	},
    UseFields = {
		use   = false,
		value = nil
	},
    GradientFile = {
		use   = false,
		value = nil
	},
    AdjustOrigin = {
		use   = false,
		value = nil
	},
    LinearInterpolation = {
		use   = false,
		value = nil
	},
    NearestNeighbor = {
		use   = false,
		value = nil
	},
    SizeToOutputInXandY = {
		use   = false,
		value = nil
	},
    ModeToOutput = {
		use   = false,
		value = nil
	},
    BytesSignedInOutput = {
		use   = false,
		value = nil
	},
    StripExtraHeader = {
		use   = false,
		value = nil
	},
    FloatDensities = {
		use   = false,
		value = nil
	},
    MeanAndStandardDeviation = {
		use   = false,
		value = nil
	},
    ContrastBlackWhite = {
		use   = false,
		value = nil
	},
    ScaleMinAndMax = {
		use   = false,
		value = nil
	},
    MultiplyAndAdd = {
		use   = false,
		value = nil
	},
    FillValue = {
		use   = false,
		value = nil
	},
    TaperAtFill = {
		use   = false,
		value = nil
	},
    MemoryLimit = {
		use   = false,
		value = nil
	},
    TestLimits = {
		use   = false,
		value = nil
	},
    VerboseOutput = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.RAPTOR = {
    Name = 'RAPTOR',
    CommandLine = '$RAPTOR -StandardInput',
    RaptorExecPath = {
		use   = true,
		value = '/usr/local/IMOD/bin/realbin/'
	},
    InputPath = {
		use   = true,
		value = function()
            return lfs.currentdir()
        end
	},
    InputFile = {
		use   = true,
		value = function()
            return basename..'.preali'
        end
	},
    OutputPath = {
		use   = true,
		value = function()
            return lfs.currentdir()..'/'..basename..'_RAPTOR'
        end
	},
    Diameter = {
		use   = true,
		value = function()
            return Config.header.fiducial_diameter /
                Config.header.pixel_size * 10
        end
	},
    WhiteMarkers = {
		use   = false,
		value = nil
	},
    MarkersPerImage = {
		use   = false,
		value = nil
	},
    AnglesInHeader = {
		use   = true,
		value = nil
	},
    Binning = {
		use   = false,
		value = nil
	},
    Reconstruction = {
		use   = false,
		value = nil
	},
    Thickness = {
		use   = false,
		value = nil
	},
    Orient = {
		use   = false,
		value = nil
	},
    TrackingOnly = {
		use   = false,
		value = nil
	},
    xRay = {
		use   = false,
		value = nil
	},
    Verbose = {
		use   = false,
		value = nil
	},
    MaxDistanceCandidate = {
		use   = false,
		value = nil
	},
    MinNeighborsMRF = {
		use   = false,
		value = nil
	},
    RollOffMRF = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.autofidseed = {
    Name = 'autofidseed',
    CommandLine = '$autofidseed -StandardInput',
    TrackCommandFile = {
		use   = true,
		value = function()
            return basename..'_beadtrack.com'
        end
	},
    AppendToSeedModel = {
		use   = false,
		value = nil
	},
    MinGuessNumBeads = {
		use   = false,
		value = nil
	},
    MinSpacing = {
		use   = true,
		value = 0.85
	},
    BeadSize = {
		use   = false,
		value = nil
	},
    AdjustSizes = {
		use   = false,
		value = nil
	},
    PeakStorageFraction = {
		use   = true,
		value = 1.0
	},
    FindBeadOptions = {
		use   = false,
		value = nil
	},
    NumberOfSeedViews = {
		use   = false,
		value = nil
	},
    BoundaryModel = {
		use   = false,
		value = nil
	},
    ExcludeInsideAreas = {
		use   = false,
		value = nil
	},
    BordersInXandY = {
		use   = false,
		value = nil
	},
    TwoSurfaces = {
		use   = false,
		value = nil
	},
    TargetNumberOfBeads = {
		use   = true,
		value = 20
	},
    TargetDensityOfBeads = {
		use   = false,
		value = nil
	},
    MaxMajorToMinorRatio = {
		use   = false,
		value = nil
	},
    ElongatedPointsAllowed = {
		use   = false,
		value = nil
	},
    ClusteredPointsAllowed = {
		use   = false,
		value = nil
	},
    LowerTargetForClustered = {
		use   = false,
		value = nil
	},
    SubareaSize = {
		use   = false,
		value = nil
	},
    SortAreasMinNumAndSize = {
		use   = false,
		value = nil
	},
    IgnoreSurfaceData = {
		use   = false,
		value = nil
	},
    DropTracks = {
		use   = false,
		value = nil
	},
    PickSeedOptions = {
		use   = false,
		value = nil
	},
    RemoveTempFiles = {
		use   = false,
		value = nil
	},
    OutputSeedModel = {
		use   = false,
		value = nil
	},
    InfoFile = {
		use   = false,
		value = nil
	},
    TemporaryDirectory = {
		use   = false,
		value = nil
	},
    LeaveTempFiles = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.beadtrack = {
    Name = 'beadtrack',
    CommandLine = '$beadtrack -StandardInput',
    InputSeedModel = {
		use   = true,
		value = function()
            return basename..'.seed'
        end
	},
    OutputModel = {
		use   = true,
		value = function()
            return basename..'.fid'
        end
	},
    ImageFile = {
		use   = true,
		value = function()
            return basename..'.preali'
        end
	},
    PieceListFile = {
		use   = false,
		value = nil
	},
    PrealignTransformFile = {
		use   = true,
		value = function()
            return basename..'.prexg'
        end
	},
    ImagesAreBinned = {
		use   = false,
		value = nil
	},
    XYZOutputFile = {
		use   = false,
		value = nil
	},
    ElongationOuptutFile = {
		use   = false,
		value = nil
	},
    SkipViews = {
		use   = false,
		value = nil
	},
    RotationAngle = {
		use   = true,
		value = function()
            return Config.header.tilt_axis
        end
	},
    SeparateGroup = {
		use   = false,
		value = nil
	},
    FirstTiltAngle = {
		use   = false,
		value = nil
	},
    TiltIncrement = {
		use   = false,
		value = nil
	},
    TiltFile = {
		use   = true,
		value = function()
            return basename..'.rawtlt'
        end
	},
    TiltAngles = {
		use   = false,
		value = nil
	},
    TiltDefaultGrouping = {
		use   = true,
		value = 5
	},
    TiltNondefaultGrouping = {
		use   = false,
		value = nil
	},
    MagDefaultGrouping = {
		use   = true,
		value = 5
	},
    MagNondefaultGrouping = {
		use   = false,
		value = nil
	},
    RotDefaultGrouping = {
		use   = true,
		value = 1
	},
    RotNondefaultGrouping = {
		use   = false,
		value = nil
	},
    MinViewsForTiltalign = {
		use   = true,
		value = 4
	},
    CentroidRadius = {
		use   = false,
		value = nil
	},
    BeadDiameter = {
		use   = true,
		value = function()
            return Config.header.fiducial_diameter /
                Config.header.pixel_size * 10
        end
	},
    MedianForCentroid = {
		use   = false,
		value = nil
	},
    LightBeads = {
		use   = false,
		value = nil
	},
    FillGaps = {
		use   = true,
		value = nil
	},
    MaxGapSize = {
		use   = true,
		value = 5
	},
    MinTiltRangeToFindAxis = {
		use   = true,
		value = 10.0
	},
    MinTiltRangeToFindAngles = {
		use   = false,
		value = nil
	},
    BoxSizeXandY = {
		use   = true,
		value = { 72, 72 }
	},
    RoundsOfTracking = {
		use   = true,
		value = 20
	},
    MaxViewsInAlign = {
		use   = false,
		value = nil
	},
    RestrictViewsOnRound = {
		use   = false,
		value = nil
	},
    UnsplitFirstRound = {
		use   = false,
		value = nil
	},
    LocalAreaTracking = {
		use   = true,
		value = 1
	},
    LocalAreaTargetSize = {
		use   = true,
		value = 1000
	},
    MinBeadsInArea = {
		use   = true,
		value = 3
	},
    MinOverlapBeads = {
		use   = true,
		value = 3
	},
    TrackObjectsTogether = {
		use   = false,
		value = nil
	},
    MaxBeadsToAverage = {
		use   = true,
		value = 4
	},
    SobelFilterCentering = {
		use   = true,
		value = nil
	},
    KernelSigmaForSobel = {
		use   = true,
		value = 1.75
	},
    AverageBeadsForSobel = {
		use   = false,
		value = nil
	},
    InterpolationType = {
		use   = false,
		value = nil
	},
    PointsToFitMaxAndMin = {
		use   = true,
		value = { 7, 3 }
	},
    DensityRescueFractionAndSD = {
		use   = true,
		value = { 0.6, 1.0 }
	},
    DistanceRescueCriterion = {
		use   = true,
		value = 10.0
	},
    RescueRelaxationDensityAndDistance = {
		use   = true,
		value = { 0.7, 0.9 }
	},
    PostFitRescueResidual = {
		use   = true,
		value = 2.5
	},
    DensityRelaxationPostFit = {
		use   = true,
		value = 0.9
	},
    MaxRescueDistance = {
		use   = true,
		value = 2.5
	},
    ResidualsToAnalyzeMaxAndMin = {
		use   = true,
		value = { 9, 5 }
	},
    DeletionCriterionMinAndSD = {
		use   = true,
		value = { 0.04, 2.0 }
	},
    BoxOutputFile = {
		use   = false,
		value = nil
	},
    SnapshotViews = {
		use   = false,
		value = nil
	},
    SaveAllPointsAreaRound = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.tiltalign = {
    Name = 'tiltalign',
    CommandLine = '$tiltalign -StandardInput',
    ModelFile = {
		use   = true,
		value = function()
            return basename..'.fid'
        end
	},
    ImageFile = {
		use   = true,
		value = function()
            return basename..'.preali'
        end
	},
    ImageSizeXandY = {
		use   = false,
		value = nil
	},
    ImageOriginXandY = {
		use   = false,
		value = nil
	},
    ImagePixelSizeXandY = {
		use   = false,
		value = nil
	},
    ImagesAreBinned = {
		use   = false,
		value = nil
	},
    OutputModelFile = {
		use   = false,
		value = nil
	},
    OutputResidualFile = {
		use   = false,
		value = nil
	},
    OutputModelAndResidual = {
		use   = true,
		value = function()
            return basename..'.resid'
        end
	},
    OutputTopBotResiduals = {
		use   = false,
		value = nil
	},
    OutputFidXYZFile = {
		use   = true,
		value = function()
            return basename..'_fix.xyz'
        end
	},
    OutputTiltFile = {
		use   = true,
		value = function()
            return basename..'.tlt'
        end
	},
    OutputUnadjustedTiltFile = {
		use   = false,
		value = nil
	},
    OutputXAxisTiltFile = {
		use   = true,
		value = function()
            return basename..'.xtilt'
        end
	},
    OutputTransformFile = {
		use   = true,
		value = function()
            return basename..'.tltxf'
        end
	},
    OutputZFactorFile = {
		use   = false,
		value = function()
            return basename..'.zfac'
        end
	},
    IncludeStartEndInc = {
		use   = false,
		value = nil
	},
    IncludeList = {
		use   = false,
		value = nil
	},
    ExcludeList = {
		use   = false,
		value = nil
	},
    RotationAngle = {
		use   = true,
		value = function()
            return Config.header.tilt_axis
        end
	},
    SeparateGroup = {
		use   = true,
		value = function()
            return '1-'..Config.header.split_angle
        end
	},
    FirstTiltAngle = {
		use   = false,
		value = nil
	},
    TiltIncrement = {
		use   = false,
		value = nil
	},
    TiltFile = {
		use   = false,
		value = nil
	},
    TiltAngles = {
		use   = false,
		value = nil
	},
    AngleOffset = {
		use   = false,
		value = nil
	},
    ProjectionStretch = {
		use   = false,
		value = nil
	},
    BeamTiltOption = {
		use   = true,
		value = 0
	},
    FixedOrInitialBeamTilt = {
		use   = false,
		value = nil
	},
    RotOption = {
		use   = true,
		value = 3
	},
    RotDefaultGrouping = {
		use   = true,
		value = 5
	},
    RotNondefaultGrouping = {
		use   = false,
		value = nil
	},
    RotationFixedView = {
		use   = false,
		value = nil
	},
    LocalRotOption = {
		use   = false,
		value = 3
	},
    LocalRotDefaultGrouping = {
		use   = false,
		value = 6
	},
    LocalRotNondefaultGrouping = {
		use   = false,
		value = nil
	},
    TiltOption = {
		use   = true,
		value = 5
	},
    TiltFixedView = {
		use   = false,
		value = nil
	},
    TiltSecondFixedView = {
		use   = false,
		value = nil
	},
    TiltDefaultGrouping = {
		use   = true,
		value = 5
	},
    TiltNondefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalTiltOption = {
		use   = false,
		value = 5
	},
    LocalTiltFixedView = {
		use   = false,
		value = nil
	},
    LocalTiltSecondFixedView = {
		use   = false,
		value = nil
	},
    LocalTiltDefaultGrouping = {
		use   = false,
		value = 6
	},
    LocalTiltNondefaultGrouping = {
		use   = false,
		value = nil
	},
    MagReferenceView = {
		use   = true,
		value = 1
	},
    MagOption = {
		use   = true,
		value = 3
	},
    MagDefaultGrouping = {
		use   = true,
		value = 4
	},
    MagNondefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalMagReferenceView = {
		use   = false,
		value = 1
	},
    LocalMagOption = {
		use   = false,
		value = 3
	},
    LocalMagDefaultGrouping = {
		use   = false,
		value = 7
	},
    LocalMagNondefaultGrouping = {
		use   = false,
		value = nil
	},
    CompReferenceView = {
		use   = false,
		value = nil
	},
    CompOption = {
		use   = false,
		value = nil
	},
    CompDefaultGrouping = {
		use   = false,
		value = nil
	},
    CompNondefaultGrouping = {
		use   = false,
		value = nil
	},
    XStretchOption = {
		use   = true,
		value = 0
	},
    XStretchDefaultGrouping = {
		use   = true,
		value = 7
	},
    XStretchNondefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalXStretchOption = {
		use   = false,
		value = 3
	},
    LocalXStretchDefaultGrouping = {
		use   = false,
		value = 11
	},
    LocalXStretchNondefaultGrouping = {
		use   = false,
		value = nil
	},
    SkewOption = {
		use   = true,
		value = 0
	},
    SkewDefaultGrouping = {
		use   = true,
		value = 11
	},
    SkewNondefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalSkewOption = {
		use   = false,
		value = 3
	},
    LocalSkewDefaultGrouping = {
		use   = false,
		value = 11
	},
    LocalSkewNondefaultGrouping = {
		use   = false,
		value = nil
	},
    XTiltOption = {
		use   = false,
		value = nil
	},
    XTiltDefaultGrouping = {
		use   = false,
		value = nil
	},
    XTiltNondefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalXTiltOption = {
		use   = false,
		value = nil
	},
    LocalXTiltDefaultGrouping = {
		use   = false,
		value = nil
	},
    LocalXTiltNondefaultGrouping = {
		use   = false,
		value = nil
	},
    ResidualReportCriterion = {
		use   = true,
		value = 3.0
	},
    SurfacesToAnalyze = {
		use   = true,
		value = 2
	},
    MetroFactor = {
		use   = true,
		value = 0.25
	},
    MaximumCycles = {
		use   = true,
		value = 1000
	},
    RobustFitting = {
		use   = true,
		value = nil
	},
    WeightWholeTracks = {
		use   = false,
		value = nil
	},
    KFactorScaling = {
		use   = true,
		value = 1.0
	},
    WarnOnRobustFailure = {
		use   = false,
		value = nil
	},
    MinWeightGroupSizes = {
		use   = false,
		value = nil
	},
    AxisZShift = {
		use   = true,
		value = 0.0
	},
    ShiftZFromOriginal = {
		use   = true,
		value = nil
	},
    AxisXShift = {
		use   = false,
		value = nil
	},
    LocalAlignments = {
		use   = false,
		value = nil
	},
    OutputLocalFile = {
		use   = false,
		value = nil
	},
    NumberOfLocalPatchesXandY = {
		use   = false,
		value = { 5, 5 }
	},
    TargetPatchSizeXandY = {
		use   = false,
		value = nil
	},
    MinSizeOrOverlapXandY = {
		use   = true,
		value = { 0.5, 0.5 }
	},
    MinFidsTotalAndEachSurface = {
		use   = true,
		value = { 8, 3}
	},
    FidXYZCoordinates = {
		use   = false,
		value = nil
	},
    LocalOutputOptions = {
		use   = false,
		value = { 1, 0, 1 }
	},
    RotMapping = {
		use   = false,
		value = nil
	},
    LocalRotMapping = {
		use   = false,
		value = nil
	},
    TiltMapping = {
		use   = false,
		value = nil
	},
    LocalTiltMapping = {
		use   = false,
		value = nil
	},
    MagMapping = {
		use   = false,
		value = nil
	},
    LocalMagMapping = {
		use   = false,
		value = nil
	},
    CompMapping = {
		use   = false,
		value = nil
	},
    XStretchMapping = {
		use   = false,
		value = nil
	},
    LocalXStretchMapping = {
		use   = false,
		value = nil
	},
    SkewMapping = {
		use   = false,
		value = nil
	},
    LocalSkewMapping = {
		use   = false,
		value = nil
	},
    XTiltMapping = {
		use   = false,
		value = nil
	},
    LocalXTiltMapping = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.xfproduct = {
    Name = 'xfproduct',
    CommandLine = '$xfproduct -StandardInput',
    InputFile1 = {
        use = true,
        value = function()
            return basename..'.prexg'
        end
    },
    InputFile2 = {
        use = true,
        value = function()
            return basename..'.tltxf'
        end
    },
    OutputFile = {
        use = true,
        value = function()
            return basename..'_fid.xf'
        end
    },
    ScaleShifts = {
        use = false,
        value = nil
    },
    OneXformToMultiply = {
        use = false,
        value = nil
    },
    write = write_command_file
}

Config.newstack = {
    Name = 'newstack',
    CommandLine = '$newstack -StandardInput',
    InputFile = {
		use   = true,
		value = function()
            return basename..'.st'
        end
	},
    OutputFile = {
		use   = true,
		value = function()
            return basename..'.ali'
        end
	},
    FileOfInputs = {
		use   = false,
		value = nil
	},
    FileOfOutputs = {
		use   = false,
		value = nil
	},
    SplitStartingNumber = {
		use   = false,
		value = nil
	},
    AppendExtension = {
		use   = false,
		value = nil
	},
    SectionsToRead = {
		use   = false,
		value = nil
	},
    NumberedFromOne = {
		use   = false,
		value = nil
	},
    ExcludeSections = {
		use   = false,
		value = nil
	},
    TwoDirectionTiltSeries = {
		use   = false,
		value = nil
	},
    SkipSectionIncrement = {
		use   = false,
		value = nil
	},
    NumberToOutput = {
		use   = false,
		value = nil
	},
    ReplaceSections = {
		use   = false,
		value = nil
	},
    BlankOutput = {
		use   = false,
		value = nil
	},
    OffsetsInXandY = {
		use   = false,
		value = nil
	},
    ApplyOffsetsFirst = {
		use   = false,
		value = nil
	},
    TransformFile = {
		use   = true,
		value = function()
            return basename..'.xf'
        end
	},
    UseTransformLines = {
		use   = false,
		value = nil
	},
    OneTrasformPerFile = {
		use   = false,
		value = nil
	},
    RotateByAngle = {
		use   = false,
		value = nil
	},
    ExpandByFactor = {
		use   = false,
		value = nil
	},
    ShrinkByFactor = {
		use   = false,
		value = nil
	},
    AntialiasFilter = {
		use   = false,
		value = nil
	},
    BinByFactor = {
		use   = false,
		value = nil
	},
    DistortionField = {
		use   = false,
		value = nil
	},
    ImagesAreBinned = {
		use   = false,
		value = nil
	},
    UseFields = {
		use   = false,
		value = nil
	},
    GradientFile = {
		use   = false,
		value = nil
	},
    AdjustOrigin = {
		use   = true,
		value = nil
	},
    LinearInterpolation = {
		use   = false,
		value = nil
	},
    NearestNeighbor = {
		use   = false,
		value = nil
	},
    SizeToOutputInXandY = {
		use   = false,
		value = nil
	},
    ModeToOutput = {
		use   = false,
		value = nil
	},
    BytesSignedInOutput = {
		use   = false,
		value = nil
	},
    StripExtraHeader = {
		use   = false,
		value = nil
	},
    FloatDensities = {
		use   = false,
		value = nil
	},
    MeanAndStandardDeviation = {
		use   = false,
		value = nil
	},
    ContrastBlackWhite = {
		use   = false,
		value = nil
	},
    ScaleMinAndMax = {
		use   = false,
		value = nil
	},
    MultiplyAndAdd = {
		use   = false,
		value = nil
	},
    FillValue = {
		use   = false,
		value = nil
	},
    TaperAtFill = {
		use   = true,
		value = { 1, 0 }
	},
    MemoryLimit = {
		use   = false,
		value = nil
	},
    TestLimits = {
		use   = false,
		value = nil
	},
    VerboseOutput = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.ctfplotter = {
    Name = 'ctfplotter',
    CommandLine = '$ctfplotter -StandardInput',
    InputStack = {
		use   = true,
		value = function()
            return basename..'.st'
        end
	},
    AngleFile = {
		use   = true,
		value = function()
            return basename..'.tlt'
        end
	},
    InvertTiltAngles = {
		use   = false,
		value = nil
	},
    OffsetToAdd = {
		use   = false,
		value = nil
	},
    ConfigFile = {
		use   = true,
		value = '/usr/local/ImodCalib/CTFnoise/K24Kbackground/'..
                'polara-K2-4k-2014.ctf'
	},
    DefocusFile = {
		use   = true,
		value = function()
            return basename..'.defocus'
        end
	},
    AxisAngle = {
		use   = true,
		value = function()
            return Config.header.tilt_axis
        end
	},
    PSResolution = {
		use   = false,
		value = nil
	},
    TileSize = {
		use   = false,
		value = nil
	},
    Voltage = {
		use   = true,
		value = 300
	},
    MaxCacheSize = {
		use   = false,
		value = nil
	},
    SphericalAberration = {
		use   = true,
		value = 2.0
	},
    DefocusTol = {
		use   = false,
		value = nil
	},
    PixelSize = {
		use   = false,
		value = nil
	},
    AmplitudeContrast = {
		use   = false,
		value = nil
	},
    ExpectedDefocus = {
		use   = false,
		value = nil
	},
    LeftDefTol = {
		use   = false,
		value = nil
	},
    RightDefTol = {
		use   = false,
		value = nil
	},
    AngleRange = {
		use   = true,
		value = { -40.0, 40.0 }
	},
    AutoFitRangeAndStep = {
		use   = true,
		value = { 0.0, 0.0 }
	},
    FrequencyRangeToFit = {
		use   = true,
		value = { 0.05, 0.225 }
	},
    VaryExponentInFit = {
		use   = true,
		value = nil
	},
    SaveAndExit = {
		use   = true,
		value = nil
	},
    DebugLevel = {
		use   = false,
		value = nil
	},
    Parameter = {
		use   = false,
		value = nil
	},
    FocalPairDefocusOffset = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.ctfphaseflip = {
    Name = 'ctfphaseflip',
    CommandLine = '$ctfphaseflip -StandardInput',
    InputStack = {
		use   = true,
		value = function()
            return basename..'.ali'
        end
	},
    OutputFileName = {
		use   = true,
		value = function()
            return basename..'_ctfcorr.ali'
        end
	},
    AngleFile = {
		use   = true,
		value = function()
            return basename..'.tlt'
        end
	},
    InvertTiltAngles = {
		use   = false,
		value = nil
	},
    DefocusFile = {
		use   = true,
		value = function()
            return basename..'.defocus'
        end
	},
    TransformFile = {
		use   = true,
		value = function()
            return basename..'.xf'
        end
	},
    DefocusTol = {
		use   = true,
		value = 200
	},
    MaximumStripWidth = {
		use   = false,
		value = nil
	},
    InterpolationWidth = {
		use   = true,
		value = 20
	},
    PixelSize = {
		use   = true,
		value = function()
            return Config.header.pixel_size
        end
	},
    Voltage = {
		use   = true,
		value = 300
	},
    SphericalAberration = {
		use   = true,
		value = 2.0
	},
    AmplitudeContrast = {
		use   = true,
		value = 0.07
	},
    StartingEndingViews = {
		use   = false,
		value = nil
	},
    TotalViews = {
		use   = false,
		value = nil
	},
    BoundaryInfoFile = {
		use   = false,
		value = nil
	},
    AxisAngle = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.xfmodel = {
    Name = 'xfmodel',
    CommandLine = '$xfmodel -StandardInput',
    InputFile = {
        use = true,
        value = function()
            return basename..'.fid'
        end
    },
    OutputFile = {
        use = true,
        value = function()
            return basename..'_erase.fid'
        end
    },
    ImageFile = {
        use = false,
        value = nil
    },
    PieceListFile = {
        use = false,
        value = nil
    },
    AllZhaveTransforms = {
        use = false,
        value = nil
    },
    CenterInXandY = {
        use = false,
        value = nil
    },
    TranslationOnly = {
        use = false,
        value = nil
    },
    RotationTranslation = {
        use = false,
        value = nil
    },
    MagRotTrans = {
        use = false,
        value = nil
    },
    SectionsToAnalyze = {
        use = false,
        value = nil
    },
    SingleSection = {
        use = false,
        value = nil
    },
    FullReportMeanAndMax = {
        use = false,
        value = nil
    },
    PrealignTransforms = {
        use = false,
        value = nil
    },
    EditTransforms = {
        use = false,
        value = nil
    },
    XformsToApply = {
        use = true,
        value = function()
            return basename..'.tltxf'
        end
    },
    UseTransformLine = {
        use = false,
        value = nil
    },
    ChunkSizes = {
        use = false,
        value = nil
    },
    BackTransform = {
        use = false,
        value = nil
    },
    ScaleShifts = {
        use = false,
        value = nil
    },
    DistortionField = {
        use = false,
        value = nil
    },
    BinningOfImages = {
        use = false,
        value = nil
    },
    GradientFile = {
        use = false,
        value = nil
    },
    write = write_command_file,
}

Config.gold_ccderaser = {
    Name = 'gold_ccderaser',
    CommandLine = '$ccderaser -StandardInput',
    InputFile = {
		use   = true,
		value = function()
            return basename..'.ali'
        end
	},
    OutputFile = {
		use   = true,
		value = function()
            return basename..'_erase.ali'
        end
	},
    PieceListFile = {
		use   = false,
		value = nil
	},
    OverlapsForModel = {
		use   = false,
		value = nil
	},
    FindPeaks = {
		use   = false,
		value = nil
	},
    PeakCriterion = {
		use   = false,
		value = nil
	},
    DiffCriterion = {
		use   = false,
		value = nil
	},
    GrowCriterion = {
		use   = false,
		value = nil
	},
    ScanCriterion = {
		use   = false,
		value = nil
	},
    MaximumRadius = {
		use   = false,
		value = nil
	},
    GiantCriterion = {
		use   = false,
		value = nil
	},
    ExtraLargeRadius = {
		use   = false,
		value = nil
	},
    BigDiffCriterion = {
		use   = false,
		value = nil
	},
    MaxPixelsInDiffPatch = {
		use   = false,
		value = nil
	},
    OuterRadius = {
		use   = false,
		value = nil
	},
    AnnulusWidth = {
		use   = false,
		value = nil
	},
    XYScanSize = {
		use   = false,
		value = nil
	},
    EdgeExclusionWidth = {
		use   = false,
		value = nil
	},
    PointModel = {
		use   = false,
		value = nil
	},
    ModelFile = {
		use   = true,
		value = function()
            return basename..'_erase.fid'
        end
	},
    LineObjects = {
		use   = false,
		value = nil
	},
    BoundaryObjects = {
		use   = false,
		value = nil
	},
    AllSectionObjects = {
		use   = false,
		value = nil
	},
    CircleObjects = {
		use   = true,
		value = '/'
	},
    BetterRadius = {
		use   = true,
		value = 13.25
	},
    ExpandCircleIterations = {
		use   = false,
		value = nil
	},
    MergePatches = {
		use   = true,
		value = nil
	},
    BorderSize = {
		use   = false,
		value = nil
	},
    PolynomialOrder = {
		use   = true,
		value = 0
	},
    ExcludeAdjacent = {
		use   = true,
		value = nil
	},
    TrialMode = {
		use   = false,
		value = nil
	},
    Verbose = {
		use   = false,
		value = nil
	},
    ProcessID = {
		use   = false,
		value = nil
	},
    ParameterFile = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.tilt = {
    Name = 'tilt',
    CommandLine = '$tilt -StandardInput',
    InputProjections = {
		use   = true,
		value = function()
            return basename..'.ali'
        end
	},
    OutputFile = {
		use   = true,
		value = function()
            return basename..'_full.rec'
        end
	},
    RecFileToReproject = {
		use   = false,
		value = nil
	},
    ProjectModel = {
		use   = false,
		value = nil
	},
    BaseRecFile = {
		use   = false,
		value = nil
	},
    ActionIfGPUFails = {
		use   = true,
		value = { 1, 2 }
	},
    AdjustOrigin = {
		use   = true,
		value = nil
	},
    ANGLES = {
		use   = false,
		value = nil
	},
    BaseNumViews = {
		use   = false,
		value = nil
	},
    BoundaryInfoFile = {
		use   = false,
		value = nil
	},
    COMPFRACTION = {
		use   = false,
		value = nil
	},
    COMPRESS = {
		use   = false,
		value = nil
	},
    ConstrainSign = {
		use   = false,
		value = nil
	},
    COSINTERP = {
		use   = false,
		value = nil
	},
    DENSWEIGHT = {
		use   = false,
		value = nil
	},
    DONE = {
		use   = false,
		value = nil
	},
    EXCLUDELIST2 = {
		use   = false,
		value = nil
	},
    FlatFilterFraction = {
		use   = false,
		value = nil
	},
    FBPINTERP = {
		use   = false,
		value = nil
	},
    FULLIMAGE = {
		use   = false,
		value = nil
	},
    IMAGEBINNED = {
		use   = true,
		value = 1
	},
    INCLUDE = {
		use   = false,
		value = nil
	},
    LOCALFILE = {
		use   = false,
		value = nil
	},
    LOCALSCALE = {
		use   = false,
		value = nil
	},
    LOG = {
		use   = true,
		value = 0.0
	},
    MASK = {
		use   = false,
		value = nil
	},
    MinMaxMean = {
		use   = false,
		value = nil
	},
    MODE = {
		use   = false,
		value = nil
	},
    OFFSET = {
		use   = false,
		value = nil
	},
    PARALLEL = {
		use   = false,
		value = nil
	},
    PERPENDICULAR = {
		use   = true,
		value = nil
	},
    RADIAL = {
		use   = true,
		value = { 0.35, 0.05 }
	},
    REPLICATE = {
		use   = false,
		value = nil
	},
    REPROJECT = {
		use   = false,
		value = nil
	},
    RotateBy90 = {
		use   = false,
		value = nil
	},
    SCALE = {
		use   = true,
		value = { 0.0, 700.0 }
	},
    SHIFT = {
		use   = true,
		value = { 0.0, 0.0 }
	},
    SIRTIterations = {
		use   = false,
		value = nil
	},
    SIRTSubtraction = {
		use   = false,
		value = nil
	},
    SLICE = {
		use   = false,
		value = nil
	},
    StartingIteration = {
		use   = false,
		value = nil
	},
    SUBSETSTART = {
		use   = true,
		value = { 0, 0 }
	},
    SubtractFromBase = {
		use   = false,
		value = nil
	},
    THICKNESS = {
		use   = true,
		value = 1200
	},
    TILTFILE = {
		use   = true,
		value = function()
            return basename..'.tlt'
        end
	},
    TITLE = {
		use   = false,
		value = nil
	},
    TOTALSLICES = {
		use   = false,
		value = nil
	},
    UseGPU = {
		use   = false,
		value = nil
	},
    ViewsToReproject = {
		use   = false,
		value = nil
	},
    VertBoundaryFile = {
		use   = false,
		value = nil
	},
    VertSliceOutputFile = {
		use   = false,
		value = nil
	},
    VertForSIRTInput = {
		use   = false,
		value = nil
	},
    WeightAngleFile = {
		use   = false,
		value = nil
	},
    WeightFile = {
		use   = false,
		value = nil
	},
    WIDTH = {
		use   = false,
		value = nil
	},
    XAXISTILT = {
		use   = false,
		value = nil
	},
    XMinAndMaxReproj = {
		use   = false,
		value = nil
	},
    XTILTFILE = {
		use   = false,
		value = nil
	},
    XTILTINTERP = {
		use   = false,
		value = nil
	},
    YMinAndMaxReproj = {
		use   = false,
		value = nil
	},
    ZFACTORFILE = {
		use   = false,
		value = nil
	},
    ZMinAndMaxReproj = {
		use   = false,
		value = nil
	},
    DebugOutput = {
		use   = false,
		value = nil
	},
    InternalSIRTSlices = {
		use   = false,
		value = nil
	},
    ParameterFile = {
		use   = false,
		value = nil
	},
    write = write_command_file,
}

Config.tomo3d = {
    Name = 'tomo3d',
    CommandLine = '#!/bin/bash',
    TiltFile = {
		use   = true,
		value = function()
            return basename..'.tlt'
        end
	},
    InputFile = {
		use   = true,
		value = function()
            return basename..'.ali'
        end
	},
    AngleOffset = {
		use   = false,
		value = nil
	},
    IOBuffers = {
		use   = false,
		value = nil
	},
    CacheBlock = {
		use   = false,
		value = nil
	},
    ConstrainOutputVolume = {
		use   = false,
		value = nil
	},
    VectorExtensions = {
		use   = false,
		value = nil
	},
    OverwriteOutputVolume = {
		use   = false,
		value = nil
	},
    HyperThreading = {
		use   = false,
		value = nil
	},
    Interpolation = {
		use   = false,
		value = nil
	},
    LogReconstruction = {
		use   = false,
		value = nil
	},
    Iterations = {
		use   = false,
		value = nil
	},
    MemoryLimit = {
		use   = false,
		value = nil
	},
    HammingFrequency = {
		use   = true,
		value = 0.35
	},
    InvertHandedness = {
		use   = false,
		value = nil
	},
    SinogramOffset = {
		use   = false,
		value = nil
	},
    OutputVolume = {
		use   = true,
		value = function()
            return basename..'_tomo3d.rec'
        end
	},
    SinogramProjections = {
		use   = false,
		value = nil
	},
    ProcessRows = {
		use   = false,
		value = nil
	},
    ResumeSIRTVolume = {
		use   = false,
		value = nil
	},
    SIRT = {
		use   = false,
		value = nil
	},
    SplitFactor = {
		use   = false,
		value = nil
	},
    Threading = {
		use   = false,
		value = nil
	},
    Verbosity = {
		use   = false,
		value = nil
	},
    Weighting = {
		use   = false,
		value = nil
	},
    Width = {
		use   = false,
		value = nil
	},
    Depth = {
		use   = false,
		value = nil
	},
    Height = {
		use   = true,
		value = 1200
	},
    write = write_tomo3d
}

Config.MOTIONCORR = {
    Name = 'dosefgpu_driftcorr',
    CommandLine = '#!/bin/bash',
    CropOffsetX = {
		use   = false,
		value = nil
	},
    CropOffsetY = {
		use   = false,
		value = nil
	},
    CropDimensionX = {
		use   = false,
		value = nil
	},
    CropDimensionY = {
		use   = false,
		value = nil
	},
    Binning = {
		use   = false,
		value = nil
	},
    AlignmentFirstFrame = {
		use   = false,
		value = nil
	},
    AlignmentLastFrame = {
		use   = false,
		value = nil
	},
    SumFirstFrame = {
		use   = false,
		value = nil
	},
    SumLastFrame = {
		use   = false,
		value = nil
	},
    GPUDeviceID = {
		use   = false,
		value = nil
	},
    BFactor = {
		use   = true,
		value = 220
	},
    PeakBox = {
		use   = false,
		value = nil
	},
    FrameOffset = {
		use   = true,
		value = function()
            return Config.header.nz // 4
        end
	},
    NoisePeakRadius = {
		use   = false,
		value = nil
	},
    ErrorThreshold = {
		use   = false,
		value = nil
	},
    GainReferenceFile = {
		use   = false,
		value = nil
	},
    DarkReferenceFile = {
		use   = false,
		value = nil
	},
    SaveUncorrectedSum = {
		use   = false,
		value = nil
	},
    SaveUncorrectedStack = {
		use   = false,
		value = nil
	},
    SaveCorrectedStack = {
		use   = false,
		value = nil
	},
    SaveCorrelationMap = {
		use   = false,
		value = nil
	},
    SaveLog = {
		use   = false,
		value = nil
	},
    AlignToMiddleFrame = {
		use   = false,
		value = nil
	},
    SaveQuickResults = {
		use   = true,
		value = 0
	},
    UncorrectedSumOutput = {
		use   = false,
		value = nil
	},
    UncorrectedStackOutput = {
		use   = false,
		value = nil
	},
    CorrectedSumOutput = {
		use   = true,
		value = function()
            return basename..'_driftcorr.mrc'
        end
	},
    CorrectedStackOutput = {
		use   = false,
		value = nil
	},
    CorrelationMapOutput = {
		use   = false,
		value = nil
	},
    LogFileOutput = {
		use   = true,
		value = function()
            return basename..'_dosefgpu_driftcorr.log'
        end
	},
    write = write_MOTIONCORR
}

Config.CTFFIND4 = {
    InputFile = {
		use   = true,
		value = function()
            return basename..'.mrc'
        end
	},
    DiagnosticOutput = {
		use   = true,
		value = function()
            return basename..'.ctf'
        end
	},
    PixelSize = {
		use   = true,
		value = function()
            return Config.header.pixel_size
        end
	},
    AccelerationVoltage = {
		use   = true,
		value = 300
	},
    ShpericalAberration = {
		use   = true,
		value = 2.0
	},
    AmplitudeContrast = {
		use   = true,
		value = 0.10
	},
    BoxSize = {
		use   = true,
		value = 256
	},
    MinimumResolution = {
		use   = true,
		value = 50.0
	},
    MaximumResolution = {
		use   = true,
		value = 10.0
	},
    MinimumDefocus = {
		use   = true,
		value = 10000.0
	},
    MaximumDefocus = {
		use   = true,
		value = 70000.0
	},
    DefocusSearchStep = {
		use   = true,
		value = 500.0
	},
    AstigmatismTolerance = {
		use   = true,
		value = 100.0
	},
    AdditionalPhaseShift = {
		use   = false,
		value = nil
	},
    MinimumPhaseShift = {
		use   = false,
		value = nil
	},
    MaximumPhaseShift = {
		use   = false,
		value = nil
	},
    PhaseShiftSearchStep = {
		use   = false,
		value = nil
	},
    write = write_CTFFIND4
}

Config.ccderaser.Lookup = {
    'InputFile',
    'OutputFile',
    'PieceListFile',
    'OverlapsForModel',
    'FindPeaks',
    'PeakCriterion',
    'DiffCriterion',
    'GrowCriterion',
    'ScanCriterion',
    'MaximumRadius',
    'GiantCriterion',
    'ExtraLargeRadius',
    'BigDiffCriterion',
    'MaxPixelsInDiffPatch',
    'OuterRadius',
    'AnnulusWidth',
    'XYScanSize',
    'EdgeExclusionWidth',
    'PointModel',
    'ModelFile',
    'LineObjects',
    'BoundaryObjects',
    'AllSectionObjects',
    'CircleObjects',
    'BetterRadius',
    'ExpandCircleIterations',
    'MergePatches',
    'BorderSize',
    'PolynomialOrder',
    'ExcludeAdjacent',
    'TrialMode',
    'Verbose',
    'ProcessID'
}

Config.tiltxcorr.Lookup = {
    'InputFile',
    'PieceListFile',
    'OutputFile',
    'RotationAngle',
    'FirstTiltAngle',
    'TiltIncrement',
    'TiltFile',
    'TiltAngles',
    'AngleOffset',
    'ReverseOrder',
    'FilterRadius1',
    'FilterRadius2',
    'FilerSigma1',
    'FilterSigma2',
    'ExcludeCentralPeak',
    'CentralPeakExclusionCriteria',
    'ShiftLimitsXandY',
    'RectangularLimits',
    'CorrelationCoefficient',
    'BordersInXandY',
    'XMinAndMax',
    'YMinAndMax',
    'BoundaryModel',
    'BoundaryObject',
    'BinningToApply',
    'AntialiasFilter',
    'LeaveTiltAxisShifted',
    'PadsInXandY',
    'TapersInXandY',
    'StartingEndingViews',
    'SkipViews',
    'BreakAtViews',
    'CumulativeCorrelation',
    'AbsoluteCoseStretch',
    'NoCosineStretch',
    'IterateCorrelations',
    'SearchMagChanges',
    'ViewsWithMagChanges',
    'MagnificationLimits',
    'SizeOfPatchesXandY',
    'NumberOfPatchesXandY',
    'OverlapPatchesXandY',
    'SeedModel',
    'SeedObject',
    'LengthAndOverlap',
    'PrealignmentTransformFile',
    'ImagesAreBinned',
    'UnalignedSizeXandY',
    'FindWarpTransforms',
    'RawAndAlignedPair',
    'AppendToWarpFile',
    'TestOutput',
    'VerboseOutput'
}

Config.xftoxg.Lookup = {
    'InputFile',
    'GOutputFile',
    'NumberToFit',
    'ReferenceSection',
    'OrderOfPolynomialFit',
    'HybridFits',
    'RangeOfAnglesInAverage',
    'RobustFit',
    'KFactorScaling',
    'MaximumIterations',
    'IterationParams'
}

Config.prenewstack.Lookup = {
	'InputFile',
	'OutputFile',
	'FileOfInputs',
    'FileOfOutputs',
	'SplitStartingNumber',
	'AppendExtension',
    'SectionsToRead',
	'NumberedFromOne',
	'ExcludeSections',
    'TwoDirectionTiltSeries',
	'SkipSectionIncrement',
	'NumberToOutput',
    'ReplaceSections',
	'BlankOutput',
	'OffsetsInXandY',
	'ApplyOffsetsFirst',
    'TransformFile',
	'UseTransformLines',
	'OneTransformPerFile',
    'RotateByAngle',
	'ExpandByFactor',
	'ShrinkByFactor',
	'AntialiasFilter',
    'BinByFactor',
	'DistortionField',
	'ImagesAreBinned',
	'UseFields',
    'GradientFile',
	'AdjustOrigin',
	'LinearInterpolation',
    'NearestNeighbor',
	'SizeToOutputInXandY',
	'ModeToOutput',
    'BytesSignedInOutput',
	'StripExtraHeader',
	'FloatDensities',
    'MeanAndStandardDeviation',
	'ContrastBlackWhite',
	'ScaleMinAndMax',
    'MultiplyAndAdd',
	'FillValue',
	'TaperAtFill',
	'MemoryLimit',
    'TestLimits',
	'VerboseOutput'
}

Config.RAPTOR.Lookup = {
	'RaptorExecPath',
	'InputPath',
	'InputFile',
    'OutputPath',
	'Diameter',
	'WhiteMarkers',
	'MarkersPerImage',
    'AnglesInHeader',
	'Binning',
	'Reconstruction',
	'Thickness',
	'Orient',
    'TrackingOnly',
	'xRay',
	'Verbose',
	'MaxDistanceCandidate',
    'MinNeighborsMRF',
	'RollOffMRF'
}

Config.autofidseed.Lookup = {
	'TrackCommandFile',
	'AppendToSeedModel',
    'MinGuessNumBeads',
	'MinSpacing',
	'BeadSize',
	'AdjustSizes',
    'PeakStorageFraction',
	'FindBeadOptions',
	'NumberOfSeedViews',
    'BoundaryModel',
	'ExcludeInsideAreas',
	'BordersInXandY',
	'TwoSurfaces',
    'TargetNumberOfBeads',
	'TargetDensityOfBeads',
	'MaxMajorToMinorRatio',
    'ElongatedPointsAllowed',
	'ClusteredPointsAllowed',
    'LowerTargetForClustered',
	'SubareaSize',
	'SortAreasMinNumAndSize',
    'IgnoreSurfaceData',
	'DropTracks',
	'PickSeedOptions',
	'RemoveTempFiles',
    'OutputSeedModel',
	'InfoFile',
	'TemporaryDirectory',
	'LeaveTempFiles'
}

Config.beadtrack.Lookup = {
	'InputSeedModel',
	'OutputModel',
	'ImageFile',
    'PieceListFile',
	'PrealignTransformFile',
	'ImagesAreBinned',
    'XYZOutputFile',
	'ElongationOutputFile',
	'SkipViews',
	'RotationAngle',
    'SeparateGroup',
	'FirstTiltAngle',
	'TiltIncrement',
	'TiltFile',
    'TiltAngles',
	'TiltDefaultGrouping',
	'TiltNondefaultGrouping',
    'MagDefaultGrouping',
	'MagNondefaultGrouping',
	'RotDefaultGrouping',
    'RotNondefaultGrouping',
	'MinViewsForTiltalign',
	'CentroidRadius',
    'BeadDiameter',
	'MedianForCentroid',
	'LightBeads',
	'FillGaps',
    'MaxGapSize',
	'MinTiltRangeToFindAxis',
	'MinTiltRangeToFindAngles',
    'BoxSizeXandY',
	'RoundsOfTracking',
	'MaxViewsInAlign',
    'RestrictViewsOnRound',
	'UnsplitFirstRound',
	'LocalAreaTracking',
    'LocalAreaTargetSize',
	'MinBeadsInArea',
	'MinOverlapBeads',
    'TrackObjectsTogether',
	'MaxBeadsToAverage',
	'SobelFilterCentering',
    'KernelSigmaForSobel',
	'InterpolationType',
	'PointsToFixMaxAndMin',
    'DensityRescueFractionAndSD',
	'DistanceRescueCriterion',
    'RescueRelaxationDensityAndDistance',
	'PostFitRescueResidual',
    'DensityRelaxationPostFit',
	'MaxRescueDistance',
    'ResidualsToAnalyzeMaxAndMin',
	'DeletionCriterionMinAndSD',
    'BoxOutputFile',
	'SnapshotViews',
	'SaveAllPointsAreaRound'
}

Config.tiltalign.Lookup = {
    'ModelFile',
    'ImageFile',
    'ImageSizeXandY',
    'ImageOriginXandY',
    'ImagePixelSizeXandY',
    'ImagesAreBinned',
    'OutputModelFile',
    'OutputResidualFile',
    'OutputModelAndResidual',
    'OutputTopBotResiduals',
    'OutputFidXYZFile',
    'OutputTiltFile',
    'OutputUnadjustedTiltFile',
    'OutputXAxisTiltFile',
    'OutputTransformFile',
    'OutputZFactorFile',
    'IncludeStartEndInc',
    'IncludeList',
    'ExcludeList',
    'RotationAngle',
    'SeparateGroup',
    'FirstTiltAngle',
    'TiltIncrement',
    'TiltFile',
    'TiltAngles',
    'AngleOffset',
    'ProjectionStretch',
    'BeamTiltOption',
    'FixedOrInitialBeamTilt',
    'RotOption',
    'RotDefaultGrouping',
    'RotNondefaultGrouping',
    'RotationFixedView',
    'LocalRotOption',
    'LocalRotDefaultGrouping',
    'LocalRotNondefaultGrouping',
    'TiltOption',
    'TiltFixedView',
    'TiltSecondFixedView',
    'TiltDefaultGrouping',
    'TiltNondefaultGrouping',
    'LocalTiltOption',
    'LocalTiltFixedView',
    'LocalTiltSecondFixedView',
    'LocalTiltDefaultGrouping',
    'LocalTiltNondefaultGrouping',
    'MagReferenceView',
    'MagOption',
    'MagDefaultGrouping',
    'MagNondefaultGrouping',
    'LocalMagReferenceView',
    'LocalMagOption',
    'LocalMagDefaultGrouping',
    'LocalMagNondefaultGrouping',
    'CompReferenceView',
    'CompOption',
    'CompDefaultGrouping',
    'CompNondefaultGrouping',
    'XStretchOption',
    'XStretchDefaultGrouping',
    'XStretchNondefaultGrouping',
    'LocalXStretchOption',
    'LocalXStretchDefaultGrouping',
    'LocalXStretchNondefaultGrouping',
    'SkewOption',
    'SkewDefaultGrouping',
    'SkewNondefaultGrouping',
    'LocalSkewOption',
    'LocalSkewDefaultGrouping',
    'LocalSkewNondefaultGrouping',
    'XTiltOption',
    'XTiltDefaultGrouping',
    'XTiltNondefaultGrouping',
    'LocalXTiltOption',
    'LocalXTiltDefaultGrouping',
    'LocalXTiltNondefaultGrouping',
    'ResidualReportCriterion',
    'SurfacesToAnalyze',
    'MetroFactor',
    'MaximumCycles',
    'RobustFitting',
    'WeightWholeTracks',
    'KFactorScaling',
    'WarnOnRobustFailure',
    'MinWeightGroupSizes',
    'AxisZShift',
    'ShiftZFromOriginal',
    'AxisXShift',
    'LocalAlignments',
    'OutputLocalFile',
    'NumberOfLocalPatchesXandY',
    'TargetPatchSizeXandY',
    'MinSizeOrOverlapXandY',
    'MinFidsTotalAndEachSurface',
    'FidXYZCoordinates',
    'LocalOutputOptions',
    'RotMapping',
    'LocalRotMapping',
    'TiltMapping',
    'LocalTiltMapping',
    'MagMapping',
    'LocalMagMapping',
    'CompMapping',
    'XStretchMapping',
    'LocalXStretchMapping',
    'SkewMapping',
    'LocalSkewMapping',
    'XTiltMapping',
    'LocalXTiltMapping'
}

Config.xfproduct.Lookup = {
    'InputFile1',
    'InputFile2',
    'OutputFile',
    'ScaleShifts',
    'OneXformToMultiply'
}

Config.newstack.Lookup = {
	'InputFile',
	'OutputFile',
	'FileOfInputs',
    'FileOfOutputs',
	'SplitStartingNumber',
	'AppendExtension',
    'SectionsToRead',
	'NumberedFromOne',
	'ExcludeSections',
    'TwoDirectionTiltSeries',
	'SkipSectionIncrement',
	'NumberToOutput',
    'ReplaceSections',
	'BlankOutput',
	'OffsetsInXandY',
	'ApplyOffsetsFirst',
    'TransformFile',
	'UseTransformLines',
	'OneTransformPerFile',
    'RotateByAngle',
	'ExpandByFactor',
	'ShrinkByFactor',
	'AntialiasFilter',
    'BinByFactor',
	'DistortionField',
	'ImagesAreBinned',
	'UseFields',
    'GradientFile',
	'AdjustOrigin',
	'LinearInterpolation',
    'NearestNeighbor',
	'SizeToOutputInXandY',
	'ModeToOutput',
    'BytesSignedInOutput',
	'StripExtraHeader',
	'FloatDensities',
    'MeanAndStandardDeviation',
	'ContrastBlackWhite',
	'ScaleMinAndMax',
    'MultiplyAndAdd',
	'FillValue',
	'TaperAtFill',
	'MemoryLimit',
    'TestLimits',
	'VerboseOutput'
}

Config.ctfplotter.Lookup = {
    'InputStack',
    'AngleFile',
    'InvertTiltAngles',
    'OffsetToAdd',
    'ConfigFile',
    'DefocusFile',
    'AxisAngle',
    'PSResolution',
    'TileSize',
    'Voltage',
    'MaxCacheSize',
    'SphericalAberration',
    'DefocusTol',
    'PixelSize',
    'AmplitudeContrast',
    'ExpectedDefocus',
    'LeftDefTol',
    'RightDefTol',
    'AngleRange',
    'AutoFitRangeAndStep',
    'FrequencyRangeToFit',
    'VaryExponentInFit',
    'SaveAndExit',
    'DebugLevel',
    'Parameter',
    'FocalPairDefocusOffset'
}

Config.ctfphaseflip.Lookup = {
    'InputStack',
    'OutputFileName',
    'AngleFile',
    'InvertTiltAngles',
    'DefocusFile',
    'TransformFile',
    'DefocusTol',
    'MaximumStripWidth',
    'InterpolationWidth',
    'PixelSize',
    'Voltage',
    'SphericalAberration',
    'AmplitudeContrast',
    'StartingEndingViews',
    'TotalViews',
    'BoundaryInfoFile',
    'AxisAngle'
}

Config.xfmodel.Lookup = {
    'InputFile',
    'OutputFile',
    'ImageFile',
    'PieceListFile',
    'AllZhaveTransforms',
    'CenterInXandY',
    'TranslationOnly',
    'RotationTranslation',
    'MagRotTrans',
    'SectionsToAnalyze',
    'SingleSection',
    'FullReportMeanAndMax',
    'PrealignTransforms',
    'EditTransforms',
    'XformsToApply',
    'UseTransformLine',
    'ChunkSizes',
    'BackTransform',
    'ScaleShifts',
    'DistortionField',
    'BinningOfImages',
    'GradientFile'
}

Config.gold_ccderaser.Lookup = {
    'InputFile',
    'OutputFile',
    'PieceListFile',
    'OverlapsForModel',
    'FindPeaks',
    'PeakCriterion',
    'DiffCriterion',
    'GrowCriterion',
    'ScanCriterion',
    'MaximumRadius',
    'GiantCriterion',
    'ExtraLargeRadius',
    'BigDiffCriterion',
    'MaxPixelsInDiffPatch',
    'OuterRadius',
    'AnnulusWidth',
    'XYScanSize',
    'EdgeExclusionWidth',
    'PointModel',
    'ModelFile',
    'LineObjects',
    'BoundaryObjects',
    'AllSectionObjects',
    'CircleObjects',
    'BetterRadius',
    'ExpandCircleIterations',
    'MergePatches',
    'BorderSize',
    'PolynomialOrder',
    'ExcludeAdjacent',
    'TrialMode',
    'Verbose',
    'ProcessID'
}

Config.tilt.Lookup = {
    'InputProjections',
    'OutputFile',
    'RecFileToReproject',
    'ProjectModel',
    'BaseRecFile',
    'ActionIfGPUFails',
    'AdjustOrigin',
    'ANGLES',
    'BaseNumViews',
    'BoundaryInfoFile',
    'COMPFRACTION',
    'COMPRESS',
    'ConstrainSign',
    'COSINTERP',
    'DENSWEIGHT',
    'DONE',
    'EXCLUDELIST2',
    'FlatFilterFraction',
    'FBPINTERP',
    'FULLIMAGE',
    'IMAGEBINNED',
    'INCLUDE',
    'LOCALFILE',
    'LOCALSCALE',
    'LOG',
    'MASK',
    'MinMaxMean',
    'MODE',
    'OFFSET',
    'PARALLEL',
    'PERPENDICULAR',
    'RADIAL',
    'REPLICATE',
    'REPROJECT',
    'RotateBy90',
    'SCALE',
    'SHIFT',
    'SIRTIterations',
    'SIRTSubtraction',
    'SLICE',
    'StartingIteration',
    'SUBSETSTART',
    'SubtractFromBase',
    'THICKNESS',
    'TILTFILE',
    'TITLE',
    'TOTALSLICES',
    'UseGPU',
    'ViewsToReproject',
    'VertBoundaryFile',
    'VertSliceOutputFile',
    'VertForSIRTInput',
    'WeightAngleFile',
    'WeightFile',
    'WIDTH',
    'XAXISTILT',
    'XMinAndMaxReproj',
    'XTILTFILE',
    'XTILTINTERP',
    'YMinAndMaxReproj',
    'ZFACTORFILE',
    'ZMinAndMaxReproj',
    'DebugOutput',
    'InternalSIRTSlices',
    'ParameterFile'
}

Config.tomo3d.Lookup = {
    {'TiltFile', '-a'},
    {'InputFile', '-i'},
    {'AngleOffset', '-A'},
    {'IOBuffers', '-b'},
    {'CacheBlock', '-C'},
    {'ConstrainOutputVolume', '-c'},
    {'VectorExtensions', '-e'},
    {'OverwriteOutputVolume', '-f'},
    {'HyperThreading', '-H'},
    {'Interpolation', '-I'},
    {'LogReconstruction', '-L'},
    {'Iterations', '-l'},
    {'MemoryLimit', '-M'},
    {'HammingFrequency', '-m'},
    {'InvertHandedness', '-n'},
    {'SinogramOffset', '-O'},
    {'OutputVolume', '-o'},
    {'SinogramProjections', '-P'},
    {'ProcessRows', '-R'},
    {'ResumeSIRTVolume', '-r'},
    {'SIRT', '-S'},
    {'SplitFactor', '-s'},
    {'Threading', '-t'},
    {'Verbosity', '-v'},
    {'Weighting', '-w'},
    {'Width', '-x'},
    {'Depth', '-y'},
    {'Height', '-z'},
}

Config.MOTIONCORR.Lookup = {
    {'CropOffsetX', '-crx'},
    {'CropOffsetY', '-cry'},
    {'CropDimensionX', '-cdx'},
    {'CropDimensionY', '-cdy'},
    {'Binning', '-bin'},
    {'AlignmentFirstFrame', '-nst'},
    {'AlignmentLastFrame', '-ned'},
    {'SumFirstFrame', '-nss'},
    {'SumLastFrame', '-nes'},
    {'GPUDeviceID', '-gpu'},
    {'BFactor', '-bft'},
    {'PeakBox', '-pbx'},
    {'FrameOffset', '-fod'},
    {'NoisePeakRadius', '-nps'},
    {'ErrorThreshold', '-kit'},
    {'GainReferenceFile', '-fgr'},
    {'DarkReferenceFile', '-fdr'},
    {'SaveUncorrectedSum', '-srs'},
    {'SaveUncorrectedStack', '-ssr'},
    {'SaveCorrectedStack', '-ssc'},
    {'SaveCorrelationMap', '-scc'},
    {'SaveLog', '-slg'},
    {'AlignToMiddleFrame', '-atm'},
    {'SaveQuickResults', '-dsp'},
    {'UncorrectedSumOutput', '-frs'},
    {'UncorrectedStackOutput', '-frt'},
    {'CorrectedSumOutput', '-fcs'},
    {'CorrectedStackOutput', '-fct'},
    {'CorrelationMapOutput', '-fcm'},
    {'LogFileOutput', '-flg'},
}

Config.CTFFIND4.Lookup = {
    'InputFile',
    'DiagnosticOutput',
    'PixelSize',
    'AccelerationVoltage',
    'ShpericalAberration',
    'AmplitudeContrast',
    'BoxSize',
    'MinimumResolution',
    'MaximumResolution',
    'MinimumDefocus',
    'MaximumDefocus',
    'DefocusSearchStep',
    'AstigmatismTolerance',
    'AdditionalPhaseShift',
    'MinimumPhaseShift',
    'MaximumPhaseShift',
    'PhaseShiftSearchStep'
}

return Config
