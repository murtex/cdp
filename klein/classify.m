% classify labels

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/classify.log' ); % start logging

	% read classifier
indir = '../data/klein/cdf/train/';

infile = fullfile( indir, 'classes.mat' );
logger.log( 'read classes ''%s''...', infile );
load( infile, 'classes' );

infile = fullfile( indir, 'forest.mat' );
logger.log( 'read forest ''%s''...', infile );
load( infile, 'forest' );

	% convert forest for mex-file usage
logger.tab( 'convert forest...' );

wstate = warning( 'query', 'all' );
warning( 'off', 'all' );
mexforest = forest.mexify(); % conversion
warning( wstate );

logger.untab();

	% prepare directories
indir = '../data/klein/cdf/features/';

outdir = '../data/klein/cdf/classify/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

	% prepare global classification accuracy
global_hits = 0;
global_misses = 0;

	% proceed subjects
ids = [22, 37];

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
	cdf.classify( run, classes, mexforest );

		% log classification accuracy
	n = numel( run.trials );

	hits = 0;
	misses = 0;

	for j = 1:n
		if ~isempty( run.trials(j).labeled.label )
			if strcmp( run.trials(j).detected.label, run.trials(j).labeled.label )
				hits = hits + 1;
			else
				misses = misses + 1;
			end
		end
	end

	global_hits = global_hits + hits;
	global_misses = global_misses + misses;

	logger.log( 'accuracy: %.2f%%', hits / (hits + misses) * 100 );

		% write data
	outfile = fullfile( outdir, sprintf( '%d.mat', run.id ) );
	logger.log( 'write cdf ''%s''...', outfile );
	save( outfile, 'run' );

		% clean-up
	delete( run );

	logger.untab();
end

logger.log( 'accuracy: %.2f%%', global_hits / (global_hits + global_misses) * 100 );

	% clean-up
delete( forest );

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

