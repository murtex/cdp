#!/bin/sh

	# arguments
INDIR="../../data/klein/convert/"
OUTDIR="${INDIR}/extra/vots_all/"

IDS="[3:27, 29, 31:47]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "extra.vots( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

