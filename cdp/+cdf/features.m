function features( run, cfg, landmarks, outdir )
% compute features
%
% FEATURES( run, cfg, landmarks, outdir )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% landmarks : use landmarks (scalar logical)
% outdir : output directory (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( landmarks ) || ~islogical( landmarks )
		error( 'invalid argument: landmarks' );
	end

	if nargin < 4 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'compute features ''%s''...', outdir );

		% proceed trials
	n = numel( run.trials );

	trials = 0; % pre-allocation
	subs = 0;

	logger.progress();
	for i = 1:n

			% reset features
		trial = run.trials(i);

		trial.detected.featfile = '';
		trial.labeled.featfile = '';

			% set response range
		resp = trial.detected;

		if landmarks
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

		respfeat(:, end+1) = sum( repmat( respfreqs, size( respft, 1 ), 1 ) .* respft, 2 ) ./ sum( respft, 2 ); % spectral centroid
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band1 ); % band #1
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band2 ); % band #2
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band3 ); % band #3
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band4 ); % band #4
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band5 ); % band #5
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band6 ); % band #6
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band7 ); % band #7
		respfeat(:, end+1) = sum( brespft, 2 );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band8 ); % band #8
		respfeat(:, end+1) = sum( brespft, 2 );

		respfeat = sta.unframe( respfeat, frame ); % smoothing
		respfeat = zscore( respfeat, 1, 1 ); % standardization

		if any( isnan( respfeat(:) ) ) || any( isinf( respfeat(:) ) )
			warning( 'NaN/Inf features' );
		end

			% get subsequence features
		subfeat = brf.subseq( respfeat, dsp.msec2smp( cfg.feat_intlen, run.audiorate ), cfg.feat_intcount );

		if isempty( subfeat )
			logger.progress( i, n );
			continue;
		end

		trials = trials + 1;
		subs = subs + size( subfeat, 1 );

			% set and write feature file
		trial.detected.featfile = fullfile( outdir, sprintf( '%d.mat', trial.id ) );

		save( trial.detected.featfile, 'subfeat', '-v7.3' ); % require hdf5-format

		logger.progress( i, n );
	end

	logger.log( 'trials: %d/%d', trials, n );
	logger.log( 'subsequences: %d', subs );

	logger.untab();
end

