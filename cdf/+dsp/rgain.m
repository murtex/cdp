function ts = rgain( ts, rate )
% replay gain equal loudness filter
%
% ts = RGAIN( ts, rate )
%
% INPUT
% ts : time series (column numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% ts : time series (column numeric)
%
% SEE
% [1] Equal loudness filter: http://replaygain.hydrogenaud.io/proposal/equal_loudness.html

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% yulewalk filter
	switch rate
		case 32000
			EL80=[0,120;20,113;30,103;40,97;50,93;60,91;70,89;80,87;90,86;100,85;200,78;300,76;400,76;500,76;600,76;700,77;800,78;900,79.5;1000,80;1500,79;2000,77;2500,74;3000,71.5;3700,70;4000,70.5;5000,74;6000,79;7000,84;8000,86;9000,86;10000,85;12000,95;15000,110;rate/2,115];
		case {44100, 48000}
			EL80=[0,120;20,113;30,103;40,97;50,93;60,91;70,89;80,87;90,86;100,85;200,78;300,76;400,76;500,76;600,76;700,77;800,78;900,79.5;1000,80;1500,79;2000,77;2500,74;3000,71.5;3700,70;4000,70.5;5000,74;6000,79;7000,84;8000,86;9000,86;10000,85;12000,95;15000,110;20000,125;rate/2,140];
		otherwise
			error( 'invalid argument: rate' );
	end

	f = EL80(:, 1) ./ (rate/2);
	m = 10 .^ ((70 - EL80(:, 2)) / 20);

	[By, Ay] = yulewalk( 10, f, m );
	ts = filter( By, Ay, ts );

		% butterworth filter
	[Bb, Ab] = butter( 2, 150 / (rate/2), 'high' );
	ts = filter( Bb, Ab, ts );

end

