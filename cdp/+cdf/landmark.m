function landmark( run, cfg )
% detect landmarks
%
% LANDMARK( run, cfg )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'detect landmarks...' );

		% proceed trials
	n = numel( run.trials );

	nvos = 0;
	nvrs = 0;
	nbos = 0;

	logger.progress();
	for i = 1:n

			% reset landmarks
		trial = run.trials(i);

		trial.detected.bo = NaN;
		trial.detected.vo = NaN;
		trial.detected.vr = NaN;

		if any( isnan( trial.detected.range ) )
			logger.progress( i, n );
			continue;
		end

			% set signals
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(trial.detected.range(1):trial.detected.range(2), 1);

			% get subband fft
		frame = dsp.msec2smp( cfg.sta_frame, run.audiorate );

		noift = sta.framing( noiser, frame, cfg.sta_wnd );
		[noift, noifreqs] = sta.fft( noift, run.audiorate );
		[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.glottis_band );

		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );
		[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.glottis_band );

			% set maximum powers
		noimax = max( noift, [], 1 ); % denoising
		m = size( respft, 1 );
		for j = 1:m
			respft(j, :) = respft(j, :) - noimax;
		end
		respft(respft < eps) = eps;

		resppow = max( respft, [], 2 );

			% smoothing
		resppow = sta.unframe( resppow, frame );
		resppow = resppow(1:size( respser, 1 ));

			% get ror and peaks
		rordt = dsp.msec2smp( cfg.glottis_rordt, run.audiorate );

		respror = k15.ror( pow2db( resppow ), rordt );

		resppeak = k15.peak( respror, cfg.glottis_rorpeak );
		respglottis = k15.peak_glottis( resppeak, pow2db( resppow ), respror, ...
			dsp.msec2smp( cfg.schwa_length, run.audiorate ), cfg.schwa_power );

			% set glottis landmarks
		m = numel( respglottis );
		pairlen = respglottis(2:2:m) - respglottis(1:2:m) + 1;
		[~, pairind] = max( pairlen ); % longest pair

		if ~isempty( pairind )
			trial.detected.vo = trial.detected.range(1) + respglottis(2*pairind-1)-1;
			trial.detected.vr = trial.detected.range(1) + respglottis(2*pairind)-1;
			nvos = nvos + 1;
			nvrs = nvrs + 1;
		end

			% get plosion indices
		resppiser = respser;
		if ~isnan( trial.detected.vo )
			resppiser(trial.detected.vo-trial.detected.range(1)+1:end) = []; % restrict detection range
		end

		resppi = k15.plosion( ...
			k15.replaygain( resppiser, run.audiorate ), ...
			dsp.msec2smp( cfg.plosion_delta, run.audiorate ), dsp.msec2smp( cfg.plosion_width, run.audiorate ) );

			% set burst landmark
		boi = find( resppi >= max( cfg.plosion_threshs ), 1, 'first' ); % upper threshold first
		if isempty( boi )
			boi = find( resppi >= min( cfg.plosion_threshs ), 1, 'first' ); % lower threshold next
		end

		if ~isempty( boi )
			trial.detected.bo = trial.detected.range(1) + boi-1;
			nbos = nbos + 1;
		end

		logger.progress( i, n );
	end

	logger.log( 'burst-onsets: %d/%d', nbos, n );
	logger.log( 'voice-onsets: %d/%d', nvos, n );
	logger.log( 'voice-releases: %d/%d', nvrs, n );

	logger.untab();
end

