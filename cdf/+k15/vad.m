function vad( ts, rate )
% voice activity detection
%
% VAD( ts, rate )
%
% INPUT
% ts : time series (column numeric)
% rate : sampling rate (scalar numeric)

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% TODO

end

