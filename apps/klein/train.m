% train label classifier

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/train.log' ); % start logging

	% prepare directories
indir = '../data/klein/cdf/features/';

outdir = '../data/klein/cdf/train/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% read training data
ids = [22, 37];

runs = cdf.hRun.empty(); % pre-allocation

logger.progress( 'read cdfs ''%s''...', indir );
ic = 0;
for id = ids

		% read data
	infile = fullfile( indir, sprintf( '%d.mat', id ) );
	if exist( infile, 'file' ) ~= 2 % skip non-existent data
		ic = ic + 1;
		logger.progress( ic, numel( ids ) );
		continue;
	end

	load( infile, 'run' );
	runs(end+1) = run;

	ic = ic + 1;
	logger.progress( ic, numel( ids ) );
end

	% train data and write classifier
[classes, forest] = cdf.train( runs, cfg );

outfile = fullfile( outdir, 'classes.mat' );
logger.log( 'write classes ''%s''...', outfile );
save( outfile, 'classes' );

outfile = fullfile( outdir, 'forest.mat' );
logger.log( 'write forest ''%s''...', outfile );
save( outfile, 'forest' );

	% convert forest for mex-file usage
logger.tab( 'convert forest...' );

wstate = warning( 'query', 'all' );
warning( 'off', 'all' );
mexforest = forest.mexify(); % conversion
warning( wstate );

outfile = fullfile( outdir, 'mexforest.mat' );
logger.log( 'write forest ''%s''...', outfile );
save( outfile, 'mexforest' );

logger.untab();

	% clean-up
delete( runs );
delete( forest );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

