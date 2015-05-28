#!/bin/sh

	# data directories
INDIR='../../data/klein/features-8/'
OUTDIR='../../data/klein/train-8/'

	# spread workload
IDS='1:20'
NTREES=4

matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 1, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 2, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 3, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 4, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 5, $NTREES ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 6, $NTREES ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 7, $NTREES ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 8, $NTREES ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 9, $NTREES ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 10, $NTREES ); exit();" &

wait

