#!/bin/sh

	# arguments
INDIR="../../data/cdd/convert/"
OUTDIR="${INDIR}/test/"

IDS="setdiff( [1:40], 11 )" # 11: two recordings

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "test.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

