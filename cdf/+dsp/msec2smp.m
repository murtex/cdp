function smp = msec2smp( msec, rate )
% milliseconds to samples
%
% smp = MSEC2SMP( msec, rate )
%
% INPUT
% msec : milliseconds (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% smp : samples (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( msec )
		error( 'invalid argument: msec' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert scale
	smp = round( msec / 1000 * rate );

end

