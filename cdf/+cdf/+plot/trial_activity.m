function trial_activity( run, cfg, id, plotfile )
% plot trial activity detection specifics
%
% TRIAL_ACTIVITY( run, cfg, id, plotfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% id : trial indentifier (scalar numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( id ) || ~isnumeric( id ) || id < 1 || id > numel( run.trials )
		error( 'invalid argument: id' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot trial activity (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% plot
	fig = style.figure();

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

