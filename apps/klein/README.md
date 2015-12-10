Preprocessing
-------------

- `proc.convert` -- raw conversion
- `test.convert` -- raw conversion statistics

<!-- -->

- `proc.sync` -- marker synchronization
- `test.sync` -- marker synchronization statistics
- `test.sync_samples` -- marker synchronization samples

Manual (re-)labeling
---------------

- `proc.label` -- labeling tool

Label detection
---------------

- **TODO!**

Auditing
--------

- `test.audit` -- auditing tool

Example
-------

```matlab

	% preprocessing
proc.convert( '../../data/klein/raw/', '../../data/klein/convert/', 1, 'convert.log' );
proc.sync( '../../data/klein/convert/', '../../data/klein/sync/', 1, 'sync.log' );

	% TODO...

```

Server batch processing
-----------------------

##### Preprocessing and detection

- `proc_convert.sh` -- raw conversion
- `proc_sync.sh` -- marker synchronization

<!-- -->

- **TODO!**

##### Statistics

- `test_convert.sh` -- raw conversion statistics
- `test_sync.sh` -- marker synchronization statistics

<!-- -->

- **TODO!**

