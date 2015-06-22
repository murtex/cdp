function sync( run, sync0, syncs, plotfile )
% plot sync offsets
%
% SYNC( run, sync0, syncs, plotfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% sync0 : sync start offset (scalar numeric)
% syncs : sync marker offsets (row numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( sync0 ) || ~isnumeric( sync0 )
		error( 'invalid argument: sync0' );
	end

	if nargin < 3 || ~isrow( syncs ) || ~isnumeric( syncs ) || numel( syncs ) ~= numel( run.trials )
		error( 'invalid argument: syncs' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot syncs (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% plot
	fig = style.figure();

	title( ...
		sprintf( 'sync start: %.1fms, sync markers: %d/%d', ...
		1000 * sync0, ...
		sum( ~isnan( syncs ) ), numel( run.trials ) ) );

	xlabel( 'marker position in seconds' );
	ylabel( 'marker offset in milliseconds' );

	xlim( [0, dsp.smp2sec( run.audiosize(1), run.audiorate)] );

	scatter( [run.trials.cue], 1000 * syncs, ...
		'Marker', '+', ...
		'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', style.color( 'warm', 0 ) );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

