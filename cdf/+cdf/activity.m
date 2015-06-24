function activity( run, cfg )
% detect voice activity
%
% ACTIVITY( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'detect voice activity...' );

		% proceed trials
	ntrials = numel( run.trials );

	logger.progress();
	for i = 1:ntrials
		trial = run.trials(i);
		resp = run.resps_det(i);

			% reset activity
		resp.range = [NaN, NaN];

			% set local noise and response signal
		noir = dsp.sec2smp( [trial.range(1), trial.dist], run.audiorate ) + [1, 0]; % noise range
		if any( isnan( noir ) ) || any( noir < 1 ) || any( noir > run.audiosize(1) )
			logger.progress( i, ntrials );
			continue;
		end

		respr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % response range
		if any( isnan( respr ) ) || any( respr < 1 ) || any( respr > run.audiosize(1) )
			logger.progress( i, ntrials );
			continue;
		end

		noits = run.audiodata(noir(1):noir(2), 1); % signals
		respts = run.audiodata(respr(1):respr(2), 1);

		if isempty( noits ) || isempty( respts )
			logger.progress( i, ntrials );
			continue;
		end

			% get short-time fourier transforms
		frlen = dsp.sec2smp( cfg.vad_frlength, run.audiorate );

		noifr = dsp.frame( noits, frlen, cfg.vad_froverlap, cfg.vad_frwindow ); % short-time framing
		respfr = dsp.frame( respts, frlen, cfg.vad_froverlap, cfg.vad_frwindow );

		[noift, noifreqs] = dsp.fft( noifr, run.audiorate ); % fourier transforms
		[respft, respfreqs] = dsp.fft( respfr, run.audiorate );

		[noift, noifreqs] = dsp.band( noift, noifreqs, cfg.vad_freqband(1), cfg.vad_freqband(2), true ); % one-sided subband
		[respft, respfreqs] = dsp.band( respft, respfreqs, cfg.vad_freqband(1), cfg.vad_freqband(2), true );

			% get voice activity
		[respvafr, ~, ~, ~, ~] = k15.vad( respft, noift, cfg.vad_adjacency, cfg.vad_hangover );

		respva = round( dsp.unframe( respvafr, frlen, cfg.vad_froverlap ) ); % unframing

			% set response to first activity
		vadiffs = diff( cat( 2, 0, respva ) );

		vastart = find( vadiffs == 1, 1 );
		if ~isempty( vastart )
			resp.range(1) = trial.range(1) + dsp.smp2sec( vastart - 1, run.audiorate );

			vastop = find( vadiffs == -1, 1 ) - 1;
			if ~isempty( vastop )
				resp.range(2) = trial.range(1) + dsp.smp2sec( vastop - 1, run.audiorate );
			else
				resp.range(2) = trial.range(2); % fallback to end of trial
			end
		end

		logger.progress( i, ntrials );
	end

		% log detections
	ndets = sum( ~isnan( diff( cat( 1, run.resps_det.range ), 1, 2 ) ) );
	logger.log( 'activities: %d/%d', ndets, ntrials );

	logger.untab();
end

