#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/convert/'"
OUTDIR="'../../data/klein-dev/sync/'"

	# prepare directories
rm -rf $OUTDIR

	# spread workload
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 1:5 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 6:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 11:15 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 16:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 21:25 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 26:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 31:35 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 36:40 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 41:45 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, 46:47 ); exit();" &

	# DEBUG
#IDS=5
#matlab -nosplash -nodesktop -r "sync( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

