function [labels, errs] = classify( roots, features )
% classify features
%
% [labels, errs] = CLASSIFY( roots, features )
%
% INPUT
% roots : tree root nodes (row object)
% features : feature matrix (matrix numeric)
%
% OUTPUT
% labels : prediction labels (row numeric)
% errs : prediction errors (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( roots ) || ~isa( roots(1), 'brf.hNode' )
		error( 'ivalid argument: roots' );
	end

	if nargin < 2 || ~ismatrix( features ) || ~isnumeric( features )
		error( 'invalid argument: features' );
	end

	logger = xis.hLogger.instance( 'bla' );
	%logger.tab( 'classify (samples: %d, trees: %d)...', size( features, 1 ), numel( roots ) );

		% get class votes from all trees
	nsamples = size( features, 1 );
	nroots = numel( roots );

	labels = NaN( nroots, nsamples ); % pre-allocation

	%logger.progress();
	for i = 1:nsamples
		sfeatures = features(i, :);

			% proceed root nodes
		for j = 1:nroots

				% proceed tree down to leaf
			node = roots(j);
			
			while ~isempty( node.left ) || ~isempty( node.right )
				if sfeatures(node.feature) < node.value
					if isempty( node.left )
						break;
					else
						node = node.left;
					end
				else
					if isempty( node.right )
						break;
					else
						node = node.right;
					end
				end
			end

				% vote for leaf label
			labels(j, i) = node.label;

			logger.log( 'label: %d', node.label );

		end

		%logger.progress( i, nsamples );
	end

		% reduce to majority votes w/ misclassification error
	[labels, errs] = mode( labels, 1 ); % TODO: equal frequencies?!
	errs = 1 - errs/nroots;

	%logger.untab();
end

