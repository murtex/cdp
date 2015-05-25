function forest = train( features, labels, nclasses, ntrees, logoob )
% grow forest
%
% forest = TRAIN( features, labels, nclasses, ntrees, logoob )
%
% INPUT
% features : feature matrix (matrix numeric)
% labels : sample labels (row numeric)
% nclasses : number of classes (scalar numeric)
% ntrees : number of trees (scalar numeric)
% logoob : oob-error logging flag (scalar logical)
%
% OUTPUT
% forest : tree root nodes (row struct)

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

	if nargin < 5 || ~isscalar( logoob ) || ~islogical( logoob )
		error( 'invalid argument: logoob' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'grow forest...' );

		% grow trees
	nfeatures = size( features, 2 );
	nsamples = size( features, 1 );

	logger.log( 'classes: %d', nclasses );
	logger.log( 'features: %d', nfeatures );
	logger.log( 'samples: %d', nsamples );

	forest = struct( ... % pre-allocation
		'labels', NaN, ...
		'impurities', NaN, ...
		'features', NaN, ...
		'values', NaN, ...
		'lefts', NaN, ...
		'rights', NaN );
	forest = repmat( forest, 1, ntrees );

	for i = 1:ntrees
		logger.tab( 'grow tree %d/%d...', i, ntrees );

			% bootstrap samples
		bagi = randsample( nsamples, nsamples, true );
		oobi = setdiff( 1:nsamples, bagi );

			% grow tree from root
		hiermax = logger.hierarchymax;
		logger.hierarchymax = logger.hierarchy + 2; % limit logging depth

		forest(i) = brf.split( forest(i), features(bagi, :), labels(bagi), nclasses, 1 );

		logger.hierarchymax = hiermax; % restore logging depth

			% log statistics
		logger.log( 'nodes: %d', numel( forest(i).labels ) );

		logger.untab();
	end

	logger.untab();
end

