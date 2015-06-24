function [ft, freqs] = fft( fr, rate )
% fourier transform signal frames
%
% [ft, freqs] = FFT( fr, rate )
%
% INPUT
% fr : signal frames (matrix numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% ft : signal frames fourier transform (matrix numeric)
% freqs : frequencies (column numeric)
%
% SEE
% A Guide to the FFT -- 2nd Edition Plus (https://www.mathworks.com/matlabcentral/fileexchange/5654-a-guide-to-the-fft-2nd-edition-plus)

		% safeguard
	if nargin < 1 || ~ismatrix( fr ) || ~isnumeric( fr ) || any( size( fr ) < 1 )
		error( 'invalid argument: fr' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% zero-padding
	nfrs = size( fr, 1 );
	ncoeffs = 2^nextpow2( nfrs );
	
	zs = zeros( ceil( (ncoeffs-nfrs)/2 ), size( fr, 2 ) );
	if mod( nfrs, 2 ) == 0
		fr = cat( 1, zs, fr, zs );
	else
		fr = cat( 1, zs, fr, zs(1:end-1, :) );
	end

		% fourier transform
	ft = fftshift( fft( fftshift( fr ) ) ) / ncoeffs;
	freqs = transpose( rate/2 * linspace( -1, 1 - 2/ncoeffs, ncoeffs ) );

end

