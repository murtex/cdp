function activity( run, cfg )
% activity detction
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
	
		% helper functions
	function f = is_valid( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if any( isnan( trials(i).range ) )
				f(i) = false;
			end
		end
	end

		% proceed (valid) trials
	trials = [run.trials]; % prepare valid trials
	
	invalids = ~is_valid( trials );
	trials(invalids) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	logger.progress();
	for i = 1:ntrials

			% prepare data
		trial = trials(i);
		respdet = trial.respdet;

		tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges

		tts = run.audiodata(tr(1):tr(2), 1); % signals

			% detect activity

		logger.progress( i, ntrials );
	end

		% exit
	logger.untab(); % stop logging

end

