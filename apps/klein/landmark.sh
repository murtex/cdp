#!/bin/sh

	# input directory
INDIR='../../data/klein/sync/'

	# proceed detection versions
for DVER in 15
do

		# output directory
	OUTDIR="../../data/klein/landmark/lm$DVER/"

		# spread workload
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 1:5, 4 ), $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 6:10, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 11:15, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 16:20, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 21:25, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 26:30, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 31:35, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 36:40, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 41:45, $DVER ); exit();" &
	sleep 3
	matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', 46:47, $DVER ); exit();" &

	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 1:5, [4] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 6:10, [7, 8, 9] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 11:15, [12, 15] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 16:20, [16, 19, 20] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 21:25, [22, 23, 25] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 26:30, [] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 31:35, [31, 32, 33, 34] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 36:40, [36, 37] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 41:45, [41, 44, 45] ), $DVER ); exit();" &
	#sleep 3
	#matlab -nosplash -nodesktop -r "landmark( '$INDIR', '$OUTDIR', setdiff( 46:47, [47] ), $DVER ); exit();" &

	wait

		# statistics
	matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', 1:47 ); exit();" &
	#matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', 1:47, {'ta'} ); exit();" &
	#matlab -nosplash -nodesktop -r "sip16( '$OUTDIR', 1:47, {'ka'} ); exit();" &

	wait

done

