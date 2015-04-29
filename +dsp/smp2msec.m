function msec = smp2sec( smp, rate )
% units of samples to milliseconds
%
% msec = SMP2MSEC( smp, rate )
%
% INPUT
% smp : units of samples (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% msec : milliseconds (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( smp )
		error( 'invalid argument: smp' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert units
	msec = smp / rate * 1000;

end

