% classify labels

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/eyetrack/classify.log' ); % start logging

	% read classifier
indir = '../data/klein/cdf/train/';

infile = fullfile( indir, 'classes.mat' );
logger.log( 'read classes ''%s''...', infile );
load( infile, 'classes' );

infile = fullfile( indir, 'forest.mat' );
logger.log( 'read forest ''%s''...', infile );
load( infile, 'forest' );

	% proceed experiments
for i = 1:2
	logger.tab( 'experiment: %d', i );

		% prepare directories
	indir = sprintf( '../data/eyetrack/%d/cdf/features', i );

		% proceed subjects
	ids = 16;

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

			% classify labels
		cdf.classify( run, classes, forest, false );

			% clean-up
		delete( run );

		logger.untab();
	end

	logger.untab();
end

	% clean-up
delete( forest );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

