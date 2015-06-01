function landmark( run, detected, labeled, plotfile )
% plot landmark statistics
%
% LANDMARK( run, detected, labeled, plotfile )
%
% INPUT
% run : run (scalar object)
% detected : detected landmarks (matrix numeric)
% labeled : labeled landmarks (matrix numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~ismatrix( detected ) || ~isnumeric( detected )
		error( 'invalid argument: detected' );
	end

	if nargin < 3 || ~ismatrix( labeled ) || ~isnumeric( labeled ) || any( size( detected ) ~= size( labeled ) )
		error( 'invalid argument: labeled' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot landmark ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set burst-onset statistics
	maxdelta = sta.msec2smp( 15, run.audiorate ); % limit view to +/-15ms

	dbos = detected(:, 1) - labeled(:, 1); % data
	dbos(isnan( dbos )) = [];
	ndbos = numel( dbos );
	dbos(abs( dbos ) > maxdelta ) = [];
	absdbos = abs( dbos );

	dbopos = linspace( min( dbos ), max( dbos ), style.bins( dbos ) ); % binning
	dbons = hist( dbos, dbopos );
	absdbopos = linspace( min( absdbos ), max( absdbos ), style.bins( absdbos ) );
	absdbons = hist( absdbos, absdbopos );

		% set voice-onset statistics
	dvos = detected(:, 2) - labeled(:, 2); % data
	dvos(isnan( dvos )) = [];
	ndvos = numel( dvos );
	dvos(abs( dvos ) > maxdelta ) = [];
	absdvos = abs( dvos );

	dvopos = linspace( min( dvos ), max( dvos ), style.bins( dvos ) ); % binning
	dvons = hist( dvos, dvopos );
	absdvopos = linspace( min( absdvos ), max( absdvos ), style.bins( absdvos ) );
	absdvons = hist( absdvos, absdvopos );

		% set voice-release statistics
	dvrs = detected(:, 3) - labeled(:, 3); % data
	dvrs(isnan( dvrs )) = [];
	ndvrs = numel( dvrs );
	dvrs(abs( dvrs ) > maxdelta ) = [];
	absdvrs = abs( dvrs );

	dvrpos = linspace( min( dvrs ), max( dvrs ), style.bins( dvrs ) ); % binning
	dvrns = hist( dvrs, dvrpos );
	absdvrpos = linspace( min( absdvrs ), max( absdvrs ), style.bins( absdvrs ) );
	absdvrns = hist( absdvrs, absdvrpos );

		% plot burst-onset delta
	subplot( 3, 2, 1 );
	title( sprintf( 'trials: %d -- landmarks', size( detected, 1 ) ) );
	xlabel( 'burst-onset (+b) delta in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( maxdelta, run.audiorate ) * [-1, 1] );
	bar( sta.smp2msec( dbopos, run.audiorate ), dbons / ndbos, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 2 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, sta.smp2msec( maxdelta, run.audiorate )] );
	ylim( [0, 1] );
	h = bar( sta.smp2msec( absdbopos, run.audiorate ), cumsum( absdbons ) / ndbos, ...
		'DisplayName', sprintf( '%d', ndbos ), ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot voice-onset delta
	subplot( 3, 2, 3 );
	xlabel( 'voice-onset (+g) delta in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( maxdelta, run.audiorate ) * [-1, 1] );
	bar( sta.smp2msec( dvopos, run.audiorate ), dvons / ndvos, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 4 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, sta.smp2msec( maxdelta, run.audiorate )] );
	ylim( [0, 1] );
	h = bar( sta.smp2msec( absdvopos, run.audiorate ), cumsum( absdvons ) / ndvos, ...
		'DisplayName', sprintf( '%d', ndvos ), ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot voice-release deltas
	subplot( 3, 2, 5 );
	xlabel( 'voice-release (-g) delta in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( maxdelta, run.audiorate ) * [-1, 1] );
	bar( sta.smp2msec( dvrpos, run.audiorate ), dvrns / ndvrs, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	subplot( 3, 2, 6 );
	xlabel( 'abs(delta) in milliseconds' );
	ylabel( 'cumulative rate' );
	xlim( [0, sta.smp2msec( maxdelta, run.audiorate )] );
	ylim( [0, 1] );
	h = bar( sta.smp2msec( absdvrpos, run.audiorate ), cumsum( absdvrns ) / ndvrs, ...
		'DisplayName', sprintf( '%d', ndvrs ), ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	l = legend( h, 'Location', 'SouthEast' );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

	style.print( plotfile );
	delete( fig );
end

