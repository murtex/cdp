function debug( indir, outdir, ids, seed, ntrials )
% plot debuggings
%
% DEBUG( indir, outdir, ids, seed, ntrials )
%
% INPUT
% indir : input directory (row char)
% outdir : plot directory (row char)
% ids : subject identifiers (row numeric)
% seed : randomization seed (scalar numeric)
% ntrials : number of trials (scalar numeric)

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

	if nargin < 5 || ~isscalar( ntrials ) || ~isnumeric( ntrials )
		error( 'invalid argument: ntrials' );
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
		if exist( plotdir, 'dir' ) == 7
			rmdir( plotdir, 's' );
		end
		mkdir( plotdir );

			% sample random trials
		rs = rng(); % push randomness
		rng( seed, 'twister' );

		trialids = 1:numel( run.trials );
		invalids = [];

		for j = trialids % skip invalids
			trial = run.trials(j);
			resp_det = run.resps_det(j);
			resp_lab = run.resps_lab(j);

			if any( isnan( trial.range ) ) || any( isnan( resp_det.range ) ) || any( isnan( resp_lab.range ) )
				invalids(end+1) = j;
			end
		end

		trialids(invalids) = [];

		if numel( trialids ) > ntrials && numel( trialids ) > 1 % sample trials
			trialids = randsample( trialids, ntrials );
		end

		rng( rs ); % pop randomness

			% plot trials
		for j = trialids
			cdf.plot.trial( run, cfg, j, fullfile( plotdir, sprintf( 'run_%d_trial_%d.png', i, j ) ) );
			%cdf.plot.trial_activity( run, cfg, j, fullfile( plotdir, sprintf( 'run_%d_trial_%d_activity.png', i, j ) ) );
		end

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

