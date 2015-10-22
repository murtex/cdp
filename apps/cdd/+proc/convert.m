function convert( indir, outdir, ids, logfile )
% raw conversion
%
% CONVERT( indir, outdir, ids, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (vector numeric)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) % input directory
		error( 'invalid argument: indir' );
	end

	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	if nargin < 3 || ~isvector( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'raw conversion...' );

		% workload
	cid = 1;
	for id = ids
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read raw data
		run = cdf.hRun();

		proc.read_audio( run, fullfile( indir, sprintf( 'participant_%d.wav', id ) ) );
		proc.read_psych( run, fullfile( indir, sprintf( 'participant_%d.txt', id ) ) );

			% write converted data
		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', id ) );
		logger.log( 'write cdf data (''%s'')...', cdffile );

		run.audiodata = []; % do not write redundant audio data

		save( cdffile, 'run' );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

