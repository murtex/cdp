#!/bin/sh

	# data directories
INDIR='../../data/klein/sync/'
OUTDIR='../../data/klein/landmark/lm4/'

#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', [3, 5, 6, 7, 8, 9, 10] ); exit();"
#matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', [3, 5, 6, 7, 8, 9, 10] ); exit();"

	# spread workload
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 1:5, 4 ) ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 6:10 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 11:15 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 16:20 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 21:25, [23, 25] ) ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 26:30 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 31:35 ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 36:40, [36, 37] ) ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 41:45, 44 ) ); exit();" &
sleep 3
matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 46:47, 47 ) ); exit();" &

wait

	# landmark statistics
matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', setdiff( 1:47, 4 ) ); exit();"

