#!/bin/sh

	# data directories
INDIR='../../data/klein/landmark/'
OUTDIR='../../data/klein/test-features/'

	# spread workload
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', [1, 2] ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', [3, 4] ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', [5, 6] ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', [7, 8] ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', [9, 10] ); exit();" &

wait

