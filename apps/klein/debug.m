function debug( indir, outdir, ids )
% debug data
%
% DEBUG( indir, outdir, ids )
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

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'debug_%03d-%03d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'debug data...' );

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

			% prepare for output
		plotdir = fullfile( outdir, sprintf( '%d', run.id ) );
		if exist( plotdir, 'dir' ) == 7
			rmdir( plotdir, s );
		end
		mkdir( plotdir );

			% plot random trials
		trials = [run.trials.detected];
		lens = diff( cat( 1, trials.range ), 1, 2 );
		trials = run.trials(~isnan( lens ));
		trials = randsample( trials, min( numel( trials ), 20 ) ); % 20 trials

		n = numel( trials );
		for j = 1:n
			cdf.plot.trial_range( run, cfg, trials(j), [...
				min( trials(j).detected.range(1), trials(j).labeled.range(1) ), ...
				max( trials(j).detected.range(2), trials(j).labeled.range(2) )], ...
				trials(j).detected.range(1), ...
				fullfile( plotdir, sprintf( '%d.png', trials(j).id ) ) );
		end

			% cleanup
		delete( run );

		logger.untab();
	end

		% cleanup
	logger.untab( 'done.' ); % stop logging

end

