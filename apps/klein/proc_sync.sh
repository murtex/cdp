#!/bin/sh

	# arguments
INDIR="../../data/klein/convert/"
OUTDIR="../../data/klein/sync/"

IDS1="[3:8]"
IDS2="[9:14]"
IDS3="[15:20]"
IDS4="[21:25]"
IDS5="[26:27, 29, 31:32]"
IDS6="[33:37]"
IDS7="[38:42]"
IDS8="[42:47]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE1="${OUTDIR}/${IDS1}.log"
LOGFILE2="${OUTDIR}/${IDS2}.log"
LOGFILE3="${OUTDIR}/${IDS3}.log"
LOGFILE4="${OUTDIR}/${IDS4}.log"
LOGFILE5="${OUTDIR}/${IDS5}.log"
LOGFILE6="${OUTDIR}/${IDS6}.log"
LOGFILE7="${OUTDIR}/${IDS7}.log"
LOGFILE8="${OUTDIR}/${IDS8}.log"

$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS1, '$LOGFILE1' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS2, '$LOGFILE2' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS3, '$LOGFILE3' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS4, '$LOGFILE4' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS5, '$LOGFILE5' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS6, '$LOGFILE6' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS7, '$LOGFILE7' ); exit();" &
$MATLAB "proc.sync( '$INDIR', '$OUTDIR', $IDS8, '$LOGFILE8' ); exit();" &

wait

