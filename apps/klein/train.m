function train( indir, outdir, ids, seed )
% train classifier
%
% TRAIN( indir, outdir, ids )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : randomization seed (scalar numeric)

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

	if nargin < 4 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: ids' );
	end

	addpath( '../../cdp/' ); % include cue-distractor package

		% prepare for output
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'train_%d.log', seed ) ) ); % start logging
	logger.tab( 'train classifier...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% read data
	logger.tab( 'read cdf...' );

	runs = cdf.hRun.empty(); % pre-allocation

	for i = ids

		infile = fullfile( indir, sprintf( '%03d.cdf', i ) );

		if exist( infile, 'file' ) ~= 2
			continue; % skip non-existing
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

		runs(end+1) = run;

	end

	logger.untab();

		% train classifier
	rng( seed );

	[classes, forest] = cdf.train( runs, cfg );

		% mexify classifier
	logger.log( 'mexify classifier...' );

	ws = warning( 'query' ); % suppress conversion warning
	warning( 'off' );

	mexforest = forest.mexify();

	warning( ws );

		% write classifier
	logger.tab( 'write cdf...' );

	outfile = fullfile( outdir, sprintf( 'classes_%d.cdf', seed ) );
	logger.log( 'write classes ''%s''...', outfile );
	save( outfile, 'classes', '-v7' );

	outfile = fullfile( outdir, sprintf( 'forest_%d.cdf', seed ) );
	logger.log( 'write forest ''%s''...', outfile );
	save( outfile, 'forest', '-v7' );

	outfile = fullfile( outdir, sprintf( 'mexforest_%d.cdf', seed ) );
	logger.log( 'write mexified forest ''%s''...', outfile );
	save( outfile, 'mexforest', '-v7' );

	logger.untab();

		% cleanup
	delete( forest );
	delete( runs );

	logger.untab( 'done.' ); % stop logging

end

