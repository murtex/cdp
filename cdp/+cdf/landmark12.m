function landmark11( run, cfg )
% detect landmarks (version #11)
%
% LANDMARK11( run, cfg )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
%
% REMARKS
% w/o noise subtraction
% revised glottal peak pairing
% pre-select glottal pairs
% rescaled powers
% epsilon powers
% more advanced successive thresholding

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
    
    nrefvos = 0; % DEBUG: use labeled landmarks as reference!
    nrefvrs = 0;
    nrefbos = 0;

	logger.progress();
	for i = 1:n

			% reset landmarks
		trial = run.trials(i);

		trial.detected.bo = NaN;
		trial.detected.vo = NaN;
		trial.detected.vr = NaN;
        
        if ~isnan( trial.labeled.bo ) % DEBUG: use labeled landmarks as reference!
            nrefbos = nrefbos + 1;
        end
        if ~isnan( trial.labeled.vo )
            nrefvos = nrefvos + 1;
        end
        if ~isnan( trial.labeled.vr )
            nrefvrs = nrefvrs + 1;
        end

		refrange = trial.labeled.range; % DEBUG: use labeled activity range as reference!
        refrange = refrange + sta.msec2smp( 25, run.audiorate ) * [-1, 2]; % plus some extra space

		if any( isnan( trial.range ) ) || any( isnan( refrange ) ) % skip invalid trials
			logger.progress( i, n );
			continue;
        end
        
        refrange(1) = max( 1, refrange(1) ); % DEBUG: do not exceed maximum range!
        refrange(2) = min( run.audiolen, refrange(2) );

			% set signals
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(refrange(1):refrange(2), 1);

			% get subband fft
		frame = sta.msec2smp( cfg.sta_frame, run.audiorate );

		%noift = sta.framing( noiser, frame, cfg.sta_wnd );
		%[noift, noifreqs] = sta.fft( noift, run.audiorate );
		%[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.glottis_band );

		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );
		respft(:, 2:end) = 2*respft(:, 2:end);
		[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.glottis_band );

			% set maximum powers
		%noimax = max( noift, [], 1 ); % denoising
		%m = size( respft, 1 );
		%for j = 1:m
			%respft(j, :) = respft(j, :) - noimax;
		%end
        
		respft(respft < eps) = eps;        
		resppow = max( respft, [], 2 );

			% smoothing
		resppow = sta.unframe( resppow, frame );
		resppow = resppow(1:size( respser, 1 ));

			% get ror and peaks
		cfg.glottis_rorpeak = 9; % TODO: hard-coded value!
		cfg.schwa_power = -18;

		rordt = sta.msec2smp( cfg.glottis_rordt, run.audiorate );

		respror = k15.ror( pow2db( resppow ), rordt );

		resppeak = k15.peak( respror, cfg.glottis_rorpeak );
		respglottis = k15.peakg( resppeak, pow2db( resppow ), respror, ...
			sta.msec2smp( cfg.schwa_length, run.audiorate ), cfg.schwa_power );

			% NEW: pre-select glottal landmarks
		bpos = (refrange(2) - refrange(1)) / 5; % TODO: hard-coded thresholds

		while numel( respglottis ) > 3 && respglottis(1) <= bpos % skip possible burst-transition
			respglottis(1:2) = [];
		end

			% OLD: set glottis landmarks
		m = numel( respglottis );
		pairlen = respglottis(2:2:m) - respglottis(1:2:m) + 1;
		[~, pairind] = max( pairlen ); % longest pair

		if ~isempty( pairind )
			trial.detected.vo = refrange(1) + respglottis(2*pairind-1)-1;
			trial.detected.vr = refrange(1) + respglottis(2*pairind)-1;
			nvos = nvos + 1;
			nvrs = nvrs + 1;
		end

			% get plosion indices
		resppiser = respser;
		if ~isnan( trial.detected.vo )
			resppiser(trial.detected.vo-refrange(1)+1:end) = []; % restrict detection range
		end

		resppi = k15.plosion( ...
			k15.replaygain( resppiser, run.audiorate ), ...
			sta.msec2smp( cfg.plosion_delta, run.audiorate ), sta.msec2smp( cfg.plosion_width, run.audiorate ) );

			% OLD: set burst landmark
		%boi = find( resppi >= max( cfg.plosion_threshs ), 1, 'first' ); % upper threshold first
		%if isempty( boi )
			%boi = find( resppi >= min( cfg.plosion_threshs ), 1, 'first' ); % lower threshold next
		%end

			% NEW: successive thresholding
		thresh = 125; % TODO: hard coded value
		boi = [];

		while isempty( boi )
			boi = find( resppi >= thresh, 1, 'first' );
			thresh = thresh - 1;
			if thresh < 0
				break;
			end
		end

		if ~isempty( boi )
			trial.detected.bo = refrange(1) + boi-1;
			nbos = nbos + 1;
		end

		logger.progress( i, n );
	end

	%logger.log( 'burst-onsets: %d/%d', nbos, n );
	%logger.log( 'voice-onsets: %d/%d', nvos, n );
	%logger.log( 'voice-releases: %d/%d', nvrs, n );
    
	logger.log( 'burst-onsets: %d/%d', nbos, nrefbos ); % DEBUG: use labeled landmarks as reference!
	logger.log( 'voice-onsets: %d/%d', nvos, nrefvos );
	logger.log( 'voice-releases: %d/%d', nvrs, nrefvrs );

	logger.untab();
end

