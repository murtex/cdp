#!/bin/sh

	# arguments
INDIR="../../data/cdd/raw/"
OUTDIR="../../data/cdd/convert/"

IDS="setdiff( [1:40], 11 )" # 11: two recordings

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "proc.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

