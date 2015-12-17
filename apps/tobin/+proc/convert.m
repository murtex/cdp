function convert( indir, outdir, ids, logfile )
% raw conversion
%
% CONVERT( indir, outdir, ids, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'raw conversion...' );

		% workload
	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read raw data
		run = cdf.hRun();

		proc.read_audio( run, fullfile( indir, sprintf( '%d/', id ) ) );
		proc.read_trials( run, fullfile( indir, sprintf( '%d/', id ) ) );

			% write converted data
		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', id ) );
		logger.log( 'write cdf data (''%s'')...', cdffile );

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

