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
	%if nargin < 1 || ~isscalar( node ) || ~isa( node, 'brf.hNode' )
		%error( 'invalid argument: node' );
	%end

	%if nargin < 2 || ~ismatrix( features ) || ~isnumeric( features )
		%error( 'invalid argument: features' );
	%end

	%if nargin < 3 || ~isrow( labels ) || ~isnumeric( labels ) || numel( labels ) ~= size( features, 1 )
		%error( 'invalid arguments: labels' );
	%end

	%if nargin < 4 || ~isscalar( nclasses ) || ~isnumeric( nclasses ) || nclasses < 1
		%error( 'invalid argument: nclasses' );
	%end

	%logger = xis.hLogger.instance();
	%logger.tab( 'grow node (samples: %d)...', size( features, 1 ) );

		% mex preparation
	persistent mexified;

	if isempty( mexified )

			% get current module path
		[st, i] = dbstack( '-completenames' );
		[path, ~, ~] = fileparts( st(i).file );

			% compile mex-source
		src = fullfile( path, 'split_imp_mex.cpp' );
		ret = mex( src, '-outdir', path );

		mexified = ~ret;
	end

		% pre-computations
	nsamples = size( features, 1 );

	classinds = false( nclasses, nsamples ); % class indicators
	for i = 1:nclasses
		classinds(i, :) = labels == i;
	end

		% sample split features
	nfeatures = size( features, 2 );

	fis = randi( nfeatures, 1, ceil( sqrt( nfeatures ) ) );
	nfis = numel( fis );

		% set split properties
	simps = NaN( nfis, 1 ); % pre-allocation
	svals = zeros( nfis, 1 );

	for i = 1:nfis

			% prepare split values to check
		[fvals, order] = sort( features(:, fis(i)) ); % all possible split values

		vis = find( diff( labels(order) ) ~= 0 ) + 1; % value indices with label change
		nvis = numel( vis );

			% get split impurities
		if mexified
			fsimps = brf.split_imp_mex( cumsum( classinds(:, order), 2 ), vis );
		else
			fsimps = brf.split_imp( cumsum( classinds(:, order), 2 ), vis );
		end

			% choose split with lowest impurity
		si = find( fsimps == min( fsimps ) );
		if numel( si ) > 1
			si = randsample( si, 1 ); % choose random minimum
		end

		if ~isempty( si )
			simps(i) = fsimps(si);
			svals(i) = fvals(vis(si));
		end

	end

		% choose split with lowest impurity
	si = find( simps == min( simps ) );
	if numel( si ) > 1
		si = randsample( si, 1 ); % choose random minimum
	end

		% split node recursively
	if ~isempty( si )

			% update current node
		node.feature = fis(si);
		node.value = svals(si);

			% proceed left child
		lsamples = features(:, node.feature) < node.value;
		nlsamples = sum( lsamples );

		if nlsamples > 0

				% prepare child node
			node.left = brf.hNode();

			occs = sum( classinds(:, lsamples), 2 );
			label = find( occs == max( occs ) );
			if numel( label ) > 1
				label = randsample( label, 1 );
			end
			node.left.label = label;

			node.left.impurity = 1;
			for i = 1:nclasses
				node.left.impurity = node.left.impurity - (occs(i) / nlsamples)^2;
			end

				% proceed non-uniform child node
			if sum( occs ~= 0 ) > 1
				brf.split( node.left, features(lsamples, :), labels(lsamples), nclasses );
			end

		end

			% proceed right child
		rsamples = ~lsamples;
		nrsamples = nsamples - nlsamples;

		if nrsamples > 0

				% prepare child node
			node.right = brf.hNode();

			occs = sum( classinds(:, rsamples), 2 );
			label = find( occs == max( occs ) );
			if numel( label ) > 1
				label = randsample( label, 1 );
			end
			node.right.label = label;

			node.right.impurity = 1;
			for i = 1:nclasses
				node.right.impurity = node.right.impurity - (occs(i) / nrsamples)^2;
			end

				% proceed non-uniform child node
			if sum( occs ~= 0 ) > 1
				brf.split( node.right, features(rsamples, :), labels(rsamples), nclasses );
			end

		end

	end

	%logger.untab();
end

