#!/bin/sh

	# data directories
INDIR='../../data/klein/test-features/'
OUTDIR='../../data/klein/test-train/'

	# spread workload
IDS='setdiff( 1:47, 4 )'
NTREES=50

matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 1, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 2, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 3, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 4, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 5, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 6, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 7, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 8, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 9, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 10, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 11, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 12, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 13, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 14, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 15, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 16, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 17, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 18, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 19, $NTREES ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 20, $NTREES ); exit();" &

wait

