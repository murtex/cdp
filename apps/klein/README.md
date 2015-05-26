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

- this application specifically assumes that raw data are stored in the paradigm of [Psychtoolbox](http://psychtoolbox.org/) with well-featured WAV-recordings and dedicated CSV-logfiles
- additionally it depends on hand-labeled annotations in XLSX-format
- [`convert.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/convert.m) reads these raw triads and transforms them into framework's format
- [`sync.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/sync.m) corrects any temporal misalignment between logfiles and recordings

Landmark detection
------------------

- [`extract.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/extract.m) finds parts of speech in audio recording (this stage may take some time)
- [`landmark.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/landmark.m) detects landmarks (Burst+, Glottis+/-) in these selected parts

Label classification
--------------------

- [`features.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/features.m) computes classification features by fixed heuristics (this may take some time too)
- [`train.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/train.m) trains a random forest classifier based upon classification features (this may take a lot of time, and you should run it only if you know what you are doing; in most cases you can skip this stage)
- [`classify.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/classify.m) classifies labels based upon a previously trained classifier

Debugging (TODO: not yet)
---------

- for verification of any mentioned stages you might run [`debug.m`](https://github.com/murtex/cdp/blob/maria/apps/klein/debug.m) directly afterwards
- it will generate additional debugging plots ready for visual assessment

Parallelization
---------------

- all of the above mentioned Matlab scripts come up with (UNIX-style, sorry for Windows users) shell scripts of same name (file extension: `.sh`)
- they might give a hint of how to parallelize data processing (process-based)
- the framework itself will take the advantage of a multi-core system only if you have installed 'Parallel Computing Toolbox' (thread-based)

Extras
------

- TODO: speech-weighted spectrum!

