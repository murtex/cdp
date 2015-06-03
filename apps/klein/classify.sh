#!/bin/sh

	# data directories
INDIR='../../data/klein/features/'
OUTDIR='../../data/klein/classify/'
TRAINDIR='../../data/klein/train/'

	# spread workload
IDS='21:47'
#IDS='setdiff( 1:20, 4 )'
#IDS='[16, 17]'
#IDS='setdiff( 1:47, [4, 16, 17] )'
SEEDS='1:5'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

