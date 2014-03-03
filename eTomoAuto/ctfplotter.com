# command file to run ctfplotter
#
####CreatedVersion#### 3.12.20
# 
#
$ctfplotter -StandardInput
#
InputStack  BB0773DEC16B010.st
#
# The tilt angle file - .rawtlt could be used instead if .tlt not available yet
AngleFile   BB0773DEC16B010.tlt
DefocusFile BB0773DEC16B010.defocus
#
# How many degrees the tilt axis deviates from vertical (Y axis) (CCW positive)
AxisAngle	-78.5
#
# Image pixel size in nanometers
PixelSize	0.504
#
# Expected defocus at the tilt axis in nanometers (underfocus is positive)
ExpectedDefocus	8000.0
#
# Starting and ending tilt angles for initial analysis
AngleRange  -20.0  20.0
#
# Microscope voltage in kV
Voltage	300
#
# Microscope spherical aberration in millimeters
SphericalAberration	2.0
#
# Fraction of amplitude contrast
AmplitudeContrast	0.07
#
# Defocus tolerance in nanometers defining the center strips
DefocusTol   200
PSResolution 101
TileSize     256
LeftDefTol  2000.0
RightDefTol 2000.0 
ConfigFile	/home/jliu/K2background/polara-K2-2013.ctg
$if (-e ./savework) ./savework
