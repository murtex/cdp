function frser = framing( ser, frame, wnd, varargin )
% short-time framing
%
% frser = FRAMING( ser, frame, wnd, ... )
%
% INPUT
% ser : time series (numeric)
% frame : frame length and stride (pair numeric)
% wnd : window function (scalar object)
% ... : additional window function arguments
%
% OUTPUT
% frser : frame series (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isnumeric( frame ) || numel( frame ) ~= 2
		error( 'invalid argument: frame' );
	end

	if nargin < 3 || ~isscalar( wnd ) || ~isa( wnd, 'function_handle' )
		error( 'invalid argument: wnd' );
	end

		% prepare framing
	s = size( ser );

	n = ceil( s(1) / frame(2) ); % number of frames

	starts = frame(2) * (0:n-1) + 1; % frame ranges
	stops = starts + frame(1) - 1;

	z = zeros( s(2:end) ); % zero padding
	ser = cat( 1, ser, repmat( z, max( stops ) - s(1), 1 ) );

	w = wnd( frame(1), varargin{:} ); % window function

		% framing
	frser = zeros( cat( 2, n, frame(1), s(2:end) ) ); % pre-allocation

	for i = 1:n
		frser(i, :) = w .* ser(starts(i):stops(i), :);
	end

end

