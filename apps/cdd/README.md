Raw data
--------

- `proc.read_audio` -- read raw audio data
- `proc.read_trials` -- read raw trial data

Preprocessing
-------------

- `proc.convert` -- raw conversion
- `test.convert` -- raw conversion statistics

<!-- -->

- `proc.sync` -- marker synchronization
- `test.sync` -- marker synchronization statistics
- `test.sync_samples` -- marker synchronization samples

Manual labeling
---------------

- `proc.label` -- labeling tool

Auditing
--------

- `test.audit` -- auditing tool

Example
-------

```matlab

	% preprocessing
proc.convert( '../../data/cdd/raw/', '../../data/cdd/convert/', 1, 'convert.log' );
proc.sync( '../../data/cdd/convert/', '../../data/cdd/sync/', 1, 'sync.log' );

	% manual labeling
copyfile( '../../data/cdd/sync/', '../../data/cdd/label/' );

proc.label( '../../data/cdd/label/', '../../data/cdd/label/', 1, 'activity', 'label.log' );
proc.label( '../../data/cdd/label/', '../../data/cdd/label/', 1, 'landmarks', 'label.log' );
proc.label( '../../data/cdd/label/', '../../data/cdd/label/', 1, 'formants', 'label.log' );

```

Server batch processing
-----------------------

- `proc_convert.sh` -- raw conversion
- `test_convert.sh` -- raw conversion statistics

<!-- -->

- `proc_sync.sh` -- marker synchronization
- `test_sync.sh` -- marker synchronization statistics

