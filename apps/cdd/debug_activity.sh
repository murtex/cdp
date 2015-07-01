#!/bin/sh

	# script arguments
INDIR="'../../data/cdd/activity/'"
OUTDIR="'../../data/cdd/debug-activity/'"
NTRIALS=20
SEED=1

	# spread workload
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 0:4, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 5:9, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 10:14, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 15:19, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 20:24, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 25:29, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 30:34, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 35:39, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, 40, $NTRIALS, $SEED ); exit();" &

	# DEBUG
#IDS="[15, 20]"
#IDS=8
#matlab -nosplash -nodesktop -r "debug_activity( $INDIR, $OUTDIR, $IDS, $NTRIALS, $SEED ); exit();" &

wait

