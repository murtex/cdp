#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/activity/"
OUTDIR="../../data/klein-dev/landmarks/"

IDS1="1:5"
IDS2="6:10"
IDS3="11:15"
IDS4="16:20"
IDS5="21:25"
IDS6="26:30"
IDS7="31:35"
IDS8="36:40"
IDS9="41:45"
IDS10="46:47"

	# reset output
rm -rf $OUTDIR

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS1 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS2 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS3 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS4 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS5 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS6 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS7 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS8 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS9 ); exit();" &
sleep 3
$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS10 ); exit();" &
sleep 3

wait

