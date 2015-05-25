function classify( indir, outdir, ids, traindir, seeds )
% classify labels
%
% CLASSIFY( indir, outdir, ids, traindir, seeds )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% traindir : training directory (row char)
% seeds : training seeds (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir )
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

	if nargin < 4 || ~isrow( traindir ) || ~ischar( traindir )
		error( 'invalid argument: traindir' );
	end

	if nargin < 5 || ~isrow( seeds ) || ~isnumeric( seeds )
		error( 'invalid argument: seeds' );
	end

	addpath( '../../cdp/' ); % include cue-distractor package

		% prepare for output
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'classify_%03d-%03d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'classify labels...' );

		% read classifiers
	logger.tab( 'read classifiers...' );

	global_classes = {}; % pre-allocation
	global_forest = [];

	for i = seeds

			% read classifier
		infile = fullfile( traindir, sprintf( 'classes_%d.cdf', i ) );
		logger.log( 'read classes ''%s''...', infile );
		load( infile, '-mat', 'classes' );

		infile = fullfile( traindir, sprintf( 'forest_%d.cdf', i ) );
		logger.log( 'read forest ''%s''...', infile );
		load( infile, '-mat', 'forest' );

			% accumulate
		global_classes = unique( cat( 2, global_classes, classes ), 'stable' );
		global_forest = cat( 2, global_forest, forest );

	end

	logger.log( 'classes: %d', numel( global_classes ) );
	logger.log( 'trees: %d', numel( global_forest ) );

	logger.untab();

		% proceed subject
	global_hits = 0;
	global_misses = 0;

	for i = ids
		logger.tab( 'subject: %d', i );

			% read cdf data
		infile = fullfile( indir, sprintf( '%03d.cdf', i ) );

		if exist( infile, 'file' ) ~= 2
			logger.untab( 'skipping' ); % skip non-existing
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

			% classify labels
		cdf.classify( run, global_classes, global_forest );

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

			% write cdf data
		run.audiodata = []; % do not write audio data

		outfile = fullfile( outdir, sprintf( '%03d.cdf', run.id ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run', '-v7' );

			% cleanup
		delete( run );

		logger.untab();
	end

	logger.log( 'accuracy: %.2f%%', global_hits / (global_hits + global_misses) * 100 );


		% cleanup
	logger.untab( 'done.' ); % stop logging

end

