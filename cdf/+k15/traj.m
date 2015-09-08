function ts = traj( peaks, gap, leap )
% peak trajectory tracker
%
% t = TRAJ( peaks, gap, leap )
%
% INPUT
% peaks : peaks (matrix numeric)
% gap : trajectory gap (scalar numeric)
% leap : trajectory leap (scalar numeric)
%
% OUTPUT
% ts : trajectories (cell array)

		% safeguard
	if nargin < 1 || ~ismatrix( peaks ) || ~isnumeric( peaks )
		error( 'invalid arguments: peaks' );
	end

	if nargin < 2 || ~isscalar( gap ) || ~isnumeric( gap )
		error( 'invalid argument: gap' );
	end

	if nargin < 3 || ~isscalar( leap ) || ~isnumeric( leap )
		error( 'invalid argument: leap' );
	end

		% track trajectories
	ts = cell( 0 ); % pre-allocation

	while true
		
			% set new trajectory start
		r = NaN;
		c = NaN;

		for i = 1:size( peaks, 2 )
			nnans = find( ~isnan( peaks(:, i) ) );
			if ~isempty( nnans )
				c = i;
				r = nnans;
				if numel( r ) > 1
					r = randsample( r, 1 ); % choose random peak
				end

				break;
			end
		end

		if isnan( r ) || isnan( c ) % stop tracking
			break;
		end

			% follow nearest peaks
		t = [c, peaks(r, c)];
		peaks(r, c) = NaN; % invalidate peak

		gs = 0;
		for i = c+1:size( peaks, 2 )

				% stop on too wide gaps
			if gs > gap
				break;
			end

				% set peak distances
			pds = abs( peaks(:, i) - t(end, 2) );

			if ~any( pds <= leap )
				gs = gs + 1;
				continue;
			end

			gs = 0;

				% append nearest peak
			[~, n] = min( pds );

			t = cat( 1, t, [i, peaks(n, i)] );
			peaks(n, i) = NaN; % invalidate peak

		end

			% append trajectory
		nvals = size( t, 1 );
		nnvals = sum( diff( t(:, 1) ) - 1 );
		len = t(end, 1) - t(1, 1) + 1;

		if nvals > nnvals && len > gap
			ts{end+1} = t;
		end
		
	end

end

