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

		% expand and overlap frames
	s = size( ser );
	n = s(1); % number of frames

	starts = frame(2) * (0:n-1) + 1; % frame ranges
	stops = starts + frame(1) - 1;

	expand = zeros( cat( 2, max( stops ), s(2:end) ) ); % pre-allocation
	overlap = zeros( max( stops ), 1 );

	for i = 1:n
		expand(starts(i):stops(i), :) = expand(starts(i):stops(i), :) + repmat( ser(i, :), frame(1), 1 );
		overlap(starts(i):stops(i)) = overlap(starts(i):stops(i)) + ones( frame(1), 1 );
	end

	m = numel( overlap ); % averaging overlaps
	for i = 1:m
		expand(i, :) = expand(i, :) ./ overlap(i);
	end

	ser = expand;

		% center frames
	l2 = floor( frame(1)/2 ); % half frame length

	ser = cat( 1, repmat( ser(1, :), l2, 1 ), ser );
	ser(end-l2+1:end, :) = [];

end

