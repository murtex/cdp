#!/bin/sh

	# landmark detection
./convert.sh
./sync.sh
./extract.sh
./landmark.sh
./debug.sh

	# label classification

