function sync( indir, outdir, ids )
% marker synchronization
%
% SYNC( indir, outdir, ids )
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
	logger.tab( 'marker synchronization...' );

		% configure framework
	cfg = cdf.hConfig();

	cfg.sync_range = [-0.125, 0.025]; % search range
	cfg.sync_smooth = 0.002; % smoothing
	cfg.sync_thresh = 3.0; % mahalanobis threshold

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

			% sync markers
		[sync0, synchints, syncs] = cdf.sync( run, cfg );

			% write output
		run.audiodata = []; % do not write redundant audio data

		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', i ) );
		logger.log( 'write cdf data (''%s'')...', cdffile );
		save( cdffile, 'run' );

		auxfile = fullfile( outdir, sprintf( 'aux_%d.mat', i ) );
		logger.log( 'write aux data (''%s'')...', auxfile );
		save( auxfile, 'sync0', 'synchints', 'syncs' );

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

