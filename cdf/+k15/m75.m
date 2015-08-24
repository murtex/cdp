function p = m75( ts, ratio )
% mermelstein peak detector
%
% p = M75( ts, ratio )
%
% INPUT
% ts : time series (column numeric)
% ratio : peak ratio (scalar numeric)
%
% OUTPUT
% p : peak indices (column numeric)
%
% SEE
% Mermelstein, Automatic Segmentation of Speech into Syllabic Units, 1975

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( ratio ) || ~isnumeric( ratio )
		error( 'invalid argument: ratio' );
	end

		% set convex hull
	[tsmax, tsmaxi] = max( ts );

	h = -Inf( size( ts ) );
	h(1) = ts(1);
	h(tsmaxi) = tsmax;
	h(end) = ts(end);

	for i = 2:tsmaxi-1 % lhs
		if ts(i) > h(i-1)
			h(i) = ts(i);
		else
			h(i) = h(i-1);
		end
	end

	for i = numel( ts )-1:-1:tsmaxi+1 % rhs
		if ts(i) > h(i+1)
			h(i) = ts(i);
		else
			h(i) = h(i+1);
		end
	end

		% proceed recursively
	[hdmax, hdmaxi] = max( h - ts ); % maximum hull difference

	if hdmax / (tsmax-min( ts )) >= ratio
		p = k15.m75( ts(1:hdmaxi), ratio );
		p = cat( 1, p, hdmaxi + k15.m75( ts(hdmaxi:end), ratio ) - 1 );
		return;
	else
		p = tsmaxi;
	end

end

