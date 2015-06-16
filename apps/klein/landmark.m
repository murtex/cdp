function landmark( indir, outdir, ids )
% detect landmarks
%
% LANDMARK( indir, outdir, ids )
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

	plotdir = fullfile( outdir, 'plot' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( '%d-%d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'detect landmarks...' );

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

			% detect landmarks
		cdf.landmark( run, cfg );

			% plot detection statistics
		trials = [run.trials.detected];
		detected = cat( 2, [trials.bo]', [trials.vo]', [trials.vr]' );
		trials = [run.trials.labeled];
		labeled = cat( 2, [trials.bo]', [trials.vo]', [trials.vr]' );
		cdf.plot.landmark( run, detected, labeled, fullfile( plotdir, sprintf( 'run_%d_landmark.png', i ) ) );
		cdf.plot.timing( run, detected, labeled, fullfile( plotdir, sprintf( 'run_%d_timing.png', i ) ) );

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

