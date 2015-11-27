#!/bin/sh

	# arguments
INDIR="../../data/klein/sync/"
OUTDIR="${INDIR}/test/"

IDS1="[3:8]"
IDS2="[9:14]"
IDS3="[15:20]"
IDS4="[21:25]"
IDS5="[26:27, 29, 31:32]"
IDS6="[33:37]"
IDS7="[38:42]"
IDS8="[42:47]"

NTRIALS="20"
RNDSEED="1"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE1="${OUTDIR}/${IDS1}.log" # statistics
LOGFILE2="${OUTDIR}/${IDS2}.log"
LOGFILE3="${OUTDIR}/${IDS3}.log"
LOGFILE4="${OUTDIR}/${IDS4}.log"
LOGFILE5="${OUTDIR}/${IDS5}.log"
LOGFILE6="${OUTDIR}/${IDS6}.log"
LOGFILE7="${OUTDIR}/${IDS7}.log"
LOGFILE8="${OUTDIR}/${IDS8}.log"

$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS1, '$LOGFILE1' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS2, '$LOGFILE2' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS3, '$LOGFILE3' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS4, '$LOGFILE4' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS5, '$LOGFILE5' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS6, '$LOGFILE6' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS7, '$LOGFILE7' ); exit();" &
$MATLAB "test.sync( '$INDIR', '$OUTDIR', $IDS8, '$LOGFILE8' ); exit();" &

LOGFILE1="${OUTDIR}/${IDS1}_samples.log" # samples
LOGFILE2="${OUTDIR}/${IDS2}_samples.log"
LOGFILE3="${OUTDIR}/${IDS3}_samples.log"
LOGFILE4="${OUTDIR}/${IDS4}_samples.log"
LOGFILE5="${OUTDIR}/${IDS5}_samples.log"
LOGFILE6="${OUTDIR}/${IDS6}_samples.log"
LOGFILE7="${OUTDIR}/${IDS7}_samples.log"
LOGFILE8="${OUTDIR}/${IDS8}_samples.log"

$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS1, $NTRIALS, $RNDSEED, '$LOGFILE1' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS2, $NTRIALS, $RNDSEED, '$LOGFILE2' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS3, $NTRIALS, $RNDSEED, '$LOGFILE3' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS4, $NTRIALS, $RNDSEED, '$LOGFILE4' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS5, $NTRIALS, $RNDSEED, '$LOGFILE5' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS6, $NTRIALS, $RNDSEED, '$LOGFILE6' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS7, $NTRIALS, $RNDSEED, '$LOGFILE7' ); exit();" &
$MATLAB "test.sync_samples( '$INDIR', '$OUTDIR', $IDS8, $NTRIALS, $RNDSEED, '$LOGFILE8' ); exit();" &

wait

