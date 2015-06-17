function msec = smp2msec( smp, rate )
% samples to milliseconds
%
% msec = SMP2MSEC( smp, rate )
%
% INPUT
% smp : samples (numeric)
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

		% convert scale
	msec = smp / rate * 1000;

end

