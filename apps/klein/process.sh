#!/bin/sh

	# landmark detection (~10min)
#./convert.sh
#./sync.sh
#./extract.sh
#./landmark.sh

	# label classification (~25min)
./features.sh
./train.sh
./classify.sh

	# debugging
#./debug.sh

