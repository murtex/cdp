function [frser, freqs] = banding( frser, freqs, band )
% frequency banding
%
% [frser, freqs] = BANDING( frser, freqs, band )
%
% INPUT
% frser : frame fft series (numeric)
% freqs : fourier frequencies (row numeric)
% band : frequency band limits (pair numeric)
%
% OUTPUT
% frser : banded frame fft series (numeric)
% freqs : banded fourier frequencies (row numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( frser )
		error( 'invalid argument: frser' );
	end

	if nargin < 2 || ~isrow( freqs ) || ~isnumeric( freqs ) || numel( freqs ) ~= size( frser, 2 )
		error( 'invalid argument: freqs' );
	end

	if nargin < 3 || ~isnumeric( band ) || numel( band ) ~= 2
		error( 'invalid argument: band' );
	end

		% banding
	fs = freqs >= band(1) & freqs <= band(2);

	frser = frser(:, fs, :);
	freqs = freqs(fs);

end

