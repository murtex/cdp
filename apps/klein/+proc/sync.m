function sync( indir, outdir, ids )
% sync raw timings
%
% SYNC( indir, outdir, ids )
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

		% check/prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	auxdir = fullfile( outdir, 'aux/' );
	if exist( auxdir, 'dir' ) ~= 7
		mkdir( auxdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( 'proc_sync_%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'sync raw timings...' );

		% configure framework
	cfg = cdf.hConfig();

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

			% sync timings
		[sync0, synchints, syncs] = cdf.sync( run, cfg );

			% write output
		run.audiodata = []; % do not write redundant audio data

		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', i ) );
		logger.log( 'write cdf data (''%s'')...', cdffile );
		save( cdffile, 'run' );

		auxfile = fullfile( auxdir, sprintf( 'run_%d_sync_aux.mat', i ) );
		logger.log( 'write aux data (''%s'')...', auxfile );
		save( auxfile, 'sync0', 'synchints', 'syncs' );

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

