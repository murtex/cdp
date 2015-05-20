#!/bin/sh

	# safeguard
if [ "$#" -ne 1 ]; then
	echo "usage: $0 SCRIPTFILE" >&2
	exit 1
fi

if ! [ -e "$1" ]; then
	echo "'$1' not found" >&2
	exit 1
fi

	# run matlab script
DIR=`dirname "$1"`
FILE=`basename "$1"`

cd "$DIR"
matlab -nosplash -nodesktop -r "try, run ./$FILE; end, exit();"

