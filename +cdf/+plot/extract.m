function extract( run, detected, labeled, plotfile )
% plot extraction range statistics
%
% EXTRACT( detected, labeled, plotfile )
%
% INPUT
% detected : detected ranges (matrix numeric)
% labeled : labeled ranged (matrix numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~ismatrix( detected ) || ~isnumeric( detected )
		error( 'invalid argument: detected' );
	end

	if nargin < 2 || ~ismatrix( labeled ) || ~isnumeric( labeled ) || any( size( detected ) ~= size( labeled ) )
		error( 'invalid argument: labeled' );
	end

	if nargin < 3 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot extraction ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set start statistics
	maxdelta = dsp.msec2smp( 80, run.audiorate ); % limit view to +/-80ms

	dstarts = detected(:, 1) - labeled(:, 1); % data
	dstarts(isnan( dstarts )) = [];
	ndstarts = numel( dstarts );
	dstarts(abs( dstarts ) > maxdelta ) = [];
	absdstarts = abs( dstarts );

	dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) ); % binning
	dstartns = hist( dstarts, dstartpos );
	absdstartpos = linspace( min( absdstarts ), max( absdstarts ), style.bins( absdstarts ) );
	absdstartns = hist( absdstarts, absdstartpos );

		% set stop statistics
	dstops = detected(:, 2) - labeled(:, 2); % data
	dstops(isnan( dstops )) = [];
	ndstops = numel( dstops );
	dstops(abs( dstops ) > maxdelta ) = [];
	absdstops = abs( dstops );

	dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) ); % binning
	dstopns = hist( dstops, dstoppos );
	absdstoppos = linspace( min( absdstops ), max( absdstops ), style.bins( absdstops ) );
	absdstopns = hist( absdstops, absdstoppos );

		% set overlap statistics
	maxoverlap = 2; % limit view to 200% overlap

	overlaps = []; % data pre-allocation
	n = size( detected, 1 );
	for i = 1:n
		if ~any( isnan( detected(i, :) ) ) && ~any( isnan( labeled(i, :) ) )
			rdetected = detected(i, 1):detected(i, 2);
			rlabeled = labeled(i, 1):labeled(i, 2);
			roverlap = intersect( rdetected, rlabeled );

			if ~isempty( roverlap )
				if numel( roverlap ) == numel( rlabeled ) % complete overlap
					overlaps(end+1) = numel( rdetected ) / numel( rlabeled );
				else % partial overlap
					overlaps(end+1) = numel( roverlap ) / numel( rlabeled );
				end
			else % no overlap
				overlaps(end+1) = 0;
			end
		end
	end
	noverlaps = numel( overlaps );
	overlaps(overlaps > maxoverlap) = [];
	
	overlappos = linspace( min( overlaps ), max( overlaps ), style.bins( overlaps ) ); % binning
	overlapns = hist( overlaps, overlappos );

		% plot start deltas
	subplot( 3, 2, 1 );
	title( sprintf( 'trials: %d -- extraction', size( detected, 1 ) ) );
	xlabel( 'start delta in milliseconds' );
	ylabel( 'rate' );
	xlim( dsp.smp2msec( maxdelta, run.audiorate ) * [-1, 1] );
	bar( dsp.smp2msec( dstartpos, run.audiorate ), dstartns / ndstarts, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 2 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, dsp.smp2msec( maxdelta, run.audiorate )] );
	ylim( [0, 1] );
	h = bar( dsp.smp2msec( absdstartpos, run.audiorate ), cumsum( absdstartns ) / ndstarts, ...
		'DisplayName', sprintf( '%d', ndstarts ), ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot stop deltas
	subplot( 3, 2, 3 );
	xlabel( 'stop delta in milliseconds' );
	ylabel( 'rate' );
	xlim( dsp.smp2msec( maxdelta, run.audiorate ) * [-1, 1] );
	bar( dsp.smp2msec( dstoppos, run.audiorate ), dstopns / ndstops, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 4 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, dsp.smp2msec( maxdelta, run.audiorate )] );
	ylim( [0, 1] );
	h = bar( dsp.smp2msec( absdstoppos, run.audiorate ), cumsum( absdstopns ) / ndstops, ...
		'DisplayName', sprintf( '%d', ndstops ), ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot overlaps
	subplot( 3, 2, 5:6 );
	xlabel( 'overlap' );
	ylabel( 'rate' );
	xlim( [0, maxoverlap] );
	bar( overlappos, overlapns / noverlaps, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	style.print( plotfile );
	delete( fig );
end

