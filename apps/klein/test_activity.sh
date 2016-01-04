#!/bin/sh

	# arguments
INDIR="../../data/klein/activity5/"
OUTDIR="${INDIR}/test/"

IDS="[3, 5:27, 29, 31:47]" # DEBUG

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "test.activity( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

