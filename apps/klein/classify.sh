#!/bin/sh

	# data directories
INDIR='../../data/klein/features-8/'
OUTDIR='../../data/klein/classify-8/'
TRAINDIR='../../data/klein/train-8/'

	# spread workload
IDS='[21:47]'
SEEDS='1:5'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

