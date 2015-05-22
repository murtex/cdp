#!/bin/sh

	# data directories
INDIR='../../data/klein/landmark/'
OUTDIR='../../data/klein/features/'

	# spread workload
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
matlab -nosplash -nodesktop -r "features( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

