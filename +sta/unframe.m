function ser = unframe( ser, frame )
% short-time un-framing
%
% ser = UNFRAME( ser, frame )
%
% INPUT
% ser : time series (numeric)
% frame : frame length and stride (pair numeric)
%
% OUTPUT
% ser : unframed time series (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isnumeric( frame ) || numel( frame ) ~= 2
		error( 'invalid argument: frame' );
	end

		% fast un-framing
	ser = sta.unframe_v2( ser, frame );

end

