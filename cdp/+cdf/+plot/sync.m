function sync( run, offs, plotfile )
% plot marker offsets
%
% SYNC( run, offs, plotfile )
%
% INPUT
% run : run (scalar object)
% offs : marker offsets (row numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( offs ) || ~isnumeric( offs ) || numel( offs ) ~= numel( run.trials )
		error( 'invalid argument: offs' );
	end

	if nargin < 3 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot sync ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% plot
	title( sprintf( '[sync] id: %d, trials: %d', run.id, numel( run.trials ) ) );
	xlabel( 'detected marker position in seconds' );
	ylabel( 'marker offset in milliseconds' );

	xlim( sta.smp2sec( [1, run.audiolen]-1, run.audiorate ) );

	h = scatter( sta.smp2sec( [run.trials.cue], run.audiorate ), sta.smp2msec( offs, run.audiorate ), ...
		'DisplayName', sprintf( '%d', sum( ~isnan( offs ) ) ), ...
		'Marker', '+', 'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', style.color( 'warm', 0 ) );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% print
	style.print( plotfile );

		% clean-up
	delete( fig );

end

