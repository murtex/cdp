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

	nrespdets = 0; % pre-allocation

	logger.progress();
	for i = 1:ntrials
		trial = run.trials(i);
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

			% set activity
		vadiff = diff( [false, vact, false] );

		vastarts = find( vadiff == 1 ) - 1;
		vastops = find( vadiff == -1 ) - 1;

		vastarts = dsp.smp2sec( vastarts + r(1) - 1, run.audiorate );
		vastops = dsp.smp2sec( vastops + r(1) - 1, run.audiorate );

		skips = vastops - vastarts < cfg.vad_minlen; % skip too shorts, DEBUG: activity-2
		vastarts(skips) = [];
		vastops(skips) = [];

		%while sum( vastarts < trial.dist + cfg.vad_maxdist ) > 1 % skip leading exposureds, DEBUG: activuty-3
			%vastarts(1) = [];
			%vastops(1) = [];
		%end

		while sum( vastarts < trial.dist + cfg.vad_maxdist ) > 1 ... % skip distractor echoes, DEBUG: activity-4
				&& vastarts(2) - vastops(1) <= cfg.vad_maxgap
			vastarts(1) = [];
			vastops(1) = [];
		end

		if ~isempty( vastarts ) % set range
			respdet.range(1) = vastarts(1);
			respdet.range(2) = vastops(1);

			nrespdets = nrespdets + 1;
		end

		logger.progress( i, ntrials );
	end

	logger.log( 'responses: %d/%d', nrespdets, ntrials );

		% done
	logger.untab();

end

