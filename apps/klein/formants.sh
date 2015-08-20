#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/sync/'"
OUTDIR="'../../data/klein-dev/formants/'"

	# reset output directory
rm -rf $OUTDIR

	# workload
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 1:5 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 6:10 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 11:15 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 16:20 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 21:25 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 26:30 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 31:35 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 36:40 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 41:45 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, 46:47 ); exit();" &

	# DEBUG
IDS=13
matlab -nosplash -nodesktop -r "formants( $INDIR, $OUTDIR, $IDS ); exit();" &

wait

