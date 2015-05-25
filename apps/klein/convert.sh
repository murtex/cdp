#!/bin/sh

	# data directories
INDIR='../../data/klein/raw/'
OUTDIR='../../data/klein/convert/'

	# spread workload
matlab -nosplash -nodesktop -r "convert( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "convert( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "convert( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "convert( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "convert( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

