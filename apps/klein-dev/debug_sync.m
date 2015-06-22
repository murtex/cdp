function debug_sync( cdfindir, syncindir, outdir, ids, ntrials, seed )
% debug syncing
% 
% DEBUG_SYNC( cdfindir, syncindir, outdir, ids, ntrials, seed )
%
% INPUT
% cdfindir : cdf input directory (row char)
% syncindir : sync input directory (row char)
% outdir : plot directory (row char)
% ids : subject identifiers (row numeric)
% ntrials : number of trials (scalar numeric)
% seed : randomization seed (scalar numeric)

		% safeguard
	if nargin < 1 || ~isrow( cdfindir ) || ~ischar( cdfindir )
		error( 'invalid argument: cdfindir' );
	end

	if nargin < 2 || ~isrow( syncindir ) || ~ischar( syncindir )
		error( 'invalid argument: syncindir' );
	end

	if nargin < 3 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	if nargin < 4 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

	if nargin < 5 || ~isscalar( ntrials ) || ~isnumeric( ntrials )
		error( 'invalid argument: ntrials' );
	end

	if nargin < 6 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: seed' );
	end

		% prepare directories
	if exist( cdfindir, 'dir' ) ~= 7
		error( 'invalid argument: cdfindir' );
	end

	if exist( syncindir, 'dir' ) ~= 7
		error( 'invalid argument: syncindir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'debug_sync_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'debug syncing...' );

	cfg = cdf.hConfig(); % use defaults

		% proceed subject identifiers
	for i = ids

			% read input data
		cdffile = fullfile( cdfindir, sprintf( 'run_%d.mat', i ) );
		syncfile = fullfile( syncindir, sprintf( 'syncs_%d.mat', i ) );

		if exist( cdffile, 'file' ) ~= 2 || exist( syncfile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		logger.log( 'read sync data (''%s'')...', syncfile );
		load( syncfile, 'sync0', 'synchints', 'syncs' );

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

		trialids = 1:numel( run.trials ); % valid trials
		invalids = [];
		for j = trialids
			if isnan( run.trials(j).cue )
				invalids(end+1) = j;
			end
		end
		trialids(invalids) = [];

		if numel( trialids ) > 1 && numel( trialids ) > ntrials % sample trials
			trialids = randsample( trialids, ntrials );
		end

		rng( rs ); % pop randomness

			% plot trial sync 
		for j = trialids
			cdf.plot.trial_sync( run, cfg, j, sync0, synchints(j), syncs(j), ...
				fullfile( plotdir, sprintf( 'run_%d_trial_%d_sync.png', i, j ) ) );
		end

	end

		% done
	logger.untab( 'done' );

end

