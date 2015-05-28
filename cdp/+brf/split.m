function tree = split( tree, features, labels, nclasses, curnode, curdepth )
% grow tree recursively
%
% SPLIT( tree, features, labels, nclasses, curnode, curdepth )
%
% INPUT
% tree : tree (scalar struct)
% features : feature matrix (matrix numeric)
% labels : sample labels (row numeric)
% nclasses : number of classes (scalar numeric)
% curnode : current node index (scalar numeric)
% curdepth : current tree depth (scalar numeric)
%
% OUTPUT
% tree : tree (scalar struct)

		% safeguard
	%if nargin < 1 || ~isscalar( tree ) || ~isstruct( tree )
		%error( 'invalid argument: tree' );
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

	%if nargin < 5 || ~isscalar( curnode ) || ~isnumeric( curnode )
		%error( 'invalid argument: curnode' );
	%end

	%if nargin < 6 || ~isscalar( curdepth ) || ~isnumeric( curdepth )
		%error( 'invalid argument: curdepth' );
	%end

	%logger = xis.hLogger.instance();
	%logger.tab( 'split node...' );

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

		% prepare current node
	nsamples = size( features, 1 );

	tree.depths(curnode) = curdepth;

	classinds = false( nclasses, nsamples ); % class indicators
	for i = 1:nclasses
		classinds(i, :) = labels == i;
	end

	occs = sum( classinds, 2 ); % majority vote
	label = find( occs == max( occs ) );
	if numel( label ) > 1
		label = randsample( label, 1 ); % random majority
	end
	tree.labels(curnode) = label;

	impurity = 1; % gini impurity
	for i = 1:nclasses
		impurity = impurity - (occs(i) / nsamples)^2;
	end
	tree.impurities(curnode) = impurity;

	tree.features(curnode) = NaN; % split properties
	tree.values(curnode) = NaN;
	tree.lefts(curnode) = NaN;
	tree.rights(curnode) = NaN;

	%logger.log( 'node label: %d', label );
	%logger.log( 'node impurity: %f', impurity );
	
	if sum( occs ~= 0 ) == 1 % stop with pure node
		%logger.untab();
		return;
	end

		% sample split features
	nfeatures = size( features, 2 );

	fis = randi( nfeatures, 1, ceil( sqrt( nfeatures ) ) );
	nfis = numel( fis );

		% set split properties
	simps = NaN( nfis, 1 ); % pre-allocation
	svals = NaN( nfis, 1 );

	for i = 1:nfis

			% set split values to check
		[fvals, order] = sort( features(:, fis(i)) ); % all possible values
		
		vis = find( diff( labels(order) ) ~= 0 ) + 1; % values with label change
		nvis = numel( vis );

			% set split impurities
		%occs = cumsum( classinds(:, order), 2 );

		%fimps = NaN( nvis, 1 ); % pre-allocation

		%for j = 1:nvis

			%nlsamples = vis(j) - 1;
			%nrsamples = nsamples - nlsamples;

			%limp = 1; % child gini impurities
			%rimp = 1;
			%for k = 1:nclasses
				%limp = limp - (occs(k, nlsamples) / nlsamples)^2;
				%rimp = rimp - ((occs(k, end)-occs(k, nlsamples)) / nrsamples)^2;
			%end

			%fimps(j) = (limp*nlsamples + rimp*nrsamples) / nsamples; % overall impurity

		%end

			% get split impurities
		if mexified
			fimps = brf.split_imp_mex( cumsum( classinds(:, order), 2 ), vis );
		else
			fimps = brf.split_imp( cumsum( classinds(:, order), 2 ), vis );
		end

			% choose split with lowest impurity
		si = find( fimps == min( fimps ) );
		if numel( si ) > 1
			si = randsample( si, 1 ); % random minimum
		end

		if ~isempty( si )
			simps(i) = fimps(si);
			svals(i) = fvals(vis(si));
		end

	end

		% choose split with lowest impurity
	si = find( simps == min( simps ) );
	if numel( si ) > 1
		si = randsample( si, 1 ); % random minimum
	end

		% finish current node (split recursively)
	if ~isempty( si )

		tree.features(curnode) = fis(si); % split properties
		tree.values(curnode) = svals(si);

			% proceed left child
		lsamples = features(:, tree.features(curnode)) < tree.values(curnode);
		nlsamples = sum( lsamples );

		if nlsamples > 0

			tree = expand( tree ); % add child node
			tree.lefts(curnode) = numel( tree.labels );

			tree = brf.split( tree, ...
				features(lsamples, :), labels(lsamples), nclasses, ...
				tree.lefts(curnode), curdepth+1 ); % recursion

		end

			% proceed right child
		rsamples = ~lsamples;
		nrsamples = sum( rsamples );

		if nrsamples > 0

			tree = expand( tree ); % add child node
			tree.rights(curnode) = numel( tree.labels );

			tree = brf.split( tree, ...
				features(rsamples, :), labels(rsamples), nclasses, ...
				tree.rights(curnode), curdepth+1 ); % recursion

		end

	end

	%logger.untab();
end

function tree = expand( tree )
	tree.labels(end+1) = NaN;
	tree.impurities(end+1) = NaN;
	tree.features(end+1) = NaN;
	tree.values(end+1) = NaN;
	tree.lefts(end+1) = NaN;
	tree.rights(end+1) = NaN;
end

