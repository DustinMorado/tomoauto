#!/bin/bash
#==============================================================================#
# This file writes a xftoxg command script and then runs the xftoxg command.   #
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
filename=xftoxg.com
base=$(basename $1 .st)
gconf=$2
lconf=$3

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

printf "%b" "# THIS IS A COMMAND FILE TO RUN XFTOXG\n" > $filename

printf "%b" "####CreatedVersion#### 1.0.0\n" >> $filename

printf "%b" "\$xftoxg -StandardInput\n" >> $filename

printf "%b" "InputFile ${base}.prexf\n" >> $filename

printf "%b" "GOutputFile ${base}.prexg\n" >> $filename

printf "%b" "NumberToFit $xftoxgNumberToFit\n" >> $filename

if [ $xftoxgReferenceSection_use -ge 0 ]; then
    printf "%b" "ReferenceSection $xftoxgReferenceSection\n" >> $filename
fi

if [ $xftoxgOrderOfPolynomialFit_use -ge 0 ]; then
    printf "%b" "PolynomialFit $xftoxgPolynomialFit\n" >> $filename
fi

if [ $xftoxgHybridFits_use -ge 0 ]; then
    printf "%b" "HybridFits $xftoxgHybridFits\n" >> $filename
fi

if [ $xftoxgRangeOfAnglesInAverage_use -ge 0 ]; then
    printf "%b" "RangeOfAnglesInAverage $xftoxgRangeOfAnglesInAverage \
                 \n" >> $filename
fi
