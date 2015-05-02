function babbling( pows, freqs, plotfile )
% plot speech-weighted noise (babbling) spectrum
%
% BABBLING( pows, freqs, plotfile )
%
% INPUT
% pows : spectral powers (row numeric)
% freqs : frequencies (row numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( pows ) || ~isnumeric( pows )
		error( 'invalid arguments: pows' );
	end

	if nargin < 2 || ~isrow( freqs ) || ~isnumeric( freqs ) || numel( freqs ) ~= numel( pows )
		error( 'invalid argument: freqs' );
	end

	if nargin < 3 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot babbling ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% linear power fits
	mask_lo = freqs >= 100 & freqs <= 1000;
	coeffs_lo = polyfit( log10( freqs(mask_lo) ), pow2db( pows(mask_lo) ), 1 );

	mask_med = freqs >= 1000 & freqs <= 10000;
	coeffs_med = polyfit( log10( freqs(mask_med) ), pow2db( pows(mask_med) ), 1 );

	mask_hi = freqs >= 10000;
	coeffs_hi = polyfit( log10( freqs(mask_hi) ), pow2db( pows(mask_hi) ), 1 );

		% plot spectrum
	title( 'babbling spectrum' );
	xlabel( 'frequency in hertz' );
	ylabel( 'power in decibel' );

	plot( freqs(mask_lo), polyval( coeffs_lo, log10( freqs(mask_lo) ) ), ... % power fits
		'LineStyle', '--', 'Color', style.color( 'cold', +2 ) );
	plot( freqs(mask_med), polyval( coeffs_med, log10( freqs(mask_med) ) ), ...
		'LineStyle', '--', 'Color', style.color( 'cold', +2 ) );
	plot( freqs(mask_hi), polyval( coeffs_hi, log10( freqs(mask_hi) ) ), ...
		'LineStyle', '--', 'Color', style.color( 'cold', +2 ) );

	plot( freqs, pow2db( pows ), ... % spectrum
		'Color', style.color( 'warm', 0 ) );

	set( gca(), 'XScale', 'log' );
	xlim( [freqs(2), freqs(end)] );
	%ylim( [pow2db( eps ), 0] );

	style.print( plotfile );
	delete( fig );
end

