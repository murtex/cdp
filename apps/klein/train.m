function train( indir, outdir, ids, seed, ntrees )
% train classifier
%
% TRAIN( indir, outdir, ids, ntrees )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : randomization seed (scalar numeric)
% ntrees : number of trees (scalar numeric)

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

	if nargin < 5 || ~isscalar( ntrees ) || ~isnumeric( ntrees )
		error( 'invaid argument: ntrees' );
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

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'train_%d.log', seed ) ) ); % start logging
	logger.tab( 'train classifier...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% read training data
	logger.tab( 'read training data...' );

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

		% train random forest and plot
	[classes, forest] = cdf.train( runs, ntrees, seed, true );

	ntrees = numel( forest );
	for i = 1:ntrees
		cdf.plot.train( forest(i), fullfile( plotdir, sprintf( '%d_%d.png', seed, i ) ) );
	end

	cdf.plot.train( forest, fullfile( plotdir, sprintf( 'forest_%d.png', seed ) ) );

		% write classifier
	logger.tab( 'write classifier...' );

	outfile = fullfile( outdir, sprintf( 'classes_%d.cdf', seed ) );
	logger.log( 'write classes ''%s''...', outfile );
	save( outfile, 'classes', '-v7' );

	outfile = fullfile( outdir, sprintf( 'forest_%d.cdf', seed ) );
	logger.log( 'write forest ''%s''...', outfile );
	save( outfile, 'forest', '-v7' );

	logger.untab();

		% cleanup
	delete( runs );

	logger.log( 'peak memory: %.1fGiB', logger.peakmem() / (1024^3) );

	logger.untab( 'done.' ); % stop logging

end

