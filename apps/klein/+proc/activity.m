function activity( indir, outdir, ids )
% voice activity detection
%
% ACTIVITY( indir, outdir, ids )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	elseif exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( '%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'voice activity detection...' );

	cfg = cdf.hConfig(); % defaults

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		if exist( cdffile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		proc.read_audio( run, run.audiofile, true );

			% detect voice activity
		cdf.activity( run, cfg );

			% write output
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

