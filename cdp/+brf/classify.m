function labels = classify( forest, features )
% classify features
%
% labels = CLASSIFY( forest, features )
%
% INPUT
% forest : trees (row struct)
% features : feature matrix (matrix numeric)
%
% OUTPUT
% labels : prediction labels (matrix numeric)

		% safeguard
	if nargin < 1 || ~isrow( forest ) % no type check!
		error( 'ivalid argument: forest' );
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
		labels = brf.classify_mex( forest, features ); % call mex-version
		return;
	end

		% MATLAB FALLBACK IMPLEMENTATION

		% get class votes from all trees
	nsamples = size( features, 1 );
	ntrees = numel( forest );

	labels = NaN( ntrees, nsamples ); % pre-allocation

	for i = 1:nsamples
		sfeatures = features(i, :);

			% proceed trees
		for j = 1:ntrees

				% proceed down to leaf
			node = 1;

			while ~isnan( forest(j).lefts(node) ) || ~isnan( forest(j).rights(node) )
				if sfeatures(forest(j).features(node)) < forest(j).values(node)
					if isnan( forest(j).lefts(node) )
						break; % found leaf
					else
						node = forest(j).lefts(node); % proceed
					end
				else
					if isnan( forest(j).rights(node) )
						break; % found leaf
					else
						node = forest(j).rights(node); % proceed
					end
				end
			end

				% vote for leaf label
			labels(j, i) = forest(j).labels(node);

		end

	end

end

