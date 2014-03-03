#!/bin/bash
#==============================================================================#
# This file writes a tilt command script and then runs the tilt command.       #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: January 28th 2011                                                   #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= Image stack file <filename.st>                                #
#            $2= String with image size <"integer integer">
#            $2= Global Configuration file /usr/local/eTomo_auto/eTomo_autorc  #
#            $3= Local Configuration (set with eTomo_auto -C <rcfile> )        #
#==============================================================================#

#setup main variables
filename="tilt.com"
base=$(basename $1 .st)
imagesize=$2
gconf=$3
lconf=$4

# Source global and local configuration files
source $gconf
if [ -n "$lconf" ]; then
    source $lconf
fi

printf "%b" "# Command file to run Tilt\n" > $filename

printf "%b" "####CreatedVersion#### 4.0.15\n" >> $filename

printf "%b" "\$tilt -StandardInput\n" >> $filename

printf "%b" "InputProjections ${base}_erase.ali\n" >> $filename

printf "%b" "OutputFile ${base}_full.rec\n" >> $filename

printf "%b" "ActionIfGPUFails $tiltActionIfGPUFails\n" >> $filename

if [ $tiltAdjustOrigin_use -ge 0 ]; then
    printf "%b" "AdjustOrigin \n" >> $filename
fi

printf "%b" "FULLIMAGE $imagesize\n" >> $filename

printf "%b" "IMAGEBINNED 1\n" >> $filename

if [ $tiltLOG_use -ge 0 ]; then
    printf "%b" "LOG $tiltLOG\n" >> $filename
fi

printf "%b" "MODE $tiltMODE\n" >> $filename

if [ $tiltOFFSET_use -ge 0 ]; then
    printf "%b" "OFFSET $tiltOFFSET\n" >> $filename
fi

if [ $tiltPARALLEL_use -ge 0 ]; then
    printf "%b" "PARALLEL\n" >> $filename
elif [ $tiltPERPENDICULAR_use -ge 0 ]; then
    printf "%b" "PERPENDICULAR \n" >> $filename
else
    printf "%b" "Error! Please make sure either PARALLEL or PERPENDICULAR is \
                 chosen in the configuration file (Not Both!)\n"
fi

printf "%b" "RADIAL $tiltRADIAL\n" >> $filename

printf "%b" "SCALE $tiltSCALE\n" >> $filename

printf "%b" "SHIFT $tiltSHIFT\n" >> $filename

if [ $tiltSLICE_use -ge 0 ]; then
    printf "%b" "SLICE $tiltSLICE\n" >> $filename
fi

if [ $tiltSUBSETSTART_use -ge 0 ]; then
    printf "%b" "SUBSETSTART $tiltSUBSETSTART\n" >> $filename
fi

printf "%b" "THICKNESS $tiltTHICKNESS\n" >> $filename

printf "%b" "TILTFILE ${base}.tlt\n" >> $filename

if [ $tiltUseGPU_use -ge 0 ]; then
    printf "%b" "UseGPU $tiltUseGPU\n" >> $filename
fi

if [ $tiltWIDTH_use -ge 0 ]; then
    printf "%b" "WIDTH $tiltWIDTH\n" >> $filename
fi

if [ $tiltXAXISTILT_use -ge 0 ]; then
    printf "%b" "XAXISTILT $tiltXAXISTILT\n" >> $filename
fi

if [ $tiltXTILTFILE_use -ge 0 ]; then
    printf "%b" "XTILTFILE ${base}.xtilt\n" >> $filename
fi
