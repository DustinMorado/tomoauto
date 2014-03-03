#!/bin/bash
#==============================================================================#
# This file writes a ccderaser command script and then runs the ccderaser      #
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
filename="gold_ccderaser.com"
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

printf "%b" "InputFile ${base}.ali\n" >> $filename

printf "%b" "OutputFile ${base}_erase.ali\n" >> $filename

printf "%b" "ModelFile ${base}_erase.fid\n" >> $filename

printf "%b" "CircleObjects $gccderaserCircleObjects\n" >> $filename

printf "%b" "BetterRadius $gccderaserBetterRadius\n" >> $filename

if [ $gccderaserMergePatches -ge 0 ]; then
    printf "%b" "MergePatches\n" >> $filename
fi

printf "%b" "PolynomialOrder $gccderaserPolynomialOrder\n" >> $filename

if [ $gccderaserExcludeAdjacent -ge 0 ]; then
    printf "%b" "ExcludeAdjacent" >> $filename
fi
