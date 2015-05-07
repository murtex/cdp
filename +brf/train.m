function train( features, labels, nclasses, ntrees )
% grow forest
%
% TRAIN( features, labels )
%
% INPUT
% features : feature matrix (matrix numeric)
% labels : sample labels (row numeric)
% nclasses : number of classes (scalar numeric)
% ntrees : number of trees (scalar numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( features ) || ~isnumeric( features )
		error( 'invalid argument: features' );
	end

	if nargin < 2 || ~isrow( labels ) || ~isnumeric( labels ) || numel( labels ) ~= size( features, 1 )
		error( 'invalid arguments: labels' );
	end

	if nargin < 3 || ~isscalar( nclasses ) || ~isnumeric( nclasses )
		error( 'invalid argument: nclasses' );
	end

	if nargin < 4 || ~isscalar( ntrees ) || ~isnumeric( ntrees )
		error( 'invalid argument: ntrees' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'grow forest...' );

		% grow trees
	nfeatures = size( features, 2 );
	nsamples = size( features, 1 );

	logger.log( 'classes: %d', nclasses );
	logger.log( 'features: %d', nfeatures );
	logger.log( 'samples: %d', nsamples );

	roots(1, ntrees) = brf.hNode();

	for i = 1:ntrees
		logger.tab( 'grow tree %d/%d...', i, ntrees );

			% bootstrap aggregation
		bagi = randsample( nsamples, nsamples, true );
		oobi = setdiff( 1:nsamples, bagi );

			% grow tree from root node
		hiermax = logger.hierarchymax;
		logger.hierarchymax = logger.hierarchy + 1; % limit logging depth

		roots(i) = brf.hNode(); % grow tree
		brf.split( roots(i), features(bagi, :), labels(bagi), nclasses );

		logger.hierarchymax = hiermax; % restore logging depth

			% test tree and present forest
		[treelabels, treeerrs] = brf.classify( roots(i), features(oobi, :) ); % tree error
		labels(oobi) % DEBUG

		[forestlabels, foresterrs] = brf.classify( roots(1:i), features(oobi, :) ); % forest error
		labels(oobi) % DEBUG

		logger.log( 'tree error: %.6f', NaN );
		logger.log( 'forest error: %.6f', NaN );

		logger.untab();
	end

	logger.untab();
end

