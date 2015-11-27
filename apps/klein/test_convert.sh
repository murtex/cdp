#!/bin/sh

	# arguments
INDIR="../../data/klein/convert/"
OUTDIR="${INDIR}/test/"

IDS="[3:27, 29, 31:47]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "test.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

