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

	addpath( '../../cdp/' ); % include cue-distractor package

		% prepare for output
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'convert_%03d-%03d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'convert raw data...' );

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read raw data
		audiofile = fullfile( indir, sprintf( 'participant_%d_1.wav', i ) );
		logfile = fullfile( indir, sprintf( 'participant_%d.txt', i ) );
		labelfile = fullfile( indir, sprintf( 'participant_%d.xlsx', i ) );

		if exist( audiofile, 'file' ) ~= 2 || exist( logfile, 'file' ) ~= 2 || exist( labelfile, 'file' ) ~= 2
			logger.untab( 'skipping' ); % skip partial data
			continue;
		end

		run = cdf.hRun();

		read_audio( run, audiofile, true );
		read_trials( run, logfile );
		read_labels( run, labelfile );

			% write cdf data
		outfile = fullfile( outdir, sprintf( '%03d.cdf', run.id ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run', '-v7.3' );

			% cleanup
		delete( run );

		logger.untab();
	end

		% cleanup
	logger.untab( 'done.' ); % stop logging

end

