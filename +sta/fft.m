function [frser, freqs] = fft( frser, rate )
% short-time fourier transform (one-sided power spectrum)
%
% [frser, freqs] = FFT( frser, rate )
%
% INPUT
% frser : frame series (numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% frser : frame fft series (numeric)
% freqs : fourier frequencies (row numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( frser )
		error( 'invalid argument: frser' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% fourier transform
	l = 2^nextpow2( size( frser, 2 ) );

	frser = fft( frser, l, 2 );
	frser = frser(:, 1:l/2+1, :); % one-sided
	frser = (frser .* conj( frser )) / (l*l); % normalized powers

	freqs = rate/2 * linspace( 0, 1, l/2+1 );

end

