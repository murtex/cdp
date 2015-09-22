#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/raw/"
OUTDIR="../../data/klein-dev/convert/"

IDS="1:47"

	# reset output
rm -rf $OUTDIR

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "proc.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &
sleep 3

wait

