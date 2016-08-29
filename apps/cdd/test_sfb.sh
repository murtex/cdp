#!/bin/sh

	# arguments
INDIR="../../data/cdd/sfb/"
OUTDIR="${INDIR}/test/all/"

IDS="[31:40]"

	# workload
MATLAB="matlab -nosplash -nodesktop -r"

#$MATLAB "test.sfb( '$INDIR', '$OUTDIR', $IDS, 'ka', 'ka', '01.log' ); exit();" &
#$MATLAB "test.sfb( '$INDIR', '$OUTDIR', $IDS, 'ta', 'ta', '02.log' ); exit();" &
#$MATLAB "test.sfb( '$INDIR', '$OUTDIR', $IDS, '*', 'ka', '03.log' ); exit();" &
#$MATLAB "test.sfb( '$INDIR', '$OUTDIR', $IDS, '*', 'ta', '04.log' ); exit();" &
$MATLAB "test.sfb( '$INDIR', '$OUTDIR', $IDS, '*', '*', '05.log' ); exit();" &

wait

