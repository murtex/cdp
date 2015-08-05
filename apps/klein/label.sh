#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/label/'"
OUTDIR="'../../data/klein-dev/label/'"

	# workload
matlab -nosplash -nodesktop -r "label( $INDIR, $OUTDIR, 13 ); exit();"

