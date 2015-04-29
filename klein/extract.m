% extract responses

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( 'extract.log' ); % start logging

	% prepare directories
indir = 'cdf/sync/';

outdir = 'cdf/extract/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

plotdir = 'plot/extract/';
if exist( plotdir, 'dir' ) ~= 7
	mkdir( plotdir );
end

	% prepare extraction range statistics
global_detected = [];
global_labeled = [];

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% proceed subjects
ids = 6:47; % some syncs are malicious

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

		% extract responses
	cdf.extract( run, cfg );
	
		% plot extraction statistics
	trials = [run.trials.detected];
	detected = cat( 1, trials.range );
	trials = [run.trials.labeled];
	labeled = cat( 1, trials.range );
	cdf.plot.extract( run, detected, labeled, fullfile( plotdir, sprintf( '%d_extract', run.id ) ) );

	global_detected = cat( 1, global_detected, detected );
	global_labeled = cat( 1, global_labeled, labeled );
	cdf.plot.extract( run, global_detected, global_labeled, fullfile( plotdir, 'global_extract' ) );

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

