% interim script

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/cdd/interim.log' ); % start logging

	% configure framework
cfg = cdf.hConfig(); % use defaults

    % read (raw) data
indir = '../data/cdd/interim/';
plotdir = indir;

logfile = fullfile( indir, 'participant_production.txt' );
audiofile = fullfile( indir, 'participant_production.wav' );
if exist( logfile, 'file' ) ~= 2 || exist( audiofile, 'file' ) ~= 2 % skip partial data
	logger.untab( 'skipping' );
	continue;
end

run = cdf.hRun();

read_audio( run, audiofile, false );
read_trials( run, logfile );

	% sync timings and plot verification
offs = cdf.sync( run, cfg, false );
cdf.plot.sync( run, offs, fullfile( plotdir, 'sync' ) );

	% extract responses
cdf.extract( run, cfg );

	% detect landmarks and plot timings
cdf.landmark( run, cfg );

trials = [run.trials.detected];
detected = cat( 2, [trials.bo]', [trials.vo]', [trials.vr]' );
cdf.plot.timing( run, detected, [], fullfile( plotdir, 'timing' ) );

	% DEBUG: plot all(!) trials and landmarks (uncomment if you need this)
%for i = 1:numel( run.trials )
	%if ~any( isnan( run.trials(i).range ) )
		%cdf.plot.trial_range( run, cfg, run.trials(i), [...
			%min( run.trials(i).detected.range(1), run.trials(i).labeled.range(1) ), ...
			%max( run.trials(i).detected.range(2), run.trials(i).labeled.range(2) )], ...
			%run.trials(i).detected.range(1), ...
			%fullfile( plotdir, sprintf( '%d', run.trials(i).id ) ) );
	%end
%end

	% log vot mean and standard deviation
trials = [run.trials.detected];
vots = dsp.smp2msec( [trials.vo]-[trials.bo], run.audiorate );
vots(isnan( vots )) = [];

logger.log( 'vot mean: %.1fms', mean( vots ) );
logger.log( 'vot std: %.1fms', std( vots, 1 ) );

	% put your own additional code here
...

	% clean-up
delete( run );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

