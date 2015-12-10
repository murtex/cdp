Preprocessing
-------------

- `proc.convert` -- raw conversion
- `proc.sync` -- marker synchronization

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

##### Preprocessing

- `proc_convert.sh` -- raw conversion
- `proc_sync.sh` -- marker synchronization

