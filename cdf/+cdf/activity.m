function activity( run, cfg )
% voice activity detection
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
	logger.tab( 'voice activity detection...' );

		% proceed trials
	ntrials = numel( run.trials );

	logger.progress();
	for i = 1:ntrials
		trial = run.trials(i);
		resplab = trial.resplab;
		respdet = trial.respdet;

			% reset activity
		respdet.range = [NaN, NaN];

			% prepare ranges and signals
		r = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0];
		relnoir = dsp.sec2smp( [trial.cue, trial.dist], run.audiorate ) + [1, 0] - r(1) + 1;

		respts = run.audiodata(r(1):r(2), 1);

		[respsd, respfreqs] = dsp.stransf( respts, run.audiorate, cfg.vad_freqband(1), cfg.vad_freqband(2), cfg.vad_nfreqs );
		noisd = respsd(:, relnoir(1):relnoir(2));

			% detect activity
		[sdiv, threshs, vact] = k15.vad( respsd, noisd );

			% set activity, TODO: check against distractor! multiple activities?
		vdiff = diff( [false, vact, false] );

		vstart = find( vdiff == 1, 1 ) - 1;
		vstop = find( vdiff == -1, 1 ) - 1;

		if ~isempty( vstart ) && ~isempty( vstop )
			respdet.range(1) = dsp.smp2sec( vstart + r(1) - 1, run.audiorate );
			respdet.range(2) = dsp.smp2sec( vstop + r(1) - 1, run.audiorate );
		end

		logger.progress( i, ntrials );
	end

		% done
	logger.untab();

end

