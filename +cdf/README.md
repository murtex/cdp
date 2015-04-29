Cue-distractor framework
========================

Data structures
---------------

- `hRun`: experimental run/recording
- `hTrial`: experimental trial
- `hConfig`: framework configuration

Functions
---------

in order of execution

1. `sync`: sync timings
2. `extract`: extract responses
3. `landmark`: detect landmarks

Plots
-----

- `plot.sync`: sync marker offsets
- `plot.trial_range`: trial overview
- `plot.extract`: extraction accuracies
- `plot.trial_extract`: extraction internals
- `plot.landmark`: landmark detection accuracies
- `plot.trial_glottis`: glottis detection internals
- `plot.trial_burst`: burst detection internals
- `plot.timing`: timings

