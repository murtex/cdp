function fr = frame( ts, length, overlap, window, varargin )
% frame signal
%
% fr = FRAME( ts, length, overlap, window, ... )
%
% INPUT
% ts : signal/time series (row numeric)
% length : frame length (scalar numeric)
% overlap : frame overlap (scalar numeric)
% window : window function (scalar object)
% ... : additional window function arguments
%
% OUTPUT
% fr : signal frames (matrix numeric)

		% safeguard
	if nargin < 1 || ~isrow( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( length ) || ~isnumeric( length ) || length < 1
		error( 'invalid argument: length' );
	end

	if nargin < 3 || ~isscalar( overlap ) || ~isnumeric( overlap ) || overlap < 0 || overlap >= 1
		error( 'invalid argument: overlap' );
	end

	if nargin < 4 || ~isscalar( window ) || ~isa( window, 'function_handle' )
		error( 'invalid argument: window' );
	end

		% prepare frames
	tslen = numel( ts );

	overlap = floor( overlap * length ); % convert scale
	stride = length - overlap;

	nframes = ceil( tslen / stride );

		% frame signal
	starts = (0:nframes-1) * stride + 1;
	stops = starts + length - 1;

	ts = cat( 2, ts, zeros( 1, stops(end) - tslen ) ); % zero-padding
	window = transpose( window( length, varargin{:} ) ); % apodization

	fr = zeros( nframes, length ); % pre-allocation

	for i = 1:nframes
		fr(i, :) = window .* ts(starts(i):stops(i));
	end

end

