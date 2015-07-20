#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/convert/'"
OUTDIR="'../../data/cdd/sync/'"

	# prepare directories
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 0:4 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 5:9 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 10:14 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 15:19 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 20:24 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 25:29 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 30:34 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 35:39 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 40 ); exit();" &

	# DEBUG
#matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, [4, 7] ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, [8, 9] ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, [16, 33] ); exit();" &

wait

