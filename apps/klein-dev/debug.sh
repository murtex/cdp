#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/sync/'"
OUTDIR="'../../data/klein-dev/debug/'"
SEED="1"

	# spread workload
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 1:5, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 6:10, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 11:15, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 16:20, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 21:25, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 26:30, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 31:35, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 36:40, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 41:45, $SEED ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( $INDIR, $OUTDIR, 46:47, $SEED ); exit();" &

wait

