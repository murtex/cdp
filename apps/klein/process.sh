#!/bin/sh

	# landmark detection
#./convert.sh
#./sync.sh
#./extract.sh
#./landmark.sh

	# label classification
./features.sh
./train.sh
./classify.sh

	# debugging
#./debug.sh

