#!/bin/bash
#==============================================================================#
# This file writes a newstack command script and then runs the newstack        #
# command.                                                                     #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: January 27th 2011                                                   #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= Image stack file <filename.st>                                #
#            $2= Global Configuration file /usr/local/eTomo_auto/eTomo_autorc  #
#            $3= Local Configuration (set with eTomo_auto -C <rcfile> )        #
#==============================================================================#

# Setup main variables
filename=newstack.com
base=$(basename $1 .st)
gconf=$2
lconf=$3

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

printf "%b" "# THIS IS A COMMAND FILE TO PRODUCE A PRE-ALIGNED STACK \
             \n" >> $filename

printf "%b" "####CreatedVersion#### 1.0.0\n" >> $filename

printf "%b" "\$newstack -StandardInput\n" >> $filename

printf "%b" "InputFile $1\n" >> $filename

printf "%b" "OutputFile ${base}.preali\n" >> $filename

printf "%b" "TransformFile ${base}.prexg\n" >> $filename

printf "%b" "ModeToOutput $newstackModeToOutput\n" >> $filename

printf "%b" "FloatDensities $newstackFloatDensities\n" >> $filename

if [ $newstackContrastBlackWhite_use -ge 0 ]; then
    printf "%b" "ContrastBlackWhite $newstackContrastBlackWhite\n" >> $filename
fi

if [ $newstackScaleMinAndMax_use -ge 0 ]; then
    printf "%b" "ScaleMinAndMax $newstackScaleMinAndMax\n" >> $filename
fi
