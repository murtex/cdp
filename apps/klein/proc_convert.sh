#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/raw/"
OUTDIR="../../data/klein-dev/convert/"

IDS="1:47"

	# reset output
rm -rf $OUTDIR

	# workload
MLARGS="-nosplash -nodesktop"

matlab $MLARGS -r "proc.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &
sleep 3

	# done
wait

