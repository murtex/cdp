function activity( run, cfg, plotfile )
% plot voice activity detection statistics
%
% ACTIVITY( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot activity statistics (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% detection start statistics
	maxdelta = 200; % limit view to +/-200ms

	dstarts = 1000 * ([run.resps_det.startpos] - [run.resps_lab.startpos]); % data
	dstarts(isnan( dstarts )) = [];
	ndstarts = numel( dstarts );
	dstarts(abs( dstarts ) > maxdelta) = [];

	dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) ); % binning
	dstartns = hist( dstarts, dstartpos );

		% detection stop statistics
	dstops = 1000 * ([run.resps_det.stoppos] - [run.resps_lab.stoppos]); % data
	dstops(isnan( dstops )) = [];
	ndstops = numel( dstops );
	dstops(abs( dstops ) > maxdelta) = [];

	dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) ); % binning
	dstopns = hist( dstops, dstoppos );

		% plot
	style.figure();

	subplot( 3, 1, 1 ); % detection starts
	title( ...
		sprintf( 'start deltas: %d/%d, stop deltas: %d/%d', ...
		ndstarts, sum( ~isnan( [run.resps_lab.startpos] ) ), ...
		ndstops, sum( ~isnan( [run.resps_lab.stoppos] ) ) ) );
	xlabel( 'start delta in milliseconds' );
	ylabel( 'rate' );
	xlim( maxdelta * [-1, 1] );
	bar( dstartpos, dstartns / ndstarts, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', +1 ), 'EdgeColor', 'none' );

	subplot( 3, 1, 2 ); % detection stops
	xlabel( 'stop delta in milliseconds' );
	ylabel( 'rate' );
	xlim( maxdelta * [-1, 1] );
	bar( dstoppos, dstopns / ndstops, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', +1 ), 'EdgeColor', 'none' );

		% print
	style.print( plotfile );

	logger.untab();
end

