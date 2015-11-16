#!/bin/sh

	# arguments
INDIR="../../data/cdd/convert/"
OUTDIR="${INDIR}/test/"

IDS="[1:40]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "test.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

