#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/raw/'"
OUTDIR="'../../data/cdd/convert/'"

IDS="0:40"

	# reset output directory
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "convert( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

