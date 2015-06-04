#!/bin/sh

	# data directories
INDIR='../../data/klein/test-features/'
OUTDIR='../../data/klein/test-classify/'
TRAINDIR='../../data/klein/test-train/'

	# spread workload
IDS='[9, 10]'
SEEDS='1:5'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

