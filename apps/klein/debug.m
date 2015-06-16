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

		% include cue-distractor package
	addpath( '../../cdp/' );

		% prepare for output
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( '%d-%d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'debug data...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read cdf data
		infile = fullfile( indir, sprintf( 'run_%d.mat', i ) );

		if exist( infile, 'file' ) ~= 2 % skip non-existing
			logger.untab( 'skipping' );
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

		read_audio( run, run.audiofile, false );

			% plot random trials
		plotdir = fullfile( outdir, sprintf( 'run_%d', i ) ); % prepare for output
		if exist( plotdir, 'dir' ) == 7
			rmdir( plotdir, 's' );
		end
		mkdir( plotdir );

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
				fullfile( plotdir, sprintf( 'trial_%d.png', trials(j).id ) ) );
		end

			% cleanup
		delete( run );

		logger.untab();
	end

		% cleanup
	logger.untab( 'done.' ); % stop logging

end

