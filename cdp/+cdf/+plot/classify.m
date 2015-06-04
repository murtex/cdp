function classify( hits, misses, plotfile )
% plot classification errors
%
% CLASSIFY( hits, misses, plotfile )
%
% INPUT
% hits : cumulative hits (matrix numeric)
% misses : cumulative misses (matrix numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~ismatrix( hits ) || ~isnumeric( hits )
		error( 'invalid argument: hits' );
	end

	if nargin < 2 || ~ismatrix( misses ) || ~isnumeric( misses ) || any( size( misses ) ~= size( hits ) )
		error( 'invalid argument: misses' );
	end

	if nargin < 3 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot classification ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

	ntrees = size( hits, 1 );
	nclasses = size( hits, 2 );

		% plot
	title( sprintf( 'TODO' ) );
	xlabel( 'number of trees' );
	ylabel( 'classification error' );

	xlim( [1, ntrees] );

	for i = 1:nclasses
		stairs( (1:ntrees) - 0.5, misses(:, i) ./ (hits(:, i) + misses(:, i)), ...
			'DisplayName', sprintf( 'class #%d', i ) );
	end

	stairs( (1:ntrees) - 0.5, sum( misses, 2 ) ./ sum( hits + misses, 2 ), ...
		'DisplayName', 'overall' );

	legend( 'Location', 'NorthEast' );

	style.print( plotfile );
	delete( fig );
end

