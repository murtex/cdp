#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/convert/proc/"
OUTDIR="../../data/klein-dev/convert/test/"

IDS="1:47"

	# reset output directory
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "test.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &

wait

