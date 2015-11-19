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
		resp = trial.respdet;

		resp.bo = NaN;
		resp.vo = NaN;
		resp.vr = NaN;

		if any( isnan( trial.range ) ) || any( isnan( resp.range ) ) % skip invalid trials
			logger.progress( i, n );
			continue;
		end

			% prepare data
		noir = dsp.sec2smp( [trial.cue, trial.dist], run.audiorate ) + [1, 0]; % ranges
		respr = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0];

		noits = run.audiodata(noir(1):noir(2), 1); % signals
		respts = run.audiodata(respr(1):respr(2), 1);

			% prepare config
		sta_frame = [15, 5];
		sta_wnd = @hann;

		glottis_band = [150, 500];
		glottis_rordt = 25;
		glottis_rorpeak = 6;

		schwa_length = 20;
		schwa_power = -20;

		plosion_threshs = [20, 10];
		plosion_delta = 1;
		plosion_width = 10;

			% get subband fft
		frame = cdfaux.sta.msec2smp( sta_frame, run.audiorate );

		noift = cdfaux.sta.framing( noits, frame, sta_wnd );
		[noift, noifreqs] = cdfaux.sta.fft( noift, run.audiorate );
		[noift, noifreqs] = cdfaux.sta.banding( noift, noifreqs, glottis_band );

		respft = cdfaux.sta.framing( respts, frame, sta_wnd );
		[respft, respfreqs] = cdfaux.sta.fft( respft, run.audiorate );
		[respft, respfreqs] = cdfaux.sta.banding( respft, respfreqs, glottis_band );

			% set maximum powers
		noimax = max( noift, [], 1 ); % denoising
		m = size( respft, 1 );
		for j = 1:m
			respft(j, :) = respft(j, :) - noimax;
		end
		respft(respft < eps) = eps;

		resppow = max( respft, [], 2 );

			% smoothing
		resppow = cdfaux.sta.unframe( resppow, frame );
		resppow = resppow(1:size( respts, 1 ));

			% get ror and peaks
		rordt = cdfaux.sta.msec2smp( glottis_rordt, run.audiorate );

		respror = cdfaux.k15.ror( pow2db( resppow ), rordt );

		resppeak = cdfaux.k15.peak( respror, glottis_rorpeak );
		respglottis = cdfaux.k15.peak_glottis( resppeak, pow2db( resppow ), respror, ...
			cdfaux.sta.msec2smp( schwa_length, run.audiorate ), schwa_power );

			% set glottis landmarks
		m = numel( respglottis );
		pairlen = respglottis(2:2:m) - respglottis(1:2:m) + 1;
		[~, pairind] = max( pairlen ); % longest pair

		if ~isempty( pairind )
			resp.vo = respr(1) + respglottis(2*pairind-1)-1;
			resp.vr = respr(1) + respglottis(2*pairind)-1;
			nvos = nvos + 1;
			nvrs = nvrs + 1;
		end

			% get plosion indices
		resppiser = respts;
		if ~isnan( resp.vo )
			resppiser(resp.vo-respr(1)+1:end) = []; % restrict detection range
		end

		resppi = cdfaux.k15.plosion( ...
			cdfaux.k15.replaygain( resppiser, run.audiorate ), ...
			cdfaux.sta.msec2smp( plosion_delta, run.audiorate ), cdfaux.sta.msec2smp( plosion_width, run.audiorate ) );

			% set burst landmark
		boi = find( resppi >= max( plosion_threshs ), 1, 'first' ); % upper threshold first
		if isempty( boi )
			boi = find( resppi >= min( plosion_threshs ), 1, 'first' ); % lower threshold next
		end

		if ~isempty( boi )
			resp.bo = respr(1) + boi-1;
			nbos = nbos + 1;
		end

			% convert landmarks scale
		resp.bo = dsp.smp2sec( resp.bo - 1, run.audiorate );
		resp.vo = dsp.smp2sec( resp.vo - 1, run.audiorate );
		resp.vr = dsp.smp2sec( resp.vr - 1, run.audiorate );

		logger.progress( i, n );
	end

	logger.log( 'burst-onsets: %d/%d', nbos, n );
	logger.log( 'voice-onsets: %d/%d', nvos, n );
	logger.log( 'voice-releases: %d/%d', nvrs, n );

	logger.untab();
end

