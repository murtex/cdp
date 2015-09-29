#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/sync/"
OUTDIR="../../data/klein-dev/test/"

IDS="setdiff( 1:47, 4 )"

	# reset output
rm -rf $OUTDIR

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

$MATLAB "test.test( '$INDIR', '$OUTDIR', $IDS ); exit();" &
sleep 3

wait

