#!/bin/sh

	# arguments
INDIR="../../data/cdd/convert/"
OUTDIR="${INDIR}/test/"

IDS="setdiff( [1:40], 11 )" # 11: two recordings

LOGFILE="${OUTDIR}/${IDS}.log"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "test.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

