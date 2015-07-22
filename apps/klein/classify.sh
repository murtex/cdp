#!/bin/sh

	# data directories
INDIR='../../data/klein/features-lo/'
OUTDIR='../../data/klein/classify-det-lo/'
TRAINDIR='../../data/klein/train-lo/'

	# spread workload
IDS='setdiff( 1:47, 4 )'
SEEDS='1:20'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS ); exit();" &

wait

