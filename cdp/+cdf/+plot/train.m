function train( forest, plotfile )
% plot feature importance
%
% TRAIN( forest, plotfile )
%
% INPUT
% forest : trees (row struct)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( forest ) % no type check!
		error( 'invalid argument: forest' );
	end

	if nargin < 2 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot training ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set feature importance
	ntrees = numel( forest );

	nfeatures = NaN;
	for i = 1:ntrees
		nfeatures = max( nfeatures, max( forest(i).features ) );
	end

	fgains = zeros( 1, nfeatures ); % pre-allocation
	for i = 1:ntrees
		for j = 1:nfeatures
			fgains(j) = fgains(j) + sum( forest(i).gains(forest(i).features == j) );
		end
	end

		% plot feature importance
	title( sprintf( 'trees: %d, features: %d -- training', ntrees, nfeatures ) );
	xlabel( 'feature index' );
	ylabel( 'importance (gini gain)' );

	xlim( [1, nfeatures] );

	bar( 1:nfeatures, fgains, ...
		'BarWidth', style.width( -1 ), 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', style.color( 'neutral', -2 ) );

	style.print( plotfile );
	delete( fig );
end

