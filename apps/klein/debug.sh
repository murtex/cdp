#!/bin/sh

	# data directories
INDIR='../../data/klein/classify/'
OUTDIR='../../data/klein/debug-classify/'

	# spread workload
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

