Reference application
=====================

Data import
-----------

- `read_trial` read logfile
- `read_label` read annotation file
- `read_audio` read audio file

Main scripts
------------

- `convert` convert raw data
- `sync` sync timing
- `extract` extract responses
- `landmark` detect landmarks

Debugging scripts
-----------------

- `sync_debug` plot random trials
- `extract_debug` plot random trials
- `landmark_debug` plot random trials

Directory structure
-------------------

- `raw/`: raw data (log, annotation, audio)

- `cdf/`: cdf formatted data
- `cdf/convert/`: after conversion
- `cdf/sync/`: after syncing
- `cdf/extract/`: after extraction
- `cdf/landmark/`: after landmark detection

- `plot/`: plots
- `plot/sync/`: sync plots (marker offsets)
- `plot/extract/`: extraction plots (range statistics)
- `plot/landmark/`: landmark detection plots (landmark statistics)

- `plot/sync_debug/`: sync debugging (random trials)
- `plot/extract_debug/`: extraction debugging (random trials)
- `plot/landmark_debug/`: landmark detection debuggung (random trials)

