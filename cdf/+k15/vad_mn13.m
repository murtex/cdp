function vad_mn13( ts, rate, freqband, window, ltm )
% voice activity detection
%
% VAD_MN13( ts, rate, freaband, window, ltm )
%
% INPUT
% ts : time series (column numeric)
% rate : sampling rate (scalar numeric)
% freqband : frequency band [lower, upper, count] (row numeric)
% window : short-time window [function, length, overlap] (row cell)
% ltm : long-term setting [R, M, head, lambda] (row numeric)
%
% SEE
% P. K. Gosh, A. Tsiartas, S. Narayanan: Robust voice activity detection using long-term signal variability (2011)
% Y. Ma, A. Nishihara: Efficient voice activity detection algorithm using long-term spectral flatness measure (2013)

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 3 || ~isrow( freqband ) || ~isnumeric( freqband )
		error( 'invalid argument: freqband' );
	end

	if nargin < 4 || ~isrow( window ) || ~iscell( window ) % TODO: check cell types?
		error( 'invalid argument: window' );
	end

	if nargin < 5 || ~isrow( ltm ) || ~isnumeric( ltm )
		error( 'invalid argument: ltm' );
	end

		% short-time fourier transform
	[stft, times, freqs] = dsp.stftransf( ts, rate, freqband, window );

	stft = stft .* conj( stft ); % powers

		% long-term averaging
	nsegs = size( stft, 2 );

	tmp = stft;
	stft = NaN( size( tmp ) );

	for i = ltm(2):nsegs
		stft(:, i) = mean( tmp(:, i-ltm(2)+1:i), 2 );
	end

		% long-term spectral flatness
	lsfm = NaN( size( stft, 2 ), 1 );

	for i = ltm(1):nsegs
		gm = geomean( stft(:, i-ltm(1)+1:i), 2 );
		am = mean( stft(:, i-ltm(1)+1:i), 2 );
		lsfm(i) = sum( log10( gm ./ am + eps ) );
	end

		% adaptive thresholding
	threshs = NaN( size( lsfm ) );

	lead = ltm(1)+ltm(2)-1:ltm(1)+ltm(2)-1+ltm(3)-1; % initial thresholds
	threshs(lead) = min( lsfm(lead) );

	for i = ltm(1)+ltm(2)-1+ltm(3):nsegs

			% initial activity decision
		tmp = lsfm(i-ltm(3):i-1);
		n = tmp >= threshs(i-ltm(3):i-1);
		bn = tmp(n);
		bsn = tmp(~n);

			% update threshold
		if ~isempty( bsn ) && ~isempty( bn )
			threshs(i) = ltm(4)*min( bn ) + (1-ltm(4))*max( bsn );
		else
			threshs(i) = threshs(i-1);
		end

	end

		% final activity decision, TODO
	tmp = lsfm < threshs;
	va = false( size( tmp ) );

	va = tmp; % DEBUG

		% DEBUG
	style = xis.hStyle.instance();
	fig = style.figure( 'Visible', 'on' );

	subplot( 3, 1, 1 );
	xlim( dsp.smp2msec( [1, numel( ts )] - 1, rate ) );
	ylim( [-1, 1] * max( abs( ts ) ) * style.scale( 1/2 ) );
	stairs( times * 1000, va * max( abs( ts ) ), 'Color', style.color( 'signal', +1 ) );
	stairs( dsp.smp2msec( 0:numel( ts )-1, rate ), ts, 'Color', style.color( 'cold', -1 ) );

	subplot( 3, 1, 2 );
	xlim( dsp.smp2msec( [1, numel( ts )] - 1, rate ) );
	ylim( freqband(1:2) );
	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % signal
	imagesc( times * 1000, freqs, pow2db( stft + eps ) );

	subplot( 3, 1, 3 );
	xlim( dsp.smp2msec( [1, numel( ts )] - 1, rate ) );
	stairs( times * 1000, threshs, 'Color', style.color( 'signal', +1 ) );
	stairs( times * 1000, lsfm, 'Color', style.color( 'cold', -1 ) );

		% DEBUG
	error( 'DEBUG' );

end

