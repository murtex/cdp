#!/bin/sh

	# arguments
INDIR="../../data/cdd/raw/"
OUTDIR="../../data/cdd/convert/"

IDS="[1:40]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "proc.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

