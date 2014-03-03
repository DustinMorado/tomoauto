#!/bin/bash
#==============================================================================#
# This is a wrapper to handle all of the other scripts to align a raw stack,   #
# and then uses RAPTOR to make a final alignment, and then eTomo to create the #
# reconstruction.                                                              #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: January 21st 2011                                                   #
# Contact: Dustin.Morado@uth.tmc.edu                                           #
#------------------------------------------------------------------------------#
# Arguments: $1= image stack file <filename.st>                                #
#            $2= fiducial size in nm <integer>                                 #
#==============================================================================#

# Make a variable to point to the root directory of eTomo_auto 
root_dir=$ETOMOAUTOROOT
[ ! -d $root_dir ] && printf "%b" 'ETOMOAUTOROOT not set!\n' && exit 2

# Make a variable for the start directory and the global config file
start_dir=$PWD
Gconf=$ETOMOAUTOROOT/eTa.conf
Lconf=

# Make variables to point to the directory of the helper
# and comwriter scripts
helper_dir=$root_dir/Helpers
comwriter_dir=$root_dir/Comwriters

# Handling Arguments with getopts
Cflag=-1
gflag=-1
hflag=-1
jflag=-1
Pflag=-1
xflag=-1
while getopts 'C:ghjP:x' OPTION
do
    case $OPTION in
        C)  Cflag=1
            Lconf="$OPTARG"
            ;;
        g)  gflag=1
            ;;
        h)  hflag=1
            ;;
        j)  jflag=1
            ;;
        P)  Pflag=1
            procnum="$OPTARG"
            ;;
        x)  xflag=1
            ;;
        ?)  printf "%b" "Invalid options please use eTomo_auto.sh -h for usage \
            \n" >&2
            exit 0
            ;;
    esac
done
shift $(($OPTIND -1))

# Here we catch the -h flag and display usage information
if [ $hflag -ge 0 ]; then
    ${helper_dir}/dispHelp 
    exit 0
fi

# See if -g and -P were run together
if [ $Pflag -ge 0 ]; then
    if [ $gflag -ge 0 ]; then
        printf "%b" "Cannot run GPU and Parallel at same time\n" >&2
        exit 3
    fi
fi

# Make variables for the base of the filename and a pointer for the file itself 
# Also make a variable for fiducial marker size so its more readable.
base=$(basename $1 .st)
file=$1
fidsize=$2

# Create the .rawtlt file for tilt angles
$helper_dir/spaceHelp $file 98
freespace_check=$?
if [ $freespace_check -ne 0 ]; then
    printf "%b" "ERROR: Disk usage is at or above 98% please make more space \
                 \n" >&2
    exit 3
fi
printf "%b" "running extracttilts for $file\n"
extracttilts -input $file -output ${base}.rawtlt 2>&1 > /dev/null
extracttilts_exit=$?
if [ $extracttilts_exit -ne 0 ]; then
    printf "%b" "Error in running extracttilts!\n" >&2
    exit 3
fi

# Get pixelsize and rotation size float fiducial size in pixels from the header
# Added as well to get the imagesize (DRM 02/22/2011)
${helper_dir}/headerHelp $file $fidsize
rotation=$(cat rotationfile)
fidint=$(cat fidfile)
imagesize=$(cat imagesize)
# Clean up the files used to get the data.
rm -f rotationfile fidfile imagesize

# Make copies of initial files for clean-up afterwards
set -e
mkdir Final_files 
cp $file Final_files/. 
set +e

# Now we adjust the image stack to create a more realistic histogram
if [ $jflag -le 0 ]; then
    ${helper_dir}/cleanHelp $file 
fi

# If we catch the -x flag then we remove the Xrays using ccderaser
if [ $xflag -ge 0 ]; then
    printf "%b" "Running ccderaser for $file\n"
    ${comwriter_dir}/ccderaser_comwriter.sh $file $Gconf $Lconf
    submfg -t ccderaser.com
    ccderaser_exit=$?
    if [ $ccderaser_exit -ne 0 ]; then
        printf "%b" "ERROR: ccderaser UNSUCCESSFUL!\n" >&2
        ${helper_dir}/garbageHelp $file
        exit 3
    fi
    mv $file ${base}_orig.st && mv ${base}_fixed.st $file 
    cat ccderaser.log > eTomo_auto.log && rm -f ccderaser.*
fi

# Now we run the second step which is to calculate a cross correlation
# and use this to generate a coarse aligned stack used to create our
# fiducial model and final aligned stack
printf "%b" "Running Coarse Alignment for $file\n"
${comwriter_dir}/tiltxcorr_comwriter.sh $file $rotation $Gconf $Lconf
${comwriter_dir}/xftoxg_comwriter.sh $file $Gconf $Lconf
${comwriter_dir}/newstack_comwriter.sh $file $Gconf $Lconf
submfg -t tiltxcorr.com xftoxg.com newstack.com
coarsealign_exit=$?
if [ $coarsealign_exit -ne 0 ]; then
    printf "%b" "ERROR: Coarse Alignment UNSUCCESSFUL!\n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
set -e
cat tiltxcorr.log >> eTomo_auto.log
cat xftoxg.log >> eTomo_auto.log
cat newstack.log >> eTomo_auto.log
rm -f tiltxcorr.*
rm -f xftoxg.*
rm -f newstack.*
set +e

# Now we run RAPTOR to produce a succesfully aligned stack
printf "%b" "Now running RAPTOR (please be patient this may take some time)\n"
printf "%b" "RAPTOR starting for $file..........\n"
$helper_dir/spaceHelp $file 98
freespace_check=$?
if [ $freespace_check -ne 0 ]; then
    printf "%b" "ERROR: Disk usage is at or above 98% please make more space \
                 \n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
RAPTOR -execPath /usr/local/RAPTOR3.0/bin/ -path $start_dir -input ${base}.preali \
       -output $start_dir/raptor1 -diameter $fidint
raptor1_exit=$?
if [ $raptor1_exit -ne 0 ]; then
    printf "%b" "ERROR: RAPTOR Alignment UNSUCCESSFUL!\n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
set -e
mv $start_dir/raptor1/align/${base}.ali $start_dir
cat $start_dir/raptor1/align/${base}_IMOD.log >> eTomo_auto.log
cat $start_dir/raptor1/align/${base}_RAPTOR.log >> eTomo_auto.log
mv $start_dir/raptor1/IMOD/${base}.tlt $start_dir
mv $start_dir/raptor1/IMOD/${base}.xf $start_dir
rm -rf $start_dir/raptor1
set +e
printf "%b" "RAPTOR alignment for $file SUCCESSFUL\n"

# Now we use RAPTOR to make a fiducial model to erase the gold in the stack
printf "%b" "Now running RAPTOR to track gold to erase gold particles\n"
printf "%b" "RAPTOR starting for $file..........\n"
$helper_dir/spaceHelp $file 98
freespace_check=$?
if [ $freespace_check -ne 0 ]; then
    printf "%b" "ERROR: Disk usage is at or above 98% please make more space \
                 \n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
RAPTOR -execPath /usr/local/RAPTOR3.0/bin/ -path $start_dir -input ${base}.ali \
       -output $start_dir/raptor2 -diameter $fidint -tracking
raptor2_exit=$?
if [ $raptor2_exit -ne 0 ]; then
    printf "%b" "ERROR: RAPTOR Fiducial Model UNSUCCESSFUL\n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
set -e
cat $start_dir/raptor2/align/${base}_RAPTOR.log >> eTomo_auto.log
mv $start_dir/raptor2/IMOD/${base}.fid.txt $start_dir/${base}_erase.fid
rm -rf $start_dir/raptor2

# Make the erase model more suitable for erasing gold
${comwriter_dir}/open2scatter_comwriter.sh $file $Gconf $Lconf 
submfg -t model2point.com point2model.com
open2scatter_exit=$?
if [ $open2scatter_exit -ne 0 ]; then
    printf "%b" "ERROR: Model conversion UNSUCCESSFUL!\n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
mv $start_dir/${base}_erase.fid $start_dir/${base}_erase.fid_orig
mv $start_dir/${base}_erase.scatter.fid $start_dir/${base}_erase.fid
cat $start_dir/model2point.log >> eTomo_auto.log && rm model2point.*
cat $start_dir/point2model.log >> eTomo_auto.log && rm point2model.*
set +e
printf "%b" "Fiducial model created for $file SUCCESSFUL\n"
$comwriter_dir/gold_comwriter.sh $file $Gconf $Lconf

# Finally we run the tilt com script and produce a reconstruction

$comwriter_dir/tilt_comwriter.sh $file "$imagesize" $Gconf $Lconf

# If g flag is caught add GPU option to tilt.com
if [ $gflag -ge 0 ]; then
    printf "%b" "UseGPU 0\n" >> tilt.com
fi

# If P flag is caught setup splittilt and processchunks
if [ $Pflag -ge 0 ]; then
    submfg -t gold_ccderaser.com 
    gold_exit=$?
    if [ $gold_exit -ne 0 ]; then
        printf "%b" "ERROR: Erasing gold UNSUCCESSFUL\n" >&2
        ${helper_dir}/garbageHelp $file
        exit 3
    fi
    splittilt -n $procnum tilt.com
    processchunks -g -P $procnum tilt
else
    submfg -t gold_ccderaser.com tilt.com
fi
reconstruction_exit=$?
if [ $reconstruction_exit -ne 0 ]; then
    printf "%b" "ERROR: Reconstruction UNSUCCESSFUL\n" >&2
    ${helper_dir}/garbageHelp $file
    exit 3
fi
set -e
cat gold_ccderaser.log >> eTomo_auto.log
if [ $Pflag -ge 0 ]; then 
    cat tilt-start.log >> eTomo_auto.log
    cat tilt.log >> eTomo_auto.log
    cat tilt-finish.log >> eTomo_auto.log
    rm -f tilt-* tilt.* 
else
    cat tilt.log >> eTomo_auto.log
    rm -f tilt.*
fi
if [ -s $start_dir/gpu_etomorc ]; then
    rm -f $start_dir/gpu_etomorc
fi
rm -f gold_ccderaser.*
set +e

# Cleanup !
printf "%b" "Running Cleanup for $file!\n"
$helper_dir/spaceHelp $file 98
freespace_check=$?
if [ $freespace_check -ne 0 ]; then
    printf "%b" "ERROR: Disk usage is at or above 98% please make more space \
                 \n" >&2
    exit 3
fi
mv ${base}_full.rec eTomo_auto.log Final_files/. && rm -f ${base}* 
mv Final_files/* . && rmdir Final_files

# Create a 4 binned reconstruction and apply a low-pass filter copy
printf "%b" "Binning the reconstruction for $file\n"
binvol -binning 4 ${base}_full.rec ${base}.bin4 2>&1 > /dev/null
binvol_exit=$?
if [ $binvol_exit -ne 0 ]; then
    printf "%b" "ERROR: binvol UNSUCCESSFUL\n" >&2
    exit 3
fi
if [ $jflag -le 0 ]; then
    permute -perm 1 0 0 0 0 1 0 1 0 ${base}.bin4 ${base}.bin4.perm
    permute_exit=$?
    if [ $permute_exit -ne 0 ]; then
        printf "%b" "ERROR: permute UNSUCCESSFUL\n" >&2
        exit 3
    fi
    compute-old ${base}.bin4.rev = ${base}.bin4.perm / -1
    compute_exit=$?
    if [ $compute_exit -ne 0 ]; then
        printf "%b" "ERROR: compute UNSUCCESSFUL\n" >&2
    exit 3
    fi
    printf "%b" "Running a low-pass filter for $file\n"
    filter -ccp4 -fd 0.6 0.6 0.6 -fs 0.1 0.1 0.1 ${base}.bin4.rev ${base}.bin4.low
    filter_exit=$?
    if [ $filter_exit -ne 0 ]; then
        printf "%b" "ERROR: filter UNSUCCESSFUL\n" >&2
        exit 3
    fi
    printf "%b" "Fixing Header for $file\n"
    fixheader -ccp4 ${base}.bin4.low
    fixheader_exit=$?
    if [ $fixheader_exit -ne 0 ]; then
        printf "%b" "ERROR: fixheader UNSUCCESSFUL\n" >&2
        exit 3
    fi
    preproc-old -med -m 1 1 9  ${base}.bin4.low ${base}.med7
    preproc_exit=$?
    if [ $preproc_exit -ne 0 ]; then
        printf "%b" "ERROR: preproc UNSUCCESSFUL\n" >&2
        exit 3
    fi
    rm -f  ${base}.bin4.perm ${base}.bin4.rev ${base}.bin4
    printf "%b" "Final filters and cleanup for $file\n"
    filter -fd 0.4 0.4 0.4 -fs 0.1 0.1 0.1 -fdi 0.01 0.01 0.01 -fsi \
               0.005 0.005 0.005 ${base}.med7 ${base}.low7
    filter_exit=$?
    if [ $filter_exit -ne 0 ]; then
        printf "%b" "ERROR: filter UNSUCCESSFUL\n" >&2
        exit 3
    fi
    rm -f ${base}.med7
fi
printf "%b" "eTomo_auto complete for $file\n"
exit 0
