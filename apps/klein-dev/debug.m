function debug( indir, outdir, ids, seed )
% plot debuggings
%
% DEBUG( indir, outdir, ids, seed )
%
% INPUT
% indir : input directory (row char)
% outdir : plot directory (row char)
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
		error( 'invalid argument: seed' );
	end

		% prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'debug_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'plot debuggings...' );

	cfg = cdf.hConfig(); % use defaults

		% proceed subject identifiers
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		if exist( cdffile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		read_audio( run, run.audiofile, true );

			% prepare plot directory
		plotdir = fullfile( outdir, sprintf( 'run_%d_plot', i ) );
		if exist( plotdir, 'dir' ) ~= 7
			mkdir( plotdir );
		end

			% plot random trials
		nsrctrials = numel( run.trials );
		ndsttrials = 20; % number of random trials

		rs = rng(); % push randomness
		rng( seed, 'twister' );

		trialids = 1:nsrctrials; % sample trials
		if nsrctrials > 1
			trialids = sort( randsample( trialids, min( nsrctrials, ndsttrials ) ) );
		end

		for j = trialids % plot trials
			cdf.plot.trial( run, cfg, j, fullfile( plotdir, sprintf( 'run_%d_trial_%d.png', i, j ) ) );
		end

		rng( rs ); % pop randomness

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

