#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/sync/'"
OUTDIR="'../../data/klein-dev/activity/'"

	# spread workload
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 1:5 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 6:10 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 11:15 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 16:20 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 21:25 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 26:30 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 31:35 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 36:40 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 41:45 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, 46:47 ); exit();" &

	# DEBUG
IDS=10
matlab -nosplash -nodesktop -r "activity( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

