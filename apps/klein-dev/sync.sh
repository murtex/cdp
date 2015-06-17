#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/convert/'"
OUTDIR="'../../data/klein-dev/sync/'"
IDS="1:47"
IDS="23"

	# spread workload
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

