#!/bin/sh

	# data directories
INDIR='../../data/klein/features-8/'
OUTDIR='../../data/klein/classify-8/'
TRAINDIR='../../data/klein/train-8/'

	# spread workload
IDS='11:20'
SEEDS='1:10'
SEEDS='1'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

