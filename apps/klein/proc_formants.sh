#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/activity/"
OUTDIR="../../data/klein-dev/formants/"

IDS1="setdiff( 1:5, 4 )"
IDS2="6:10"
IDS3="11:15"
IDS4="16:20"
IDS5="21:25"
IDS6="26:30"
IDS7="31:35"
IDS8="36:40"
IDS9="41:45"
IDS10="46:47"

POSTPROC="false"

	# reset output
rm -rf $OUTDIR

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS1, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS2, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS3, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS4, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS5, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS6, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS7, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS8, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS9, $POSTPROC ); exit();" &
sleep 3
$MATLAB "proc.formants( '$INDIR', '$OUTDIR', $IDS10, $POSTPROC ); exit();" &
sleep 3

wait

