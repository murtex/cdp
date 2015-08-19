function sec = smp2sec( smp, rate )
% samples to seconds
%
% sec = SMP2SEC( smp, rate )
%
% INPUT
% smp : samples (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% sec : seconds (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( smp )
		error( 'invalid argument: smp' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate ) || rate <= 0
		error( 'invalid argument: rate' );
	end

		% convert scale
	sec = smp / rate;

end

