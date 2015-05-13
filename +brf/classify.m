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

		% compile mex-file (once)
	persistent compile;

	if isempty( compile )
		[st, i] = dbstack( '-completenames' ); % get current module path
		[path, ~, ~] = fileparts( st(i).file );
		src = fullfile( path, 'classify_mex.cpp' ); % compile mex-file
		mex( src, '-outdir', path );
		compile = false; % never check again
	end

		% call and return with mex-file
	labels = brf.classify_mex( roots, features );

	return;

		% MATLAB MEX-FILE TEMPLATE
		% DO NOT CALL ANYTHING THAT FOLLOWS!

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

