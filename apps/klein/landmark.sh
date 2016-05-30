#!/bin/sh

	# data directories
INDIR='../../data/klein/sync/'
OUTDIR='../../data/klein/landmark/lm0/'

	# spread workload
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 1:5 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 6:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 11:15 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 16:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 21:25 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 26:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 31:35 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 36:40 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 41:45 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 46:47 ); exit();" &

wait

	# landmark statistics
matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', 1:47 ); exit();"

