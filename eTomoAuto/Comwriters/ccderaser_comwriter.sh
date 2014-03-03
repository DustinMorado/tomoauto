#!/bin/bash
#==============================================================================#
# This file writes a ccderaser command script and then runs the ccderaser      #
# command                                                                      #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: January 20th 2011                                                   #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= Image stack file <filename.st>                                #
#            $2= Global Configuration file (/usr/local/eTomo_auto/eTomo_autorc #
#            $3= Local Configuration (set with eTomo_auto -C <rcfile> )        #
#==============================================================================#

# Setup main variables 
filename="ccderaser.com"
base=$(basename $1 .st)
gconf=$2
lconf=$3

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

printf "%b" "# THIS IS A COMMAND FILE TO RUN CCDERASER\n" > $filename

printf "%b" "####CreatedVersion#### 3.7.2\n" >> $filename

printf "%b" "\$ccderaser -StandardInput\n" >> $filename

printf "%b" "InputFile $1\n" >> $filename

printf "%b" "OutputFile ${base}_fixed.st\n" >> $filename

printf "%b" "PointModel ${base}_peak.mod\n" >> $filename

printf "%b" "FindPeaks\n" >> $filename

printf "%b" "PeakCriterion $ccderaserPeakCriterion\n" >> $filename

printf "%b" "DiffCriterion $ccderaserDiffCriterion\n" >> $filename

printf "%b" "GrowCriterion $ccderaserGrowCriterion\n" >> $filename

printf "%b" "ScanCriterion $ccderaserScanCriterion\n" >> $filename

printf "%b" "MaximumRadius $ccderaserMaximumRadius\n" >> $filename

printf "%b" "AnnulusWidth $ccderaserAnnulusWidth\n" >> $filename

printf "%b" "XYScanSize $ccderaserXYScanSize\n" >> $filename

printf "%b" "EdgeExclusionWidth $ccderaserEdgeExclusionWidth\n" >> $filename

printf "%b" "BorderSize $ccderaserBorderSize\n" >> $filename

printf "%b" "PolynomialOrder $ccderaserPolynomialOrder\n" >> $filename
