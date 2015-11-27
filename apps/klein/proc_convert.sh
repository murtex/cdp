#!/bin/sh

	# arguments
INDIR="../../data/klein/raw/"
OUTDIR="../../data/klein/convert/"

IDS="[3:27, 29, 31:47]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

LOGFILE="${OUTDIR}/${IDS}.log"

$MATLAB "proc.convert( '$INDIR', '$OUTDIR', $IDS, '$LOGFILE' ); exit();" &

wait

