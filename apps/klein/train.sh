#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/train/'

	# spread workload
IDS='setdiff( 1:20, 4 )'
#IDS='21:47'
#IDS='[16, 17]'
NTREES=5

matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 1, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 2, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 3, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 4, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 5, $NTREES ); exit();" &

wait

