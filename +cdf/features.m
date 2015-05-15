function features( run, cfg, labeled, landmarks, outdir )
% extract features
%
% FEATURES( run, cfg, labeled, landmarks, outdir )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% labeled : use labeled responses (scalar logical)
% landmarks : use landmarks (scalar logical)
% outdir : output directory (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( labeled ) || ~islogical( labeled )
		error( 'invalid argument: labeled' );
	end

	if nargin < 4 || ~isscalar( landmarks ) || ~islogical( landmarks )
		error( 'invalid argument: landmarks' );
	end

	if nargin < 5 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'extract features ''%s''...', outdir );

		% proceed trials
	n = numel( run.trials );

	trials = 0; % pre-allocation
	subs = 0;

	logger.progress();
	for i = 1:n

			% reset features
		trial = run.trials(i);

		if labeled % set response
			trial.labeled.featfile = '';
			resp = trial.labeled;
		else
			trial.detected.featfile = '';
			resp = trial.detected;
		end

		if landmarks % set response range
			resprange = [resp.bo, resp.vr];
		else
			resprange = resp.range;
		end

		if any( isnan( resprange ) ) % skip invalids
			logger.progress( i, n );
			continue;
		end

			% set signals
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(resprange(1):resprange(2), 1);

			% get full bandwidth fft
		frame = dsp.msec2smp( cfg.sta_frame, run.audiorate );

		noift = sta.framing( noiser, frame, cfg.sta_wnd );
		[noift, noifreqs] = sta.fft( noift, run.audiorate );
		[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.sta_band );

		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );
		[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.sta_band );

			% denoising
		noimax = max( noift, [], 1 );
		m = size( respft, 1 );
		for j = 1:m
			respft(j, :) = respft(j, :) - noimax;
		end
		respft(respft < eps) = eps;

			% set prime features
		respfeat = NaN( size( respft, 1 ), 0 ); % pre-allocation

		respfeat(:, end+1) = sum( respft, 2 ); % total power 
		respfeat(:, end+1) = sum( repmat( respfreqs, size( respft, 1 ), 1 ) .* respft, 2 ) ./ sum( respft, 2 ); % spectral centroid

		respfeat = sta.unframe( respfeat, frame ); % smoothing
		respfeat = zscore( respfeat, 1, 1 ); % standardization

		if any( isnan( respfeat(:) ) ) || any( isinf( respfeat(:) ) )
			warning( 'NaN/Inf features' );
		end

			% get subsequence features
		%rng(1); % DEBUG
		subfeat = brf.subseq( respfeat, dsp.msec2smp( cfg.feat_intlen, run.audiorate ), cfg.feat_intcount );
		%error( 'DEBUG' );

		if isempty( subfeat )
			logger.progress( i, n );
			continue;
		end

		trials = trials + 1;
		subs = subs + size( subfeat, 1 );

			% set and write feature file
		outfile = fullfile( outdir, sprintf( '%d.mat', trial.id ) );

		if labeled
			trial.labeled.featfile = outfile;
		else
			trial.detected.featfile = outfile;
		end

		save( outfile, 'subfeat', '-v7.3' ); % hdf5-format

		logger.progress( i, n );
	end

	logger.log( 'trials: %d/%d', trials, n );
	logger.log( 'subsequences: %d', subs );

	logger.untab();
end

