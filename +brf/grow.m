function grow( node, features, labels, nclasses )
% grow tree
%
% GROW( node, features, labels, nclasses )
%
% INPUT
% node : tree node (scalar object)
% features : feature matrix (matrix numeric)
% labels : sample labels (row numeric)
% nclasses : number of classes (scalar numeric)

		% safeguard
	if nargin < 1 || ~isscalar( node ) || ~isa( node, 'brf.hNode' )
		error( 'invalid argument: node' );
	end

	if nargin < 2 || ~ismatrix( features ) || ~isnumeric( features )
		error( 'invalid argument: features' );
	end

	if nargin < 3 || ~isrow( labels ) || ~isnumeric( labels ) || numel( labels ) ~= size( features, 1 )
		error( 'invalid arguments: labels' );
	end

	if nargin < 4 || ~isscalar( nclasses ) || ~isnumeric( nclasses )
		error( 'invalid argument: nclasses' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'grow tree...' );

		% sample features
	nsamples = size( features, 1 );
	nfeatures = size( features, 2 );

	fi = randi( nfeatures, 1, ceil( sqrt( nfeatures ) ) );

	logger.log( 'samples: %d', nsamples );

		% find best splits
	nfis = numel( fi );

	splits = NaN( 0, 3 ); % pre-allocation (impurity, feature, value )

	logger.progress( 'find best split...' );
	for i = 1:nfis

			% set split impurities
		[fvals, order] = sort( features(:, fi(i)) ); % all possible splits
		labelset = labels(order);

		labelchange = diff( labelset ); % reduce to splits w/ label change
		labelspliti = find( labelchange ~= 0 ) + 1;

		nsplits = numel( labelspliti ); % pre-allocation
		imps = NaN( 1, 1 + nsplits );

		for j = 1:nsplits

				% split set of labels
			llabelset = labelset(1:labelspliti(j)-1);
			rlabelset = labelset(labelspliti(j):end);

				% compute impurity
			imps(j) = numel( llabelset ) * brf.gini( llabelset, nclasses ) + ...
				numel( rlabelset ) * brf.gini( rlabelset, nclasses );

		end
		imps(end) = nsamples*brf.gini( labelset, nclasses );

			% store split w/ minimum impurity
		impmin = min( imps );
		impmini = find( imps == impmin );
		if numel( impmini ) > 1
			impmini = randsample( impmini, 1 ); % choose random minimum
		end

		if impmini > nsplits
			splits(end+1, :) = [impmin, fi(i), Inf]; % full left node, empty right node
		else
			splits(end+1, :) = [impmin, fi(i), fvals(labelspliti(impmini))];
		end

		logger.progress( i, nfis );
	end

		% choose split w/ minimum impurity
	splitimpmin = min( splits(:, 1) );
	splitimpmini = find( splits(:, 1) == splitimpmin );
	if numel( splitimpmini ) > 1
		splitimpmini = randsample( splitimpmini, 1 ); % choose random minimum
	end

	splitimp = splits(splitimpmini, 1); % set split
	splitfi = splits(splitimpmini, 2);
	splitfval = splits(splitimpmini, 3);

	logger.log( 'feature: %d (value: %f)', splitfi, splitfval );
	logger.log( 'impurity: %f', splitimp );

		% split node and continue recursively
	node.impurity = splitimp;

	if node.impurity > 0

			% left node
		li = features(:, splitfi) < splitfval;
		if sum( li ) > 0
			node.left = brf.hNode();
			brf.grow( node.left, features(li, :), labels(li), nclasses );
		end
		
			% right node
		ri = ~li;
		if sum( ri ) > 0
			node.right = brf.hNode();
			brf.grow( node.right, features(ri, :), labels(ri), nclasses );
		end

	end

	logger.untab();
end


