#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/raw/'"
OUTDIR="'../../data/klein-dev/convert/'"

IDS="1:47"

	# reset output directory
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "convert( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

