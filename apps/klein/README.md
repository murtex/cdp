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
proc.convert( '../../data/cdd/raw/', '../../data/cdd/convert/', 1, 'convert.log' );
proc.sync( '../../data/cdd/convert/', '../../data/cdd/sync/', 1, 'sync.log' );

```

Server batch processing
-----------------------

- `proc_convert.sh` -- raw conversion
- `test_convert.sh` -- raw conversion statistics

<!-- -->

- `proc_sync.sh` -- marker synchronization
- `test_sync.sh` -- marker synchronization statistics

