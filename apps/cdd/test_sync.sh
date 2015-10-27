#!/bin/sh

	# arguments
INDIR="../../data/cdd/sync/"
OUTDIR="${INDIR}/test/"

IDS1="[1:5]"
IDS2="[6:10]"
IDS3="setdiff( [11:15], 11 )" # 11: two recordings
IDS4="[16:20]"
IDS5="[21:25]"
IDS6="[26:30]"
IDS7="[31:35]"
IDS8="[36:40]"

LOGFILE1="${OUTDIR}/${IDS1}.log"
LOGFILE2="${OUTDIR}/${IDS2}.log"
LOGFILE3="${OUTDIR}/${IDS3}.log"
LOGFILE4="${OUTDIR}/${IDS4}.log"
LOGFILE5="${OUTDIR}/${IDS5}.log"
LOGFILE6="${OUTDIR}/${IDS6}.log"
LOGFILE7="${OUTDIR}/${IDS7}.log"
LOGFILE8="${OUTDIR}/${IDS8}.log"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS1, '$LOGFILE1' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS2, '$LOGFILE2' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS3, '$LOGFILE3' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS4, '$LOGFILE4' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS5, '$LOGFILE5' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS6, '$LOGFILE6' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS7, '$LOGFILE7' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS8, '$LOGFILE8' ); exit();" &

wait

