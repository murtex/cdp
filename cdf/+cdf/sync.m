function sync( run )
% sync timings
%
% SYNC( run )
%
% INPUT
% run : cue-distractor run (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'sync timings...' );

		% track sync start (initial tone)

	logger.untab();
end

