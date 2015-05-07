function split( node, features, labels, nclasses )
% split tree node recursively
%
% SPLIT( node, features, labels, nclasses )
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
	logger.tab( 'split node (samples: %d)...', size( features, 1 ) );

		% sample features
	nsamples = size( features, 1 );
	nfeatures = size( features, 2 );

	fi = randi( nfeatures, 1, ceil( sqrt( nfeatures ) ) );

		% find best splits
	nfis = numel( fi );

	splits = NaN( nfis, 3 ); % pre-allocation (impurity, feature, value)

	for i = 1:nfis

			% prepare splitting
		[fvals, order] = sort( features(:, fi(i)) ); % all possible splits
		labelset = labels(order); % ordered set of labels

		spliti = find( diff( labelset ) ~= 0 ) + 1; % splits w/ label change
		nsplits = numel( spliti );

			% set split gini impurities
		imps = NaN( 1, 1 + nsplits ); % pre-allocation

		classinds = false( nclasses, nsamples ); % precompute class indications
		for j = 1:nclasses
			classinds(j, :) = labelset == j;
		end
		classinds = cumsum( classinds, 2 );

		for j = 1:nsplits
			nllabels = spliti(j) - 1; % number of child labels
			nrlabels = nsamples - nllabels;

			li = 1;
			ri = 1;
			for k = 1:nclasses
				li = li - (classinds(k, nllabels) / nllabels)^2;
				ri = ri - ((classinds(k, end)-classinds(k, nllabels)) / nrlabels)^2;
			end

			imps(j) = nllabels*li + nrlabels*ri;
		end

			% set none-split gini impurity
		ni = 1;
		for j = 1:nclasses
			ni = ni - (classinds(j, end) / nsamples)^2;
		end

		imps(end) = nsamples*ni;

			% store split w/ minimum impurity
		impmin = min( imps );
		impmini = find( imps == impmin );
		if numel( impmini ) > 1
			impmini = randsample( impmini, 1 ); % choose random minimum
		end

		if impmini > nsplits
			splits(i, :) = [impmin, fi(i), Inf]; % full left node, empty right node
		else
			splits(i, :) = [impmin, fi(i), fvals(spliti(impmini))];
		end

	end

		% choose split w/ minimum impurity
	splitimpmin = min( splits(:, 1) );
	splitimpmini = find( splits(:, 1) == splitimpmin );
	if numel( splitimpmini ) > 1
		splitimpmini = randsample( splitimpmini, 1 ); % choose random minimum
	end

	node.impurity = splits(splitimpmini, 1); % set split
	node.feature = splits(splitimpmini, 2);
	node.value = splits(splitimpmini, 3);

	logger.log( 'impurity: %.3f', node.impurity );

		% split node recursively
	if node.impurity > 0

			% left node
		li = features(:, node.feature) < node.value;
		if sum( li ) > 0
			node.left = brf.hNode();
			brf.split( node.left, features(li, :), labels(li), nclasses );
		end
		
			% right node
		ri = ~li;
		if sum( ri ) > 0
			node.right = brf.hNode();
			brf.split( node.right, features(ri, :), labels(ri), nclasses );
		end

	end

	logger.untab();
end


