function p = plosion( ser, delta, width )
% get plosion indices
% 
% p = PLOSION( ser, delta, width )
% 
% INPUT
% ser : time series (vector numeric)
% delta : TODO (scalar numeric)
% width : plosion width (scalar numeric)
%
% OUTPUT
% p : plosion indices (column numeric)

		% safeguard
	if nargin < 1 || ~isvector( ser ) || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isscalar( delta ) || ~isnumeric( delta )
		error( 'invalid argument: delta' );
	end

	if nargin < 2 || ~isscalar( width ) || ~isnumeric( width )
		error( 'invalid argument: width' );
	end

		% proceed sets between zero-crossings
	p = zeros( numel( ser ), 1 ); % pre-allocation

	zcs = find( abs( diff( ser >= 0 ) ) == 1 ); % zero-crossings
	he = abs( hilbert( ser ) ); % hilbert envelope

	n = numel( zcs );
	for i = 1:n-1

			% hilbert maximum
		[hemax, imax] = max( he(zcs(i):zcs(i+1)-1) );
		imax = zcs(i) + imax-1;

			% region to average
		li = max( 1, imax-delta-width );
		ri = max( 1, imax-delta-1 );

			% plosion index
		if imax > delta+1
			p(imax) = hemax/mean( he(li:ri) );
		end

	end

end

