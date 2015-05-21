function rorser = ror( ser, delta )
% rate-of-rise
%
% rorser = ROR( ser, delta )
%
% INPUT
% ser : time series (numeric)
% delta : ror-delta (scalar numeric)
%
% OUTPUT
% rorser : rate-of-rise (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isscalar( delta ) || ~isnumeric( delta )
		error( 'invalid argument: delta' );
	end

		% set rates
	n = size( ser, 1 );

	ldelta = floor( (delta-1)/2 );
	rdelta = ceil( (delta-1)/2 );

	rorser = zeros( size( ser ) ); % pre-allocation

	for i = 1:n

		li = max( 1, i-ldelta );
		ri = min( n, i+rdelta );

			% fade-in/out
		w = 1;
		
		%if i < ldelta
			%w = (i-1) / ldelta;
		%elseif i > n-rdelta
			%w = (n-i) / rdelta;
		%end

			% weighted ror
		rorser(i, :) = w * (ser(ri, :) - ser(li, :));

	end

end

