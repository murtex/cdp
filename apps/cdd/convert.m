function convert( indir, outdir, ids )
% convert raw data
%
% CONVERT( indir, outdir, ids )
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

		% initialize framework
	addpath( '../../cdf/' );

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'convert_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'convert raw data...' );

		% proceed subject identifiers
	for i = ids
		logger.tab( 'subject: %d', i );

			% prepare raw filenames
		audiofile = fullfile( indir, sprintf( 'participant_%d.wav', i ) );
		trialfile = fullfile( indir, sprintf( 'participant_%d.txt', i ) );

		if exist( audiofile, 'file' ) ~= 2 || exist( trialfile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

			% read raw data
		run = cdf.hRun();

		read_audio( run, audiofile, false );
		read_trials( run, trialfile );

			% write cdf data
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

