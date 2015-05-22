#!/bin/sh

	# data directories
INDIR='../../data/klein/extract/'
OUTDIR='../../data/klein/landmark/'

	# spread workload
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 1:10 ); exit();" &
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 11:20 ); exit();" &
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 21:30 ); exit();" &
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 31:40 ); exit();" &
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 41:47 ); exit();" &

wait

