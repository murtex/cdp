function features( run, cfg, outdir, labeled )
% compute features
%
% FEATURES( run, cfg, outdir, labeled )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% outdir : output directory (row char)
% labeled : use labeled response flag (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	if nargin < 4 || ~isscalar( labeled ) || ~islogical( labeled )
		erorr( 'invalid argument: labeled' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'compute features ''%s''...', outdir );

		% spectral centroid
	function c = centroid( freqs, ft )
		c = sum( repmat( freqs, size( ft, 1 ), 1 ) .* ft, 2 ) ./ sum( ft, 2 );
	end

		% proceed trials
	n = numel( run.trials );

	trials = 0; % pre-allocation
	subs = 0;

	logger.progress();
	for i = 1:n

			% reset features
		trial = run.trials(i);

		if labeled
			trial.labeled.featfile = '';
			resp = trial.labeled;
		else
			trial.detected.featfile = '';
			resp = trial.detected;
		end

		if any( isnan( trial.range ) ) || any( isnan( resp.range ) ) ... % skip invalid trials
				|| isnan( resp.bo ) || isnan( resp.vo )
			logger.progress( i, n );
			continue;
		end

			% set signals
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		%respser = run.audiodata(resp.range(1):resp.range(2), 1);
		respser = run.audiodata(resp.bo:resp.vo, 1);

			% get full bandwidth fft
		frame = sta.msec2smp( cfg.sta_frame, run.audiorate );

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
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band1 ); % band #1 power
		respfeat(:, end+1) = pow2db( sum( brespft, 2 ) );
		[brespft, ~] = sta.banding( respft, respfreqs, cfg.feat_band2 ); % band #2 power
		respfeat(:, end+1) = pow2db( sum( brespft, 2 ) );

		respfeat = sta.unframe( respfeat, frame ); % smoothing
		%respfeat = zscore( respfeat, 1, 1 ); % standardization

		if any( isnan( respfeat(:) ) ) || any( isinf( respfeat(:) ) )
			warning( 'NaN/Inf features' );
		end

			% get subsequence features
		subfeat = brf.subseq( respfeat, sta.msec2smp( cfg.feat_intlen, run.audiorate ), cfg.feat_intcount );

		if isempty( subfeat )
			logger.progress( i, n );
			continue;
		end

		trials = trials + 1;
		subs = subs + size( subfeat, 1 );

			% write feature file
		featfile = fullfile( outdir, sprintf( 'trial_%d.mat', i ) );

		if labeled
			trial.labeled.featfile = featfile;
		else
			trial.detected.featfile = featfile;
		end

		save( featfile, 'subfeat', '-v7' );

		logger.progress( i, n );
	end

	logger.log( 'trials: %d/%d', trials, n );
	logger.log( 'subsequences: %d', subs );

	logger.untab();
end

