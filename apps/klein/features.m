function features( indir, outdir, ids )
% compute features
% 
% FEATURES( indir, outdir, ids )
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
	logger.tab( 'compute features...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read cdf data
		infile = fullfile( indir, sprintf( 'run_%d.mat', i ) );

		if exist( infile, 'file' ) ~= 2
			logger.untab( 'skipping' ); % skip non-existing
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );

		read_audio( run, run.audiofile, false );

			% compute features
		subdir = fullfile( outdir, sprintf( 'run_%d_detected', i ) ); % detected responses
		if exist( subdir, 'dir' ) ~= 7
			mkdir( subdir );
		end

		cdf.features( run, cfg, subdir, false );

		subdir = fullfile( outdir, sprintf( 'run_%d_labeled', i ) ); % labeled responses
		if exist( subdir, 'dir' ) ~= 7
			mkdir( subdir );
		end

		cdf.features( run, cfg, subdir, true );

			% write cdf data
		run.audiodata = []; % do not write audio data

		outfile = fullfile( outdir, sprintf( 'run_%d.mat', i ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run', '-v7' );

			% cleanup
		delete( run );

		logger.untab();
	end

		% cleanup
	logger.log( 'peak memory: %.1fGiB', logger.peakmem() / (1024^3) );

	logger.untab( 'done.' ); % stop logging

end

