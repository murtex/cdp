#!/bin/sh

	# arguments
INDIR="../../data/cdd/sync/"
OUTDIR="${INDIR}/test/"

IDS1="[1:5]"
IDS2="[6:10]"
IDS3="[11:15]"
IDS4="[16:20]"
IDS5="[21:25]"
IDS6="[26:30]"
IDS7="[31:35]"
IDS8="[36:40]"

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

