#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/sync/proc/"
OUTDIR="../../data/klein-dev/sync/test/"

IDS="1:47"

	# reset output directory
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "test.sync( '$INDIR', '$OUTDIR', $IDS ); exit();" &

wait

