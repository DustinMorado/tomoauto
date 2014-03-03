# Command file to run ctfphaseflip
#
####CreatedVersion#### 3.12.20
# 
$ctfphaseflip -StandardInput
InputStack  BB0773DEC16B010.ali
AngleFile   BB0773DEC16B010.tlt
OutputFileName	BB0773DEC16B010_ctfcorr.ali
#
# Defocus file from ctfplotter (see man page for format)
DefocusFile	BB0773DEC16B010.defocus
#
# Microscope voltage in kV
Voltage	300
#
# Microscope spherical aberration in millimeters
SphericalAberration	2.0
#
# Defocus tolerance in nanometers limiting the strip width
DefocusTol	200
#
# Image pixel size in nanometers
PixelSize	0.504
#
# Fraction of amplitude contrast
AmplitudeContrast	0.07
#
# The distance in pixels between two consecutive strips
InterpolationWidth	20
$if (-e ./savework) ./savework
