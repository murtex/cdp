function ser = unframe_v2( ser, frame )
% short-time un-framing
%
% ser = UNFRAME_V2( ser, frame )
%
% INPUT
% ser : time series (numeric)
% frame : frame length and stride (pair numeric)
%
% OUTPUT
% ser : unframed time series (numeric)

		% TODO: support multi-dimensional arrays!
	if ~ismatrix( ser )
		error( 'invalid argument: ser' );
	end

		% expand frames
	ser = kron( ser, ones( frame(2), 1 ) );
	ser(end+1:end+frame(1)-frame(2), :) = repmat( ser(end, :), frame(1)-frame(2), 1 );

		% center frames
	l2 = floor( frame(1)/2 );
	ser = cat( 1, repmat( ser(1, :), l2, 1 ), ser );
	ser(end-l2+1:end, :) = [];

		% smoothing
	kernel = fspecial( 'average', [2*(frame(1)-frame(2)), 1] );
	ser = filter2( kernel, ser );

end

