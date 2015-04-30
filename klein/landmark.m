% detect landmarks

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/landmark.log' ); % start logging

	% prepare directories
indir = '../data/klein/cdf/extract/';

outdir = '../data/klein/cdf/landmark/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

plotdir = '../data/klein/plot/landmark/';
if exist( plotdir, 'dir' ) ~= 7
	mkdir( plotdir );
end

	% prepare landmark statistics
global_detected = [];
global_labeled = [];

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% proceed subjects
ids = 1:47;

for id = ids
	logger.tab( 'subject: %d', id );

		% read data
	infile = fullfile( indir, sprintf( '%d.mat', id ) );
	if exist( infile, 'file' ) ~= 2 % skip non-existent data
		logger.untab( 'skipping' );
		continue;
	end

	logger.log( 'read cdf ''%s''...', infile );
	load( infile, 'run' );

	read_audio( run, run.audiofile, false );

		% detect landmarks
	cdf.landmark( run, cfg );

		% plot landmark statistics
	trials = [run.trials.detected];
	detected = cat( 2, [trials.bo]', [trials.vo]', [trials.vr]' );
	trials = [run.trials.labeled];
	labeled = cat( 2, [trials.bo]', [trials.vo]', [trials.vr]' );
	cdf.plot.landmark( run, detected, labeled, fullfile( plotdir, sprintf( '%d_landmark', run.id ) ) );
	cdf.plot.timing( run, detected, labeled, fullfile( plotdir, sprintf( '%d_timing', run.id ) ) );

	global_detected = cat( 1, global_detected, detected );
	global_labeled = cat( 1, global_labeled, labeled );
	cdf.plot.landmark( run, global_detected, global_labeled, fullfile( plotdir, 'global_landmark' ) );
	cdf.plot.timing( run, global_detected, global_labeled, fullfile( plotdir, 'global_timing' ) );

		% write data
	run.audiodata = []; % do not write audio data

	outfile = fullfile( outdir, sprintf( '%d.mat', run.id ) );
	logger.log( 'write cdf ''%s''...', outfile );
	save( outfile, 'run' );

		% clean-up
	delete( run );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

