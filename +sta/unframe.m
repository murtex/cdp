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

		% try to call mex-version (once)
	%persistent mexified;

	%if isempty( mexified )

			%% get current module path
		%[st, i] = dbstack( '-completenames' );
		%[path, ~, ~] = fileparts( st(i).file );

			%% compile mex-source
		%src = fullfile( path, 'unframe_mex.cpp' );
		%ret = mex( src, '-silent', '-outdir', path );

		%mexified = ~ret;
	%end

	%if mexified
		%ser = sta.unframe_mex( ser, frame ); % call mex-version
		%return;
	%end

		% MATLAB FALLBACK IMPLEMENTATION

	ser = sta.unframe_v2( ser, frame );

end

