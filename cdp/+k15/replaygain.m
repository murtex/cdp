function ser = replaygain( ser, rate )
% replay gain filter
%
% ser = REPLAYGAIN( ser, rate )
%
% INPUT
% ser : time series (vector numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% ser : filtered time series (vector numeric)

		% safeguard
	if nargin < 1 || ~isvector( ser ) || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% prepare filter, TODO: support more samplig rate!
	switch rate
		case 44100
			a1 = [1.00000000000000, -3.47845948550071, 6.36317777566148, -8.54751527471874, 9.47693607801280, -8.81498681370155, 6.85401540936998, -4.39470996079559, 2.19611684890774, -0.75104302451432, 0.13149317958808];
			b1 = [0.05418656406430, -0.02911007808948, -0.00848709379851, -0.00851165645469, -0.00834990904936, 0.02245293253339, -0.02596338512915, 0.01624864962975, -0.00240879051584, 0.00674613682247, -0.00187763777362];
			a2 = [1.00000000000000, -1.96977855582618, 0.97022847566350];
			b2 = [0.98500175787242, -1.97000351574484, 0.98500175787242];
		otherwise
			error( 'invalid argument: rate' );
	end

		% apply filter
	ser = filter( b1, a1, ser );
	ser = filter( b2, a2, ser );

end

