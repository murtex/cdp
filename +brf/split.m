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

	if nargin < 4 || ~isscalar( nclasses ) || ~isnumeric( nclasses ) || nclasses < 1
		error( 'invalid argument: nclasses' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'grow node (samples: %d)...', size( features, 1 ) );

		% pre-computations
	nsamples = size( features, 1 );

	classinds = false( nclasses, nsamples ); % class indicators
	for i = 1:nclasses
		classinds(i, :) = labels == i;
	end

	trivial = 1; % trivial split impurity
	for i = 1:nclasses
		trivial = max( 0, trivial - (sum( classinds(i, :) ) / nsamples)^2 );
	end
	trivial = nsamples*trivial;

		% prepare node
	classoccs = sum( classinds, 2 ); % majority class label
	imax = find( classoccs == max( classoccs ) );
	if numel( imax ) > 1
		imax = randsample( imax, 1 ); % choose randomly
	end

	node.label = imax;

	if trivial == 0
		logger.untab();
		return;
	end

		% sample features for splitting
	nfeatures = size( features, 2 );

	fi = randi( nfeatures, 1, ceil( sqrt( nfeatures ) ) );
	nfis = numel( fi );

		% get best split for each feature
	splits = NaN( nfis, 3 ); % pre-allocation (impurity, feature, value)

	for i = 1:nfis

			% prepare splitting
		[fvals, order] = sort( features(:, fi(i)) ); % all possible splits

		labelset = labels(order); % check only splits w/ label change
		spliti = find( diff( labelset ) ~= 0 ) + 1;
		nsplits = numel( spliti );

		classoccs = cumsum( classinds(:, order), 2 ); % precompute class occupations

			% get split impurities
		impurities = NaN( nsplits + 1, 1 ); % pre-allocation

		for j = 1:nsplits
			nllabels = spliti(j) - 1; % number of child labels
			nrlabels = nsamples - nllabels;

			li = 1;
			ri = 1;
			for k = 1:nclasses
				li = max( 0, li - (classoccs(k, nllabels) / nllabels)^2 );
				ri = max( 0, ri - ((classoccs(k, end)-classoccs(k, nllabels)) / nrlabels)^2 );
			end

			impurities(j) = nllabels*li + nrlabels*ri;
		end

		impurities(end) = trivial; % append trivial split impurity

			% record split w/ minimum impurity
		imin = find( impurities == min( impurities ) );
		if numel( imin ) > 1
			imin = randsample( imin, 1 ); % choose randomly
		end

		if imin > nsplits
			splits(i, :) = [impurities(imin), fi(i), Inf]; % trivial split
		else
			splits(i, :) = [impurities(imin), fi(i), fvals(spliti(imin))];
		end

	end

		% set split w/ minimum impurity
	imin = find( splits(:, 1) == min( splits(:, 1) ) );
	if numel( imin ) > 1
		imin = randsample( imin, 1 ); % choose randomly
	end

	node.feature = splits(imin, 2); % set node
	node.value = splits(imin, 3);

		% split node recursively
	li = features(:, node.feature) < node.value; % proceed left child node
	if sum( li ) > 0
		node.left = brf.hNode();
		brf.split( node.left, features(li, :), labels(li), nclasses );
	end
	
	ri = ~li; % proceed right child node
	if sum( ri ) > 0
		node.right = brf.hNode();
		brf.split( node.right, features(ri, :), labels(ri), nclasses );
	end

	logger.untab();
end


