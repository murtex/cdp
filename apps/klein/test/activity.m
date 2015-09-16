function debug_activity( indir, outdir, ids, ntrials, seed )
% debug activity detection
% 
% DEBUG_ACTIVITY( indir, outdir, ids, ntrials, seed )
%
% INPUT
% indir : input directory (row char)
% outdir : plot directory (row char)
% ids : subject identifiers (row numeric)
% ntrials : number of trials (scalar numeric)
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

	if nargin < 4 || ~isscalar( ntrials ) || ~isnumeric( ntrials )
		error( 'invalid argument: ntrials' );
	end

	if nargin < 5 || ~isscalar( seed ) || ~isnumeric( seed )
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

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'debug_activity_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'debug activity detection...' );

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

			% plot detection statistics
		cdf.plot.activity( run, cfg, fullfile( outdir, sprintf( 'run_%d_activity.png', i ) ) );

			% prepare trial plot directory
		plotdir = fullfile( outdir, sprintf( 'run_%d', i ) );
		if exist( plotdir, 'dir' ) == 7
			rmdir( plotdir, 's' );
		end
		mkdir( plotdir );

			% sample random trials
		rs = rng(); % push randomness
		rng( seed, 'twister' );

		trialids = 1:numel( run.trials ); % valid trials
		invalids = [];
		for j = trialids
			if isnan( run.trials(j).cue ) || isnan( run.trials(j).dist ) || any( isnan( run.trials(j).range ) )
				invalids(end+1) = j;
			end
		end
		trialids(invalids) = [];

		if numel( trialids ) > 1 && numel( trialids ) > ntrials % sample trials
			trialids = randsample( trialids, ntrials );
		end

		rng( rs ); % pop randomness

			% plot trials
		for j = trialids
			cdf.plot.trial_activity( run, cfg, j, ...
				fullfile( plotdir, sprintf( 'run_%d_trial_%d_activity.png', i, j ) ) );
		end

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

