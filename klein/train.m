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

	% read subjects
ids = [16, 17];

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

	% train classifier
rng(2);
cdf.train( runs, cfg, false );

	% clean-up
delete( runs );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

