#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/convert/"
OUTDIR="../../data/klein-dev/sync/"

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

$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS1 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS2 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS3 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS4 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS5 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS6 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS7 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS8 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS9 ); exit();" &
sleep 3
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS10 ); exit();" &
sleep 3

	# done
wait

