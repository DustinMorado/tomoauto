#!/bin/bash
#==============================================================================#
# This file writes a tiltxcorr command script and then runs the tiltxcorr      #
# command                                                                      #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: January 27th 2011                                                   #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= Image stack file <filename.st>                                #
#            $2= Rotation (Read from stack header)                             #
#            $3= Global Configuration file (/usr/local/eTomo_auto/eTomo_autorc #
#            $4= Local Configuration (set with eTomo_auto -C <rcfile> )        #
#==============================================================================#

# Setup main variables
filename=tiltxcorr.com
base=$(basename $1 .st)
rotation=$2
gconf=$3
lconf=$4

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

printf "%b" "# THIS IS A COMMAND FILE TO RUN TILTXCORR\n" > $filename

printf "%b" "####CreatedVersion#### 3.4.4\n" >> $filename

printf "%b" "\$tiltxcorr -StandardInput\n" >> $filename

printf "%b" "InputFile $1\n" >> $filename

printf "%b" "OutputFile ${base}.prexf\n" >> $filename

printf "%b" "TiltFile ${base}.rawtlt\n" >> $filename

printf "%b" "RotationAngle $2\n" >> $filename

printf "%b" "AngleOffset $tiltxcorrAngleOffset\n" >> $filename

printf "%b" "FilterRadius2 $tiltxcorrFilterRadius2\n" >> $filename

printf "%b" "FilterSigma1 $tiltxcorrFilterSigma1\n" >> $filename

printf "%b" "FilterSigma2 $tiltxcorrFilterSigma2\n" >> $filename

if [ $tiltxcorrExcludeCentralPeak -ge 0 ]; then
    printf "%b" "ExcludeCentralPeak\n" >> $filename
fi

if [ $tiltxcorrBordersInXandY_use -ge 0 ]; then
    printf "%b" "BordersInXandY $tiltxcorrBordersInXandY\n" >> $filename
fi

if [ $tiltxcorrXMinAndMax_use -ge 0 ]; then
    printf "%b" "XMinAndMax $tiltxcorrXMinAndMax\n" >> $filename
fi

if [ $tiltxcorrYMinAndMax_use -ge 0 ]; then
    printf "%b" "YMinAndMax $tiltxcorrYMinAndMax\n" >> $filename
fi

if [ $tiltxcorrPadsInXandY_use -ge 0 ]; then
    printf "%b" "PadsInXandY $tiltxcorrPadsInXandY\n" >> $filename
fi

if [ $tiltxcorrTapersInXandY_use -ge 0 ]; then
    printf "%b" "TapersInXandY $tiltxcorrTapersInXandY\n" >> $filename
fi

if [ $tiltxcorrStartingEndingViews_use -ge 0 ]; then
    printf "%b" "StartingEndingViews $tiltxcorrStartingEndingViews \
                \n" >> $filename  
fi

if [ $tiltxcorrCumulativeCorrelation -ge 0 ]; then
    printf "%b" "CumulativeCorrelation\n" >> $filename
fi

if [ $tiltxcorrAbsoluteCosineStretch -ge 0 ]; then
    printf "%b" "AbsoluteCosineStretch\n" >> $filename
fi

if [ $tiltxcorrNoCosineStretch -ge 0 ]; then
    printf "%b" "NoCosineStretch\n" >> $filename
fi

if [ $tiltxcorrTestOutput -ge 0 ]; then
    printf "%b" "TestOutput ${base}_test.img\n" >> $filename
fi
