function extract( indir, outdir, ids )
% extract repsonses
%
% EXTRACT( indir, outdir, ids )
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

	plotdir = fullfile( outdir, 'plot' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'extract_%03d-%03d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'extract responses...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read cdf data
		infile = fullfile( indir, sprintf( '%03d.cdf', i ) );

		if exist( infile, 'file' ) ~= 2
			logger.untab( 'skipping' ); % skip non-existing
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

		read_audio( run, run.audiofile, false );

			% extract responses and plot
		cdf.extract( run, cfg );

		trials = [run.trials.detected];
		detected = cat( 1, trials.range );
		trials = [run.trials.labeled];
		labeled = cat( 1, trials.range );
		cdf.plot.extract( run, detected, labeled, fullfile( plotdir, sprintf( '%d.png', run.id ) ) );

			% write cdf data
		run.audiodata = []; % do not write audio data

		outfile = fullfile( outdir, sprintf( '%03d.cdf', run.id ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run', '-v7' );

			% cleanup
		delete( run );

		logger.untab();
	end

		% cleanup
	logger.untab( 'done.' ); % stop logging

end
