function gi = gini( labels, nclasses )
% get gini impurity index
%
% gi = GINI( labels, nclasses )
%
% INPUT
% labels : sample labels (row numeric)
% nclasses : number of classes (scalar numeric)
%
% OUTPUT
% gi : gini impurity index (scalar numeric)

		% safeguard
	if nargin < 1 || ~isrow( labels ) || ~isnumeric( labels )
		error( 'invalid argument: labels' );
	end

	if nargin < 2 || ~isscalar( nclasses ) || ~isnumeric( nclasses )
		error( 'invalid argument: nclasses' );
	end

		% compute gini impurity
	nlabels = numel( labels );

	gi = 1;

	for i = 1:nclasses
		gi = gi - (sum( labels == i )/nlabels)^2;
	end

end

