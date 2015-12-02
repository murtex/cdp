function [starts, stops] = vad( ts, rate, freqband, window, range )
% voice activity detection
%
% [starts, stops] = VAD( ts, rate, freqband, window, range )
%
% INPUT
% ts : time series (column numeric)
% rate : sampling rate (scalar numeric)
% freqband : frequency band [lower, upper, count] (row numeric)
% window : short-time window [function, length, overlap] (vector cell)
% range : long-term range [start, stop] (row numeric)
%
% OUTPUT
% starts : activity starts (column numeric)
% stops : activity stops (column numeric)
%
% SEE
% Y. Ma, A. Nishihara : Efficient voice activity detection algorithm using long-term spectral flatness measure (2013)

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

	if nargin < 4 || ~isvector( window ) || ~iscell( window ) % TODO: check cell types?!
		error( 'invalid argument: window' );
	end

	if nargin < 5 || ~isrow( range ) || ~isnumeric( range )
		error( 'invalid argument: range' );
	end

		% get short-time fourier transform
	[stft, times, freqs] = dsp.stftransf( ts, rate, freqband, window );

	stft = stft .* conj( stft );

		% set long-term spectral flatness measure
	nsegs = size( stft, 2 );

	lsfm = zeros( nsegs, 1 ); % pre-allocation

	for i = 1:nsegs
		startseg = max( 1, i + range(1) );
		stopseg = min( nsegs, i + range(2) );

		times(stopseg)-times(startseg) % DEBUG

		gm = geomean( stft(:, startseg:stopseg), 2 );
		am = mean( stft(:, startseg:stopseg), 2 );

		lsfm(i) = sum( log10( gm ./ am ) );
	end

		% DEBUG
	starts = [];
	stops = [];

		% DEBUG
	style = xis.hStyle.instance();

	fig = style.figure( 'Visible', 'on' );

	subplot( 2, 1, 1 ); % spectrogram
	xlabel( 'time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( dsp.smp2msec( [1, numel( ts )] - 1, rate ) );
	ylim( freqband(1:2) );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
	imagesc( times * 1000, freqs, log( stft .^ 0.15 + eps ) );

	subplot( 2, 1, 2 ); % lsfm
	xlabel( 'time in milliseconds' );
	ylabel( 'long-term spectral flatness measure' );

	xlim( dsp.smp2msec( [1, numel( ts )] - 1, rate ) );

	stairs( times * 1000, lsfm, ... % measure
		'Color', style.color( 'cold', -1 ) );

	error( 'DEBUG' );

end

