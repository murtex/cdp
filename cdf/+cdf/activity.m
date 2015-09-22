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

		logger.progress( i, ntrials );
	end

		% done
	logger.untab();

end

