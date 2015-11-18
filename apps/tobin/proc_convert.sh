#!/bin/sh

	# arguments
INDIR="../../data/tobin/raw/"
OUTDIR="../../data/tobin/convert/"

IDS="3112"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "proc.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

