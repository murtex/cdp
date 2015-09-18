#!/bin/sh

	# script arguments
INDIR="../../data/klein-dev/convert/proc/"
OUTDIR="../../data/klein-dev/sync/proc/"

IDS1="1:5"
IDS2="6:9"
IDS3="10:15"
IDS4="16:19"
IDS5="20:25"
IDS6="26:29"
IDS7="30:35"
IDS8="36:39"
IDS9="40:45"
IDS10="46:47"

	# reset output directory
rm -rf $OUTDIR

	# workload
matlab -nosplash -nodesktop -r "proc.sync( '$INDIR', '$OUTDIR', $IDS1 ); exit();" &

wait

