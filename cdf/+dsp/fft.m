function [ft, freqs] = fft( fr, rate )
% fourier transform signal (frames)
%
% [ft, freqs] = FFT( fr, rate )
%
% INPUT
% fr : signal (frames) (matrix numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% ft : signal (frames) fourier transform (matrix numeric)
% freqs : frequencies (column numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( fr ) || ~isnumeric( fr ) || size( fr, 1 ) < 1
		error( 'invalid argument: fr' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% fourier transform
	ncoeffs = 2 ^ nextpow2( size( fr, 1 ) );

	ft = fft( fr, ncoeffs );
	freqs = rate/2 * linspace( 0, 1, ncoeffs/2 + 1 );
	
end

