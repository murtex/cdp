function [ft, freqs] = band( ft, freqs, lofreq, hifreq, onesided )
% fourier transform subband
%
% [ft, freqs] = band( ft, freqs, lofreq, hifreq, onesided )
%
% INPUT
% ft : signal frames fourier transform (matrix numeric)
% freqs : frequencies (column numeric)
% lofreq : lower frequency limit (scalar numeric)
% hifreq : upper frequency limit (scalar numeric)
% onesided : onse-sided spectrum flag (scalar logical)
% 
% OUTPUT
% ft : signal frames fourier transform (matrix numeric)
% freqs : frequencies (column numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( ft ) || ~isnumeric( ft ) || any( size( ft ) == 0 )
		error( 'invalid argument: ft' );
	end

	if nargin < 2 || ~iscolumn( freqs ) || ~isnumeric( freqs ) || numel( freqs ) ~= size( ft, 1 )
		error( 'invalid argument: freqs' );
	end

	if nargin < 3 || ~isscalar( lofreq ) || ~isnumeric( lofreq )
		error( 'invalid argument: lofreq' );
	end

	if nargin < 4 || ~isscalar( hifreq ) || ~isnumeric( hifreq )
		error( 'invalid argument: hifreq' );
	end

	if nargin < 5 || ~isscalar( onesided ) || ~islogical( onesided )
		error( 'invalid argument: onesided' );
	end

		% reduce to one-sided spectrum
	if onesided
		nfreqs = ceil( (size( ft, 1 ) + 1) / 2 );

		ft = flipud( ft(1:nfreqs, :) );
		freqs = flipud( abs( freqs(1:nfreqs) ) );
	end

		% subband spectrum
	bandfreqs = freqs >= lofreq & freqs <= hifreq;

	ft = ft(bandfreqs, :);
	freqs = freqs(bandfreqs);

end

