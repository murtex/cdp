function activity( run, cfg )
% activity detection
%
% ACTIVITY( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' ) % cue-distractor run
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' ) % framework configuration
		error( 'invalid argument: cfg' );
	end

		% init
	logger = xis.hLogger.instance(); % start logging
	logger.tab( 'activity detection...' );
	
		% proceed (valid) trials
	trials = [run.trials]; % prepare valid trials
	
	invalids = ~is_valid( [run.trials] );
	trials(invalids) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	logger.progress();
	for i = 1:ntrials
		trial = trials(i);
		respdet = trial.respdet;

			% prepare data
		tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges

		tts = run.audiodata(tr(1):tr(2), 1); % signals

			% detect activities
		[stft, times, freqs, stride, ~, ~, ~, va] = k15.vad( ... % voice
			tts, run.audiorate, ...
			trial.soa, ...
			cfg.vad_freqband, cfg.vad_window );

		[~, ~, ~, sa] = k15.sad( va, stft, times, freqs, cfg.sad_subband ); % speech

			% set activity range
		astarts = find( diff( cat( 1, false, sa ) ) == 1 );
		astops = find( diff( cat( 1, sa, false ) ) == -1 );

		if ~isempty( astarts ) && ~isempty( astops ) % choose first active range, TODO: more sophisticated choice?!
			respdet.range(1) = trial.range(1) + times(astarts(1)) - stride/2;
			respdet.range(2) = trial.range(1) + times(astops(1)) + stride/2;
		end

		logger.progress( i, ntrials );
	end

		% exit
	logger.untab(); % stop logging

end

