Raw data
--------

- `proc.read_audio` -- read raw audio data
- `proc.read_trials` -- read raw trial data
- `proc.read_labels` -- read raw label data

Preprocessing
-------------

- `proc.convert` -- raw conversion
- `test.convert` -- raw conversion statistics

<!-- -->

- `proc.sync` -- marker synchronization
- `test.sync` -- marker synchronization statistics
- `test.sync_samples` -- marker synchronization samples

Label detection
---------------

`proc.activity` -- activity detection
`proc.landmarks` -- landmarks detection
`proc.formants` -- formants detection

Auditing
--------

- `test.audit` -- auditing tool

Example
-------

```matlab

	% preprocessing
proc.convert( '../../data/klein/raw/', '../../data/klein/convert/', 1, 'convert.log' );
proc.sync( '../../data/klein/convert/', '../../data/klein/sync/', 1, 'sync.log' );

	% label detection
proc.activity( '../../data/klein/sync/', '../../data/klein/activity/', 1, 'activity.log' );
proc.landmarks( '../../data/klein/sync/', '../../data/klein/landmarks/', 1, 'landmarks.log' );
proc.formants( '../../data/klein/sync/', '../../data/klein/formants/', 1, 'formants.log' );

```

