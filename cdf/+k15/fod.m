function fod( sd, freqs, rate, peakratio, nformants )
% formant-onset detector
%
% FOD( sd, freqs, rate, peakratio, nformants )
% 
% INPUT
% sd : spectral decomposition (matrix numeric)
% freqs : frequencies (column numeric)
% rate : sampling rate (scalar numeric)
% peakratio : peak ratio (scalar numeric)
% nformants : number of formants (scalar numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( sd ) || ~isnumeric( sd )
		error( 'invalid argument: sd' );
	end

	if nargin < 2 || ~iscolumn( freqs ) || ~isnumeric( freqs ) || numel( freqs ) ~= size( sd, 1 )
		error( 'invalid argument: freqs' );
	end

	if nargin < 3 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 4 || ~isscalar( peakratio ) || ~isnumeric( peakratio )
		error( 'invalid argument: peakratio' );
	end

	if nargin < 5 || ~isscalar( nformants ) || ~isnumeric( nformants )
		error( 'invalid argument: nformants' );
	end

		% detect (formant) peaks
	sdlen = size( sd, 2 );
	sdmin = min( sd(:) );
	sdmax = max( sd(:) );

	ps = NaN( nformants, sdlen ); % pre-allocation
	for i = 1:sdlen
		p = sort( k15.m75( sd(:, i), peakratio ) );

		for j = 1:min( 4, numel( p ) )
			if (sd(p(j), i)-sdmin) / (sdmax-sdmin) >= peakratio
				ps(j, i) = freqs(p(j));
			end
		end
	end

		% DEBUG
	style = xis.hStyle.instance();
	fig = style.figure();

	title( 'formant-onset detection' );
	xlabel( 'response time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( dsp.smp2msec( [0, sdlen-1], rate ) );
	ylim( [min( freqs ), max( freqs )] );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % spectrogram
	imagesc( dsp.smp2msec( 0:sdlen-1, rate ), freqs, sd );

	for i = 1:nformants % peaks
		plot( dsp.smp2msec( 0:sdlen-1, rate ), ps(i, :) );
	end

	style.print( 'DEBUG.png' );
	delete( fig );

end

