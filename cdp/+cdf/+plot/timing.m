function timing( run, detected, labeled, plotfile )
% plot timing statistics
%
% TIMING( run, detected, labeled, plotfile )
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

	if nargin < 3 || ~ismatrix( labeled ) || ~isnumeric( labeled )
		error( 'invalid argument: labeled' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot timing ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set voice-onset time statistics
	detvots = detected(:, 2) - detected(:, 1);
	detvots(isnan( detvots )) = [];
	ndetvots = numel( detvots );
	detvotpos = linspace( min( detvots ), max( detvots ), style.bins( detvots ) );
	detvotns = hist( detvots, detvotpos );

	if ~isempty( labeled )
		labvots = labeled(:, 2) - labeled(:, 1);
		labvots(isnan( labvots )) = [];
		nlabvots = numel( labvots );
		labvotpos = linspace( min( labvots ), max( labvots ), style.bins( labvots ) );
		labvotns = hist( labvots, labvotpos );
	end

		% set vowel length statistics
	detvows = detected(:, 3) - detected(:, 2);
	detvows(isnan( detvows )) = [];
	ndetvows = numel( detvows );
	detvowpos = linspace( min( detvows ), max( detvows ), style.bins( detvows ) );
	detvowns = hist( detvows, detvowpos );

	if ~isempty( labeled )
		labvows = labeled(:, 3) - labeled(:, 2);
		labvows(isnan( labvows )) = [];
		nlabvows = numel( labvows );
		labvowpos = linspace( min( labvows ), max( labvows ), style.bins( labvows ) );
		labvowns = hist( labvows, labvowpos );
	end

		% set syllable length statistics
	detsyls = detected(:, 3) - detected(:, 1);
	detsyls(isnan( detsyls )) = [];
	ndetsyls = numel( detsyls );
	detsylpos = linspace( min( detsyls ), max( detsyls ), style.bins( detsyls ) );
	detsylns = hist( detsyls, detsylpos );

	if ~isempty( labeled )
		labsyls = labeled(:, 3) - labeled(:, 1);
		labsyls(isnan( labsyls )) = [];
		nlabsyls = numel( labsyls );
		labsylpos = linspace( min( labsyls ), max( labsyls ), style.bins( labsyls ) );
		labsylns = hist( labsyls, labsylpos );
	end

		% prepare plot
	xlvot = [min( detvots ), max( detvots )]; % axes
	if ~isempty( labeled )
		xlvot = [min( xlvot(1), min( labvots ) ), max( xlvot(2), max( labvots ) )];
	end
	xlvow = [min( detvows ), max( detvows )];
	if ~isempty( labeled )
		xlvow = [min( xlvow(1), min( labvows ) ), max( xlvow(2), max( labvows ) )];
	end
	xlsyl = [min( detsyls ), max( detsyls )];
	if ~isempty( labeled )
		xlsyl = [min( xlsyl(1), min( labsyls ) ), max( xlsyl(2), max( labsyls ) )];
	end

		% plot voice-onset time
	if ~isempty( labeled )
		subplot( 3, 2, 1 );
	else
		subplot( 3, 1, 1 );
	end
	title( sprintf( 'trials: %d -- timing', size( detected, 1 ) ) );
	xlabel( 'voice-onset time (detected) in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( xlvot, run.audiorate ) );
	bar( sta.smp2msec( detvotpos, run.audiorate ), detvotns / ndetvots, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	if ~isempty( labeled )
		subplot( 3, 2, 2 );
		xlabel( 'voice-onset time (labeled) in milliseconds' );
		ylabel( 'rate' );
		xlim( sta.smp2msec( xlvot, run.audiorate ) );
		bar( sta.smp2msec( labvotpos, run.audiorate ), labvotns / nlabvots, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
	end

		% plot vowel length
	if ~isempty( labeled )
		subplot( 3, 2, 3 );
	else
		subplot( 3, 1, 2 );
	end
	xlabel( 'vowel length (detected) in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( xlvow, run.audiorate ) );
	bar( sta.smp2msec( detvowpos, run.audiorate ), detvowns / ndetvows, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	if ~isempty( labeled )
		subplot( 3, 2, 4 );
		xlabel( 'vowel length (labeled) in milliseconds' );
		ylabel( 'rate' );
		xlim( sta.smp2msec( xlvow, run.audiorate ) );
		bar( sta.smp2msec( labvowpos, run.audiorate ), labvowns / nlabvows, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
	end

		% plot syllable length
	if ~isempty( labeled )
		subplot( 3, 2, 5 );
	else
		subplot( 3, 1, 3 );
	end
	xlabel( 'syllable length (detected) in milliseconds' );
	ylabel( 'rate' );
	xlim( sta.smp2msec( xlsyl, run.audiorate ) );
	bar( sta.smp2msec( detsylpos, run.audiorate ), detsylns / ndetsyls, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	if ~isempty( labeled )
		subplot( 3, 2, 6 );
		xlabel( 'syllable length (labeled) in milliseconds' );
		ylabel( 'rate' );
		xlim( sta.smp2msec( xlsyl, run.audiorate ) );
		bar( sta.smp2msec( labsylpos, run.audiorate ), labsylns / nlabsyls, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
	end

	style.print( plotfile );
	delete( fig );
end

