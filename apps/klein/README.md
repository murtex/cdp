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
- `proc.landmarks` -- landmarks detection
- `proc.formants` -- formants detection

##### Classification

- `proc.features` -- feature extraction
- `proc.train` -- training
- `proc.classify` -- classification

Testing
-------

##### Statistics

- `test.convert` -- raw conversion statistics
- `test.sync` -- marker synchronization statistics
- `test.activity` -- voice activity detection statistics
- `test.landmarks` -- landmarks detection statistics
- `test.formants` -- formants detection statistics
- `test.train` -- training statistics
- `test.classify` -- classification statistics

##### Samples

- `test.sync_samples` -- marker synchronization samples
- `test.activity_samples` -- voice activity detection samples
- `test.landmarks_samples` -- landmarks detection samples
- `test.formants_samples` -- formants detection samples
- `test.classify_samples` -- classification samples

Analysis
--------

