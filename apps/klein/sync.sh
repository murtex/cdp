#!/bin/sh

	# data directories
INDIR='../../data/klein/convert/'
OUTDIR='../../data/klein/sync/'

	# spread workload
matlab -nosplash -nodesktop -r "sync( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "sync( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

