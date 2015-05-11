Upcoming cue-distractor experiment
==================================

`interim` script
----------------

- @Eugen
	- please prefix the logfile header line with a comment character `#`
	- when you have included output of SOA in your scripts, please remove line 55 in script `read_trials.m`
- @Stephen
	- just download the zip file and extract to your desktop (or wherever you want)
	- change to that directory in MATLAB and start the single script `interim`
	- raw recordings (for all individual subjects) you can store wherever you want them to be
	- files of the current subject needs to be called `participant_production.txt` and `participant_production.wav` and put into directory `data/cdd/interim/`
	- after script execution you will find there two plots `sync.png` and `timing.png`
	- the first one should be used as progress verification, in the title you can see how many sync markers have been found by the detection routines
	- if this ratio is too low, the VOT distribution in the second plot is probably not meaningful

