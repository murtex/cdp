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

		% prepare activity ranges
	maxdelta = 80; % limit view to +/-80ms
	maxoverlap = 2; % limit two 200% overlap

	detrs = cat( 1, run.resps_det.range );
	labrs = cat( 1, run.resps_lab.range );

		% detection start statistics
	dstarts = 1000 * (detrs(:, 1) - labrs(:, 1)); % data
	dstarts(isnan( dstarts )) = [];
	ndstarts = numel( dstarts );
	dstarts(abs( dstarts ) > maxdelta) = [];
	absdstarts = abs( dstarts );

	dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) ); % binning
	dstartns = hist( dstarts, dstartpos );
	absdstartpos = linspace( min( absdstarts ), max( absdstarts ), style.bins( absdstarts ) );
	absdstartns = hist( absdstarts, absdstartpos );

		% detection stop statistics
	dstops = 1000 * (detrs(:, 2) - labrs(:, 2)); % data
	dstops(isnan( dstops )) = [];
	ndstops = numel( dstops );
	dstops(abs( dstops ) > maxdelta) = [];
	absdstops = abs( dstops );

	dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) ); % binning
	dstopns = hist( dstops, dstoppos );
	absdstoppos = linspace( min( absdstops ), max( absdstops ), style.bins( absdstops ) );
	absdstopns = hist( absdstops, absdstoppos );

		% detection overlap statistics
	overlaps = NaN( size( detrs, 1 ), 1 ); % data
	for i = 1:numel( overlaps )
		if any( isnan( detrs(i, :) ) ) || any( isnan( labrs(i, :) ) )
			continue;
		end

		if detrs(i, 2) < labrs(i, 1) || detrs(i, 1) > labrs(i, 2) % outside
			overlaps(i) = 0;
		elseif detrs(i, 1) >= labrs(i, 1) && detrs(i, 2) <= labrs(i, 2) % inside
			overlaps(i) = diff( detrs(i, :) ) / diff( labrs(i, :) );
		elseif detrs(i, 1) < labrs(i, 1) && detrs(i, 2) > labrs(i, 2) % complete
			overlaps(i) = diff( detrs(i, :) ) / diff( labrs(i, :) );
		elseif detrs(i, 2) < labrs(i, 2)
			overlaps(i) = (detrs(i, 2)-labrs(i, 1)) / diff( labrs(i, :) );
		else
			overlaps(i) = (labrs(i, 2)-detrs(i, 1)) / diff( labrs(i, :) );
		end
	end
	overlaps(isnan( overlaps )) = [];
	noverlaps = numel( overlaps );
	overlaps(overlaps < 0 | overlaps > maxoverlap) = [];

	overlappos = linspace( min( overlaps ), max( overlaps ), style.bins( overlaps ) ); % binning
	overlapns = hist( overlaps, overlappos );

		% plot
	fig = style.figure();

	subplot( 3, 2, 1 ); % detection starts
	title( ...
		sprintf( 'start deltas: %d/%d', ...
		ndstarts, sum( ~isnan( labrs(:, 1) ) ) ) );
	xlabel( 'start delta in milliseconds' );
	ylabel( 'rate' );
	xlim( maxdelta * [-1, 1] );
	bar( dstartpos, dstartns / ndstarts, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 2 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, maxdelta] );
	ylim( [0, 1] );
	bar( absdstartpos, cumsum( absdstartns ) / ndstarts, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 3 ); % detection stops
	title( ...
		sprintf( 'stop deltas: %d/%d', ...
		ndstops, sum( ~isnan( labrs(:, 2) ) ) ) );
	xlabel( 'stop delta in milliseconds' );
	ylabel( 'rate' );
	xlim( maxdelta * [-1, 1] );
	bar( dstoppos, dstopns / ndstops, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 4 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, maxdelta] );
	ylim( [0, 1] );
	bar( absdstoppos, cumsum( absdstopns ) / ndstops, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, [5, 6] ); % detection overlaps
	title( ...
		sprintf( 'overlaps: %d/%d', ...
		noverlaps, min( ndstarts, ndstops ) ) );
	xlabel( 'overlap' );
	ylabel( 'rate' );
	xlim( [0, maxoverlap] );
	bar( overlappos, overlapns / noverlaps, ...
		'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

