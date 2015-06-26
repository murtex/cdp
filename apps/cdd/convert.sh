#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/raw/'"
OUTDIR="'../../data/cdd/convert/'"
IDS="0:40"

	# spread workload
matlab -nosplash -nodesktop -r "convert( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

