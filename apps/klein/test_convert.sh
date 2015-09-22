#!/bin/sh

	# arguments
INDIR="../../data/klein-dev/convert/"
OUTDIR="$INDIR/test/"

IDS="1:47"

	# reset output
rm -rf $OUTDIR

	# workload
MLARGS="-nosplash -nodesktop"

matlab $MLARGS -r "test.convert( '$INDIR', '$OUTDIR', $IDS ); exit();" &
sleep 3

	# done
wait

