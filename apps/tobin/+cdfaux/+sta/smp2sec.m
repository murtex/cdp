function sec = smp2sec( smp, rate )
% units of samples to seconds
%
% sec = SMP2SEC( smp, rate )
%
% INPUT
% smp : units of samples (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% sec : seconds (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( smp )
		error( 'invalid argument: smp' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert units
	sec = smp / rate;

end

