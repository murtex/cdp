function smp = sec2smp( sec, rate )
% seconds to units of samples
%
% smp = SEC2SMP( sec, rate )
%
% INPUT
% sec : seconds (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% smp : units of samples (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( sec )
		error( 'invalid argument: sec' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert units
	smp = round( sec * rate );

end

