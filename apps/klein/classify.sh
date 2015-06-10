#!/bin/sh

	# data directories
INDIR='../../data/klein/test-features/'
OUTDIR='../../data/klein/test-classify/'
TRAINDIR='../../data/klein/test-train/'

	# spread workload
IDS='setdiff( 1:47, 4 )'
SEEDS='1:20'

matlab -nosplash -nodesktop -r "classify( '$INDIR', '$OUTDIR', $IDS, '$TRAINDIR', $SEEDS); exit();" &

wait

