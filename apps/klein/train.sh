#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/train/'

	# spread workload
IDS='[3, 6, 8, 10]'
IDS='[16, 17]'
NTREES=1

matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 1, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 2, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 3, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 4, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 5, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 6, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 7, $NTREES ); exit();" &
matlab -nosplash -nodesktop -r "train( '$INDIR', '$OUTDIR', $IDS, 8, $NTREES ); exit();" &

wait

