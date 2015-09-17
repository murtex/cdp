#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/raw/"
OUTDIR="../../data/klein-dev/convert/proc/"

IDS="1:47"

	# reset output directory
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "proc.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &

wait

