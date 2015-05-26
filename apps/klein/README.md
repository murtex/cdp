Klein's thesis-data application
===============================

- this application is *the* showcase of how to use the entire framework
- but please take this only as a suggestion, there are many other ways of getting your data processed by the framework
- the application is designed as a staggered process which components needs to be run in order
  1. import data
  2. detect landmarks
  3. classify labels
- each of these stages may contain several scripts which also have to be ran in order
- every script below follows the same concept: read input data -- process these data -- write output data; so data are sequentially passed from stage to stage

Import data
-----------

- this application assumes that raw data are stored in the paradigm of [Psychtoolbox](http://psychtoolbox.org/) with well-featured WAV-recordings and dedicated CSV-logfiles
- additionally it depends on hand-labeled annotations in XLSX-format
- [`convert.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/convert.m) reads these raw triads and transforms them into framework's format
- [`sync.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/sync.m) corrects any temporal misalignment between logfiles and recordings

Landmark detection
------------------

Label classification
--------------------

Debugging
---------

Parallelization
---------------

Extras
------

