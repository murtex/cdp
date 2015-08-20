function p = m75( fvals, ratio )
% convex-hull peak detector
%
% p = M75( fvals, ratio )
%
% INPUT
% fvals : function values (vector numeric)
% ratio : peak ratio (scalar numeric)
%
% OUTPUT
% p : peak indices (column numeric)
%
% SEE
% Mermelstein, Automatic Segmentation of Speech into Syllabic Units, 1975

		% safeguard
	if nargin < 1 || ~isvector( fvals ) || ~isnumeric( fvals )
		error( 'invalid argument: fvals' );
	end

	if nargin < 2 || ~isscalar( ratio ) || ~isnumeric( ratio )
		error( 'invalid argument: ratio' );
	end

		% set convex hull
	fhull = -Inf( size( fvals ) );

	[fmax, fmaxi] = max( fvals );
	if isempty( fmax ) || isempty( fmaxi )
		p = [];
		return;
	end

	fhull(1) = fvals(1);
	fhull(fmaxi) = fvals(fmaxi);
	fhull(end) = fvals(end);

	for i = 2:fmaxi-1 % lhs
		if fvals(i) > fhull(i-1)
			fhull(i) = fvals(i);
		else
			fhull(i) = fhull(i-1);
		end
	end

	for i = numel( fvals )-1:-1:fmaxi+1 % rhs
		if fvals(i) > fhull(i+1)
			fhull(i) = fvals(i);
		else
			fhull(i) = fhull(i+1);
		end
	end

		% proceed recursively
	[dmax, dmaxi] = max( (fhull-fvals) / (fmax-min( fvals )) ); % hull difference

	if dmax >= ratio % split recursively

		p = k15.m75( fvals(1:dmaxi), ratio ); % lhs
		p = cat( 1, p, k15.m75( fvals(dmaxi:end), ratio ) - 1 + dmaxi ); % rhs

		return;

	else % add peak

		p = fmaxi;

	end

end

