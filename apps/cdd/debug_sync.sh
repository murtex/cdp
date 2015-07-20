#!/bin/sh

	# script arguments
CDFINDIR="'../../data/cdd/convert/'"
SYNCINDIR="'../../data/cdd/sync/'"
PLOTDIR="'../../data/cdd/debug-sync/'"
NTRIALS=20
SEED=1

	# spread workload
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 0:4, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 5:9, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 10:14, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 15:19, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 20:24, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 25:29, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 30:34, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 35:39, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, 40, $NTRIALS, $SEED ); exit();" &

	# DEBUG
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, [4, 7], $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, [8, 9], $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $PLOTDIR, [16, 33], $NTRIALS, $SEED ); exit();" &

wait

