function smp = sec2smp( sec, rate )
% seconds to samples
%
% smp = sec2SMP( sec, rate )
%
% INPUT
% sec : seconds (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% smp : samples (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( sec )
		error( 'invalid argument: sec' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate ) || rate <= 0
		error( 'invalid argument: rate' );
	end

		% convert scale
	smp = round( sec * rate );

end

