#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/raw/"
OUTDIR="../../data/klein-dev/convert/"

IDS="1:47"

	# reset output
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "proc.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &

	# done
wait

