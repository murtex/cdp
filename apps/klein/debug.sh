#!/bin/sh

	# data directories
INDIR='../../data/klein/classify-lab/'
OUTDIR='../../data/klein/debug-worst/'

	# spread workload
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 1:5 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 6:10 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 11:15 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 16:20 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 21:25 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 26:30 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 31:35 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 36:40 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 41:45 ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', 46:47 ); exit();" &

	# DEBUG
IDS='[]'
matlab -nosplash -nodesktop -r "debug( '$INDIR', '$OUTDIR', $IDS ); exit();" &

wait

