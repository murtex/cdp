% classify labels

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/classify.log' ); % start logging

	% prepare directories
indir1 = '../data/klein/cdf/features/';
indir2 = '../data/klein/cdf/train/';

	% read classification data
ids = [16, 17];

runs(1, numel( ids )) = cdf.hRun(); % pre-allocation

logger.progress( 'read cdfs ''%s''...', indir1 );
ic = 0;
for id = ids

		% read data
	infile = fullfile( indir1, sprintf( '%d.mat', id ) );
	if exist( infile, 'file' ) ~= 2 % skip non-existent data
		ic = ic + 1;
		logger.progress( ic, numel( ids ) );
		continue;
	end

	load( infile, 'run' );
	runs(ic+1) = run;

	ic = ic + 1;
	logger.progress( ic, numel( ids ) );
end

	% read classifier and classify data
infile = fullfile( indir2, 'classes.mat' );
logger.log( 'read classes ''%s''...', infile );
load( infile, 'classes' );

infile = fullfile( indir2, 'forest.mat' );
logger.log( 'read forest ''%s''...', infile );
load( infile, 'forest' );

cdf.classify( runs, classes, forest, false );

	% clean-up
delete( runs );
delete( forest );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

