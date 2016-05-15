function [sbpw, t1, t2, sa] = sad( va, stft, times, freqs, subband )
% speech activity detection
%
% [sbpw, t1, t2, sa] = SAD( va, stft, times, freqs, subband )
%
% INPUT
% va : voice activity (column numeric)
% stft : short-time fourier transform power (matrix numeric)
% times : time values (row numeric)
% freqs : frequencies (column numeric)
% subband : frequency subband (row numeric)
%
% OUTPUT
% sbpw : subband power (row numeric)
% t1 : lower threshold (scalar numeric)
% t2 : upper threshold (scalar numeric)
% sa : speech activity (column numeric)
%
% SEE
% [1] D. Burileanu, L. Pascalin, C.Burileanu, M. Puchiu: An adaptive and fast speech detection algorithm (2000)

		% safeguard
	if nargin < 1 || ~iscolumn( va ) || ~islogical( va )
		error( 'invalid argument: va' );
	end

	if nargin < 2 || ~ismatrix( stft ) || ~isnumeric( stft )
		error( 'invalid argument: stft' );
	end

	if nargin < 3 || ~isrow( times ) || numel( times ) ~= size( stft, 2 ) || ~isnumeric( times )
		error( 'invalid arguments: times' );
	end

	if nargin < 4 || ~iscolumn( freqs ) || numel( freqs ) ~= size( stft, 1 ) || ~isnumeric( freqs )
		error( 'invalid argument: freqs' );
	end

	if nargin < 5 || ~isrow( subband ) || numel( subband ) ~= 2 || ~isnumeric( subband )
		error( 'invalid argument: subband' );
	end

		% subband power
	sbpw = sum( stft(freqs >= subband(1) & freqs <= subband(2), :), 1 );
	sbpw(sbpw < 100*eps) = NaN; % mask low values

		% adaptive thresholds, SEE: [1]
	smin = min( sbpw );
	smax = max( sbpw );

	t1 = smin * (1 + 2*log10( smax/smin ));
	t2 = t1 + 0.25*(mean( sbpw(sbpw > t1) ) - t1);

		% validate voice activities
	dva = diff( [false; va; false] );

	starts = find( dva == 1 );
	stops = find( dva == -1 ) - 1;

	sa = va; % pre-allocation

	for i = 1:numel( starts )
		if ~any( sbpw(starts(i):stops(i)) > t2 )
			sa(starts(i):stops(i)) = false;
	end

end

