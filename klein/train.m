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
ids = [16, 17];

runs(1, numel( ids )) = cdf.hRun(); % pre-allocation

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
	runs(ic+1) = run;

	ic = ic + 1;
	logger.progress( ic, numel( ids ) );
end

	% train data and write classifier
rng(2); % DEBUG
forest = cdf.train( runs, cfg, false );

outfile = fullfile( outdir, 'forest.mat' );
logger.log( 'write classifier ''%s''...', outfile );
save( outfile, 'forest' );

	% clean-up
delete( runs );
delete( forest );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

