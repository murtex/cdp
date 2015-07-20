#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/raw/'"
OUTDIR="'../../data/klein-dev/convert/'"

IDS="1:47"

	# prepare directories
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "convert( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

