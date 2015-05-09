function ser = unframe_v2( ser, frame )
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

		% TODO: support multi-dimensional arrays!
	if ~ismatrix( ser )
		error( 'invalid argument: ser' );
	end

		% expand and center frames
	ser = kron( ser, ones( frame(2), 1 ) );

	l2 = floor( frame(1)/2 ); % half frame length
	ser = cat( 1, repmat( ser(1, :), l2, 1 ), ser );
	ser(end-l2+1:end, :) = [];

		% smooth series
	kernel = fspecial( 'average', [2*(frame(1)-frame(2)), 1] );
	ser = filter2( kernel, ser );

end

