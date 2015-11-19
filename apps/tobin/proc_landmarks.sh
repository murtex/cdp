#!/bin/sh

	# arguments
INDIR="../../data/tobin/convert/"
OUTDIR="../../data/tobin/landmarks/"

IDS="3112"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "proc.landmarks( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

