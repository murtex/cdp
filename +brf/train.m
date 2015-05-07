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

	for i = 1:ntrees

			% bootstrap samples
		bi = randsample( nsamples, nsamples, true );

			% grow tree from root node
		root = brf.hNode();

		brf.split( root, features(bi, :), labels(bi), nclasses );

	end

	logger.untab();
end

