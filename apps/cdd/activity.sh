#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/sync/'"
OUTDIR="'../../data/cdd/activity/'"

	# spread workload
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 0:4 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 5:9 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 10:14 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 15:19 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 20:24 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 25:29 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 30:34 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 35:39 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 40 ); exit();" &

	# DEBUG
#IDS="[15, 20]"
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

