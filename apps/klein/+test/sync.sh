#!/bin/sh

	# script arguments
CDFINDIR="'../../data/klein-dev/convert/'"
SYNCINDIR="'../../data/klein-dev/sync/'"
OUTDIR="'../../data/klein-dev/debug-sync/'"

NTRIALS=20
SEED=1

	# reset output directory
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 1:5, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 6:10, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 11:15, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 16:20, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 21:25, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 26:30, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 31:35, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 36:40, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 41:45, $NTRIALS, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, 46:47, $NTRIALS, $SEED ); exit();" &

	# DEBUG
#IDS=5
#matlab -nosplash -nodesktop -r "debug_sync( $CDFINDIR, $SYNCINDIR, $OUTDIR, $IDS, $NTRIALS, $SEED ); exit();" &

wait

