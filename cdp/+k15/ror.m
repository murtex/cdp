function rorser = ror( ser, delta, qsplit )
% rate-of-rise
%
% rorser = ROR( ser, delta )
% rorser = ROR( ser, delta, qsplit )
%
% INPUT
% ser : time series (numeric)
% delta : ror-delta (scalar numeric)
% qsplit : split ratio (scalar numeric)
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
    
    if nargin < 3
        qsplit = 0.5;
    elseif ~isscalar( qsplit ) || ~isnumeric( qsplit )
        error( 'invalid argument: qsplit' );
    end

		% set rates
	n = size( ser, 1 );

	ldelta = floor( (delta-1) * qsplit ); % unbalanced split
	rdelta = ceil( (delta-1) * (1-qsplit) );
    
	rorser = zeros( size( ser ) ); % pre-allocation
    
	for i = 1:n
		li = max( 1, i-ldelta );
		ri = min( n, i+rdelta );
		rorser(i, :) = (ser(ri, :) - ser(li, :));
	end

end

