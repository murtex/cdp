#!/bin/sh

	# script arguments
INDIR="'../../data/klein-dev/label/'"
OUTDIR="'../../data/klein-dev/debug-formant/'"
NTRIALS=20
SEED=1

	# spread workload
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 1:5, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 6:10, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 11:15, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 16:20, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 21:25, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 26:30, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 31:35, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 36:40, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 41:45, $NTRIALS, $SEED ); exit();" &
#sleep 3
#matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, 46:47, $NTRIALS, $SEED ); exit();" &

	# DEBUG
IDS="[13, 42, 46]"
matlab -nosplash -nodesktop -r "debug_formant( $INDIR, $OUTDIR, $IDS, $NTRIALS, $SEED ); exit();" &

wait
