Preprocessing
-------------

- `proc.convert` -- raw conversion
- `proc.sync` -- marker synchronization

Manual (re-)labeling
---------------

- `proc.label` -- labeling tool

Automatic detection
-------------------

- `proc.activity` -- activity detection

Auditing
--------

- `test.audit` -- auditing tool

Example
-------

```matlab

	% preprocessing
proc.convert( '../../data/klein/raw/', '../../data/klein/convert/', 3, 'convert.log' );
proc.sync( '../../data/klein/convert/', '../../data/klein/sync/', 3, 'sync.log' );

	% automatic detection
proc.activity( '../../data/klein/sync/', '../../data/klein/activity/', 3, 'activity.log' );

```

Server batch processing
-----------------------

##### Preprocessing

- `proc_convert.sh` -- raw conversion
- `proc_sync.sh` -- marker synchronization

##### Automatic detection

- `proc_activity.sh` -- activity detection

