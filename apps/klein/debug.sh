#!/bin/sh

	# data directories
INDIR='../../data/klein/classify/'
OUTDIR='../../data/klein/debug/'

	# spread workload
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

