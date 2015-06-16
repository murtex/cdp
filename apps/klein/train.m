function train( indir, outdir, ids, seed, ntrees, ratio )
% train classifier
%
% TRAIN( indir, outdir, ids, ntrees, ratio )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : randomization seed (scalar numeric)
% ntrees : number of trees (scalar numeric)
% ratio : training ratio (scalar numeric)

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
		error( 'invalid argument: seed' );
	end

	if nargin < 5 || ~isscalar( ntrees ) || ~isnumeric( ntrees )
		error( 'invaid argument: ntrees' );
	end

	if nargin < 6 || ~isscalar( ratio ) || ~isnumeric( ratio )
		error( 'invalid argument: ratio' );
	end

		% include cue-distractor package
	addpath( '../../cdp/' );

		% prepare for output
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	plotdir = fullfile( outdir, 'plot' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( '%d.log', seed ) ) ); % start logging
	logger.tab( 'train classifier...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% read training data
	logger.tab( 'read training data...' );

	runs = cdf.hRun.empty(); % pre-allocation

	for i = ids
		infile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		if exist( infile, 'file' ) ~= 2
			continue; % skip non-existing
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

		runs(end+1) = run;
	end

	logger.untab();

		% train random forest and plot
	[classes, forest, trained] = cdf.train( runs, ntrees, seed, ratio );

	ntrees = numel( forest );
	for i = 1:ntrees
		cdf.plot.train( forest(i), fullfile( plotdir, sprintf( '%d_%d.png', seed, i ) ) );
	end

	cdf.plot.train( forest, fullfile( plotdir, sprintf( 'forest_%d.png', seed ) ) );

		% write classifier
	logger.tab( 'write classifier...' );

	outfile = fullfile( outdir, sprintf( 'classes_%d.mat', seed ) );
	logger.log( 'write classes ''%s''...', outfile );
	save( outfile, 'classes', '-v7' );

	outfile = fullfile( outdir, sprintf( 'forest_%d.mat', seed ) );
	logger.log( 'write forest ''%s''...', outfile );
	save( outfile, 'forest', '-v7' );

	outfile = fullfile( outdir, sprintf( 'trained_%d.mat', seed ) );
	logger.log( 'write identifiers ''%s''...', outfile );
	save( outfile, 'trained', '-v7' );

	logger.untab();

		% cleanup
	delete( runs );

	logger.log( 'peak memory: %.1fGiB', logger.peakmem() / (1024^3) );

	logger.untab( 'done.' ); % stop logging

end

