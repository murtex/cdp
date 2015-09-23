Raw data
--------

- stimuli (via [psychtoolbox](http://psychtoolbox.org/))
- responses (audio recordings)
- labels (manually measured)

Processing
----------

##### Preprocessing

- `proc.convert` -- raw conversion
- `proc.sync` -- marker synchronization

##### Detection

- `proc.activity` -- voice activity detection
- `proc.landmarks` -- landmark detection
- `proc.formants` -- formant detection

##### Classification

- `proc.features` -- feature extraction
- `proc.train` -- training
- `proc.classify` -- classification

Testing
-------

##### Statistics

- `test.convert` -- conversion stats
- `test.sync` -- synchronization stats
- `test.activity` -- activity stats
- `test.landmarks` -- landmark stats
- `test.formants` -- formant stats
- `test.train` -- training stats
- `test.classify` -- classification stats

##### Samples

- `test.sync_samples` -- synchronization samples
- `test.activity_samples` -- activity samples
- `test.landmarks_samples` -- landmark samples
- `test.formants_samples` -- formant samples
- `test.classify_samples` -- classification samples

Analysis
--------

