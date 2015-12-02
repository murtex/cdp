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

