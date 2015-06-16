#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/train/'

	# spread workload
IDS='setdiff( 1:47, 4 )'
NTREES=1
RATIO=0.8

matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 1, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 2, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 3, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 4, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 5, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 6, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 7, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 8, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 9, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 10, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 11, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 12, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 13, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 14, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 15, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 16, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 17, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 18, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 19, $NTREES, $RATIO ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 20, $NTREES, $RATIO ); exit();" &

wait

