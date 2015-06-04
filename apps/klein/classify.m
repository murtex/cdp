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

	plotdir = fullfile( outdir, 'plot' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'classify_%03d-%03d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'classify labels...' );

		% read forests and plot
	logger.tab( 'read classifier...' );

	global_classes = {}; % pre-allocation
	global_forest = [];

	for i = seeds

			% read forest
		infile = fullfile( traindir, sprintf( 'classes_%d.cdf', i ) );
		logger.log( 'read classes ''%s''...', infile );
		load( infile, '-mat', 'classes' );

		infile = fullfile( traindir, sprintf( 'forest_%d.cdf', i ) );
		logger.log( 'read forest ''%s''...', infile );
		load( infile, '-mat', 'forest' );

			% accumulate forests
		global_classes = unique( cat( 2, global_classes, classes ), 'stable' );
		global_forest = cat( 2, global_forest, forest );

	end

	nclasses = numel( global_classes );
	ntrees = numel( global_forest );

	logger.tab( 'classes: %d', nclasses );
	for i = 1:nclasses
		logger.log( 'class #%d: ''%s''', i, global_classes{i} );
	end
	logger.untab();
	logger.log( 'trees: %d', ntrees );

	cdf.plot.train( global_forest, fullfile( plotdir, 'forest.png' ) );

	logger.untab();

		% proceed subjects
	function cid = classid( label ) % label to class conversion
		cid = find( strcmp( label, global_classes ) );
	end

	global_hits = zeros( ntrees, nclasses ); % pre-allocation
	global_misses = zeros( ntrees, nclasses );

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

			% classify labels and log/plot
		cumlabels = cdf.classify( run, global_classes, global_forest, false );

		hits = zeros( ntrees, nclasses ); % pre-allocation
		misses = zeros( ntrees, nclasses );

		n = numel( run.trials );
		for j = 1:n
			cid = classid( run.trials(j).labeled.label );
			if ~isempty( cid )
				for k = 1:ntrees
					if cumlabels(k, j) == cid
						hits(k, cid) = hits(k, cid) + 1;
					else
						misses(k, cid) = misses(k, cid) + 1;
					end
				end
			end
		end

		global_hits = global_hits + hits;
		global_misses = global_misses + misses;

		logger.tab( 'error: %.2f%%', sum( misses(ntrees, :) ) / sum( hits(ntrees, :) + misses(ntrees, :) ) * 100 );
		for j = 1:nclasses
			logger.log( 'class #%d: %.2f%%', j, misses(ntrees, j) / (hits(ntrees, j) + misses(ntrees, j)) * 100 );
		end
		logger.untab();

		cdf.plot.classify( hits, misses, fullfile( plotdir, sprintf( '%d.png', run.id ) ) );

			% write cdf data
		run.audiodata = []; % do not write audio data

		outfile = fullfile( outdir, sprintf( '%03d.cdf', run.id ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run', '-v7' );

			% cleanup
		delete( run );

		logger.untab();
	end

	logger.tab( 'error: %.2f%%', sum( global_misses(ntrees, :) ) / sum( global_hits(ntrees, :) + global_misses(ntrees, :) ) * 100 );
	for j = 1:nclasses
		logger.log( 'class #%d: %.2f%%', j, global_misses(ntrees, j) / (global_hits(ntrees, j) + global_misses(ntrees, j)) * 100 );
	end
	logger.untab();

	cdf.plot.classify( global_hits, global_misses, fullfile( plotdir, 'global.png' ) );

		% cleanup
	logger.log( 'peak memory: %.1fGiB', logger.peakmem() / (1024^3) );

	logger.untab( 'done.' ); % stop logging

end

