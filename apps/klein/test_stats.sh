#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/convert/proc/"
OUTDIR="../../data/klein-dev/convert/test/"

IDS="10:10"

	# workload
matlab -nosplash -nodesktop -r "test.stats( '$INDIR', '$OUTDIR', $IDS ); exit();" &

wait

