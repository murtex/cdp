function activity( indir, outdir, ids )
% detect voice activity
%
% ACTIVITY( indir, outdir, ids )
% 
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)

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

		% prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	plotdir = fullfile( outdir, 'plot/' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'activity_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'detect voice activity...' );

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

			% detect activities and plot statistics
		cdf.activity( run, cfg );

		cdf.plot.activity( run, cfg, fullfile( plotdir, sprintf( 'run_%d_activity.png', i ) ) );

			% write output data
		run.audiodata = []; % do not write redundant audio data

		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', i ) );
		logger.log( 'write cdf data (''%s'')...', cdffile );
		save( cdffile, 'run' );

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

