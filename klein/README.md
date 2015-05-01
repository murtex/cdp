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
- `babbling` speech-weighted noise

Debugging scripts
-----------------

- `sync_debug` plot random trials
- `extract_debug` plot random trials
- `landmark_debug` plot random trials

Data directory structure
------------------------

- `raw/`: raw data (log, annotation, audio)

- `cdf/`: cdf formatted data
- `cdf/convert/`: after conversion pass
- `cdf/sync/`: after sync pass
- `cdf/extract/`: after extraction pass
- `cdf/landmark/`: after landmark detection pass
- `cdf/babbling/`: speech-weighted noise

- `plot/`: plots
- `plot/sync/`: sync plots (marker offsets)
- `plot/extract/`: extraction plots (range statistics)
- `plot/landmark/`: landmark detection plots (landmark statistics)
- `plot/babbling/`: babbling spectra

- `plot/sync_debug/`: sync debugging (random trials)
- `plot/extract_debug/`: extraction debugging (random trials)
- `plot/landmark_debug/`: landmark detection debuggung (random trials)

