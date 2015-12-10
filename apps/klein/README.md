Preprocessing
-------------

- `proc.convert` -- raw conversion
- `proc.sync` -- marker synchronization

Manual (re-)labeling
---------------

- `proc.label` -- labeling tool

Auditing
--------

- `test.audit` -- auditing tool

Example
-------

```matlab

	% preprocessing
proc.convert( '../../data/klein/raw/', '../../data/klein/convert/', 1, 'convert.log' );
proc.sync( '../../data/klein/convert/', '../../data/klein/sync/', 1, 'sync.log' );

```

Server batch processing
-----------------------

##### Preprocessing

- `proc_convert.sh` -- raw conversion
- `proc_sync.sh` -- marker synchronization

