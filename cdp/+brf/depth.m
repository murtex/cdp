function d = depth( tree, curnode )
% get tree maximum tree depth recursively
%
% d = DEPTH( tree )
%
% INPUT
% tree : tree (scalar struct)
% curnode : current node index (scalar numeric)
%
% OUTPUT
% d : maximum depth (scalar numeric)

	if nargin < 1 || ~isscalar( tree ) || ~isstruct( tree )
		error( 'invalid argument: tree' );
	end

	if nargin < 2 || ~isscalar( curnode ) || ~isnumeric( curnode )
		error( 'invalid argument: curnode' );
	end

		% get depth recursively
	if isnan( tree.lefts(curnode) ) && isnan( tree.rights(curnode) )
		d = 0;
		return;

	else

		ld = 0; % left depth
		if ~isnan( tree.lefts(curnode) )
			ld = brf.depth( tree, tree.lefts(curnode) );
		end

		rd = 0; % right depth
		if ~isnan( tree.lefts(curnode) )
			rd = brf.depth( tree, tree.lefts(curnode) );
		end

		d = max( ld, rd ) + 1; % maximum

	end

end

