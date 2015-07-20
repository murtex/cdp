#!/bin/sh

	# script arguments
CDFINDIR="'../../data/klein-dev/convert/'"
SYNCINDIR="'../../data/klein-dev/sync/'"
PLOTDIR="'../../data/klein-dev/debug-sync/'"
NTRIALS=20
SEED=1

	# spread workload
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 1:5, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 6:10, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 11:15, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 16:20, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 21:25, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 26:30, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 31:35, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 36:40, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 41:45, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 46:47, $NTRIALS, $SEED ); exit();" &

	# DEBUG
#IDS=5
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, $IDS, $NTRIALS, $SEED ); exit();" &

wait

