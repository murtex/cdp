#!/bin/sh

	# script arguments
CDFINDIR="'../../data/cdd/convert/'"
SYNCINDIR="'../../data/cdd/sync/'"
OUTDIR="'../../data/cdd/debug-sync/'"

NTRIALS=20
SEED=1

	# reset output directory
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 0:4, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 5:9, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 10:14, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 15:19, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 20:24, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 25:29, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 30:34, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 35:39, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 40, $NTRIALS, $SEED ); exit();" &

	# DEBUG
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, [4, 7], $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, [8, 9], $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, [16, 33], $NTRIALS, $SEED ); exit();" &

wait

