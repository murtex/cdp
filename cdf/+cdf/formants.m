function formants( run, cfg, lab )
% detect formant-onsets
%
% FORMANTS( run, cfg, lab )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% lab : labeled input flag (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( lab ) || ~islogical( lab )
		error( 'invalid argument: lab' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'detect formant-onsets...' );

		% proceed trials
	ntrials = numel( run.trials );

	logger.progress();
	for i = 1:ntrials
		trial = run.trials(i);
		resp = run.resps_det(i);

			% reset formants
		resp.f0 = [NaN, NaN];
		resp.f1 = [NaN, NaN];
		resp.f2 = [NaN, NaN];
		resp.f3 = [NaN, NaN];

			% set response signal
		if lab
			r = dsp.sec2smp( run.resps_lab(i).range, run.audiorate ) + [1, 0];
		else
			r = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0];
		end
		if any( isnan( r ) )
			logger.progress( i, ntrials );
			continue;
		end

		ts = run.audiodata(r(1):r(2), 1);

			% set spectral decomposition
		[sd, freqs] = dsp.fst( ts, run.audiorate, cfg.fod_freqband(1), cfg.fod_freqband(2), cfg.fod_nfreqs );

		sd = sd .* conj( sd );
		sd = sd .^ cfg.fod_gamma;
		sd = log( sd + eps );

			% get formant-onsets
		k15.fod( sd, freqs, run.audiorate, 5, cfg.fod_peakratio, cfg.fod_peakgap, cfg.fod_peakleap );

			% DEBUG
		break;

		logger.progress( i, ntrials );
	end

	logger.untab();
end

