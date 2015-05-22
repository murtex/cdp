#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/classify/'
TRAINDIR='../../data/klein/train/'

	# spread workload
IDS='[16, 17]'
SEEDS='1:8'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

