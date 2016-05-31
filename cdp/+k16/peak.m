function p = peak( ser, thresh )
% +/- peak detection
%
% p = PEAK( ser, thresh )
%
% INPUT
% ser : time series (vector numeric)
% thresh : peak threshold (scalar numeric)
%
% OUTPUT
% p : peak indices (vector numeric)

		% safeguard
	if nargin < 1 || ~isvector( ser ) || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isscalar( thresh ) || ~isnumeric( thresh )
		error( 'invalid argument: thresh' );
	end

		% mermelstein-like peak-detector
	function p = m75( ser, tpeak, tsplit )

			% (first) maximum
		[m, mind] = max( abs( ser ) );
		mind = mind(1);
		
			% two-sided convex hull
		n = numel( ser );

		hull = zeros( size( ser ) ); % pre-allocation
		hull(1) = ser(1);
		hull(mind) = ser(mind);
		hull(n) = ser(n);

		for i = 2:mind-1 % left side
			if abs( ser(i) ) > abs( hull(i-1) )
				hull(i) = ser(i);
			else
				hull(i) = hull(i-1);
			end
		end

		for i = n-1:-1:mind+1 % right side (backwards)
			if abs( ser(i) ) > abs( hull(i+1) )
				hull(i) = ser(i);
			else
				hull(i) = hull(i+1);
			end
		end

			% split (recursively)
		[dm, dmind] = max( abs( hull-ser ) ); % maximum distance between series and hull
		dmind = dmind(1);

		if dm >= tsplit
			p = m75( ser(1:dmind), tpeak, tsplit ); % left side
			p = cat( 1, p, m75( ser(dmind:n), tpeak, tsplit )-1+dmind ); % right side
			return;
		
			% set peak
		elseif abs( ser( mind ) ) >= tpeak
			p = mind;
		else
			p = [];
		end

	end

		% find +/- peaks
	p = m75( abs( ser ), thresh, thresh );

end

