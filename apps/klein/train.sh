#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/train/'

	# spread workload
IDS='[3, 6, 8, 10]'
IDS='[16, 17]'
IDS='[1:3, 5:10]'
NTREES=50 # 500 trees total

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

wait

