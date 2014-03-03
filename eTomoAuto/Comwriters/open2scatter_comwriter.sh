#!/bin/bash
#==============================================================================#
# This file writes a model2point command script as well as a point2model       #
# command script to change the fid model to scatter type for gold erasing      #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: February 22nd 2011                                                  #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= Image stack file <filename.st>                                #
#            $2= Global Configuration file (/usr/local/eTomo_auto/eTomo_autorc #
#            $3= Local Configuration (set with eTomo_auto -C <rcfile> )        #
#==============================================================================#

# Setup main variables 
m2pfilename="model2point.com"
p2mfilename="point2model.com"
base=$(basename $1 .st)
gconf=$2
lconf=$3

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

# Handle the comscript for model2point
printf "%b" "# THIS IS A COMMAND FILE TO RUN MODEL2POINT\n" > $m2pfilename

printf "%b" "\$model2point -StandardInput\n" >> $m2pfilename

printf "%b" "InputFile ${base}_erase.fid\n" >> $m2pfilename

printf "%b" "OutputFile ${base}_erase.fid.txt\n" >> $m2pfilename

if [ $model2pointFloatingPoint_use -ge 0 ]; then
    printf "%b" "FloatingPoint\n" >> $m2pfilename
fi

if [ $model2pointScaledCoordinates_use -ge 0 ]; then
    printf "%b" "ScaledCoordinates\n" >> $m2pfilename
fi

if [ $model2pointObjectAndContour_use -ge 0 ]; then
    printf "%b" "ObjectAndContour\n" >> $m2pfilename
fi

if [ $model2pointContour_use -ge 0 ]; then
    printf "%b" "Contour\n" >> $m2pfilename
fi

if [ $model2pointNumberedFromZero_use -ge 0 ]; then
    printf "%b" "NumberedFromZero\n" >> $m2pfilename
fi

# Handle the comscript for point2model
printf "%b" "# THIS IS A COMMAND FILE TO RUN POINT2MODEL\n" > $p2mfilename

printf "%b" "\$point2model -StandardInput\n" >> $p2mfilename

printf "%b" "InputFile ${base}_erase.fid.txt\n" >> $p2mfilename

printf "%b" "OutputFile ${base}_erase.scatter.fid\n" >> $p2mfilename

if [ $point2modelOpenContours_use -ge 0 ]; then
    printf "%b" "OpenContours\n" >> $p2mfilename
fi

if [ $point2modelScatteredPoints_use -ge 0 ]; then
    printf "%b" "ScatteredPoints\n" >> $p2mfilename
fi

if [ $point2modelPointsPerContour_use -ge 0 ]; then
    printf "%b" "PointsPerContour $point2modelPointsPerContour\n" >> $p2mfilename
fi

if [ $point2modelPlanarContours_use -ge 0 ]; then
    printf "%b" "PlanarContours\n" >> $p2mfilename
fi

if [ $point2modelNumberedFromZero_use -ge 0 ]; then
    printf "%b" "NumberedFromZero\n" >> $p2mfilename
fi

printf "%b" "CircleSize $point2modelCircleSize\n" >> $p2mfilename

if [ $point2modelSphereRadius_use -ge 0 ]; then
    printf "%b" "SphereRadius $point2modelSphereRadius\n" >> $p2mfilename
fi

printf "%b" "ColorOfObject $point2modelColorOfObject\n" >> $p2mfilename

printf "%b" "ImageForCoordinates ${base}.ali\n" >> $p2mfilename
