function [st, freqs] = stransf( ts, rate, lofreq, hifreq, nfreqs )
% stockwell transform
%
% [st, freqs] = STRANFS( ts, rate, lofreq, hifreq, nfreqs )
%
% INPUT
% ts : signal/time series (column numeric)
% rate : sampling rate (scalar numeric)
% lofreq : lower frequency limit (scalar numeric)
% hifreq : upper frequency limit (scalar numeric)
% nfreqs : frequency resolution (scalar numeric)
%
% OUTPUT
% st : stockwell transform (matrix numeric)
% freqs : frequencies (column numeric)
% 
% SEE
% https://www.mathworks.com/matlabcentral/fileexchange/45848-stockwell-transform--s-transform-
% http://www.codeforge.com/read/33451/st.m__html
%
% TODO
% implement vectorized version (via gaussian window matrix)

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 3 || ~isscalar( lofreq ) || ~isnumeric( lofreq )
		error( 'invalid argument: lofreq' );
	end
	
	if nargin < 4 || ~isscalar( hifreq ) || ~isnumeric( hifreq )
		error( 'invalid argument: hifreq' );
	end

	if nargin < 5 || ~isscalar( nfreqs ) || ~isnumeric( nfreqs )
		error( 'invalid argument: nfreqs' );
	end

	FACTOR = 3; % a value of 3 should give better frequency resolution (sometimes)

		% gaussian window function
	function gw = gw( len, freq, FACTOR )
		v(1, :) = [0:len-1];
		v(2, :) = [-len:-1];
		v = v.^2;
		v = (-2*pi^2*FACTOR / freq^2) * v;
		gw = sum( exp( v ) );
	end

		% zero-pad time series
	tslenorig = numel( ts );

	tslen = 2^nextpow2( max( rate, tslenorig ) );
	ts = cat( 1, ts, zeros( tslen - tslenorig, 1 ) );

		% compute hilbert transform (the real way [sic!])
	ts = fft( real( ts ) );
	h = [1; ...
		2*ones( fix( (tslen-1)/2 ), 1 ); ...
		ones( 1-rem( tslen, 2 ), 1 ); ...
		zeros( fix( (tslen-1)/2 ), 1 )];
	ts = ts .* h;
	ts = ifft( ts );

		% compute fourier transforms
	fts = fft( ts ) / tslen;
	%fts = fftshift( fft( fftshift( ts ) ) ) / tslen;
	fts = [fts, fts];

		% compute fourier frequencies
	if mod( tslen, 2 ) == 0
		ftfreqs = transpose( [0:tslen/2-1, -fliplr( 1:tslen/2 )] );
	else
		ftfreqs = transpose( [0:floor( tslen/2 ), -fliplr( 1:floor( tslen/2 ) )] );
	end
	ftfreqs = ftfreqs / (tslen/2) * (rate/2);

		% compute stockwell transform
	st = zeros( nfreqs, tslen ); % pre-allocation
	freqs = transpose( linspace( lofreq, hifreq, nfreqs ) );

	for i = 1:nfreqs

			% set nearest fourier frequency
		[~, ftfreqi] = min( abs( ftfreqs - freqs(i) ) );
		freqs(i) = ftfreqs(ftfreqi);

			% compute transform
		if ftfreqi == 1
			st(i, :) = mean( ts );
		else
			st(i, :) = ifft( fts(ftfreqi:ftfreqi+tslen-1) .* gw( tslen, freqs(i), FACTOR ) );
		end

	end

		% trim zero-padding
	st = st(:, 1:tslenorig);

end

