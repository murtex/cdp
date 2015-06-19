#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/sync/'"
OUTDIR="'../../data/klein-dev/activity/'"
IDS="1:47"
IDS="13"

	# spread workload
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

