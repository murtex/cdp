#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/label/'"
OUTDIR="'../../data/cdd/label/'"

	# workload
matlab -nosplash -nodesktop -r "label( $INDIR, $OUTDIR, 1 ); exit();"
