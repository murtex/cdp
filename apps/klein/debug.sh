#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/activity/'"
OUTDIR="'../../data/klein-dev/debug-activity/'"
SEED="1"
NTRIALS=10

	# spread workload
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 1:5, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 6:10, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 11:15, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 16:20, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 21:25, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 26:30, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 31:35, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 36:40, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 41:45, $SEED, $NTRIALS ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 46:47, $SEED, $NTRIALS ); exit();" &

	# DEBUG
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 13, $SEED, $NTRIALS ); exit();" &

wait

