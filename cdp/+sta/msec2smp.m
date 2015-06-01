function smp = msec2smp( msec, rate )
% milliseconds to units of samples
%
% smp = MSEC2SMP( msec, rate )
%
% INPUT
% msec : milliseconds (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% smp : units of samples (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( msec )
		error( 'invalid argument: msec' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert units
	smp = round( msec/1000 * rate );

end

