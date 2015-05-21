function labels = classify( roots, features )
% classify features
%
% labels = CLASSIFY( roots, features )
%
% INPUT
% roots : mex tree root nodes (row struct)
% features : feature matrix (matrix numeric)
%
% OUTPUT
% labels : prediction labels (matrix numeric)

		% safeguard
	if nargin < 1 || ~isrow( roots ) % no type check!
		error( 'ivalid argument: roots' );
	end

	if nargin < 2 || ~ismatrix( features ) || ~isnumeric( features )
		error( 'invalid argument: features' );
	end

		% try to call mex-version (once)
	persistent mexified;

	if isempty( mexified )

			% get current module path
		[st, i] = dbstack( '-completenames' );
		[path, ~, ~] = fileparts( st(i).file );

			% compile mex-source
		src = fullfile( path, 'classify_mex.cpp' );
		ret = mex( src, '-outdir', path );

		mexified = ~ret;
	end

	if mexified
		labels = brf.classify_mex( roots, features ); % call mex-version
		return;
	end

		% MATLAB FALLBACK IMPLEMENTATION

		% get class votes from all trees
	nsamples = size( features, 1 );
	nroots = numel( roots );

	labels = NaN( nroots, nsamples ); % pre-allocation

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

		end

	end

end

