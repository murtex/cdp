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
		resp.startpos = NaN;
		resp.stoppos = NaN;

			% set local noise and response signal
		noir = dsp.sec2smp( [trial.cuepos, trial.distpos], run.audiorate ) + 1; % noise range
		if any( isnan( noir ) ) || any( noir < 1 ) || any( noir > run.audiosize(1) )
			logger.progress( i, ntrials );
			continue;
		end

		respr = [dsp.sec2smp( trial.cuepos, run.audiorate ) + 1, run.audiosize(1)]; % response range
		if i < ntrials
			respr(2) = dsp.sec2smp( run.trials(i+1).cuepos, run.audiorate );
		end
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

			% get voice activity
		[va, ~, ~, ~, ~] = k15.vad( respft, noift, cfg.vad_adjacency, cfg.vad_hangover );

			% set response to first activity
		vaswaps = diff( cat( 1, false, va ) );

		vastart = find( vaswaps == 1, 1 );
		if ~isempty( vastart )
			resp.startpos = trial.cuepos + dsp.fr2sec( vastart, frlen, cfg.vad_froverlap, run.audiorate );

			vastop = find( vaswaps == -1, 1 ) - 1;
			if ~isempty( vastop )
				resp.stoppos = trial.cuepos + dsp.fr2sec( vastop, frlen, cfg.vad_froverlap, run.audiorate );
			else
				resp.stoppos = dsp.smp2sec( respr(2), run.audiorate ); % fallback: stop with trial end
			end
		end

		logger.progress( i, ntrials );
	end

		% log detections
	logger.log( 'activities: %d/%d', sum( ~isnan( [run.resps_det.startpos] ) ), ntrials );

	logger.untab();
end

