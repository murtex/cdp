function [stft, times, freqs, stride] = stftransf( ts, rate, freqband, window )
% short-time fourier transform
%
% [stft, times, freqs] = stftransf( ts, rate, freqband, window )
%
% INPUT
% ts : signal/time series (column numeric)
% rate : sampling rate (scalar numeric)
% freqband : frequency band [lower, upper, count] (vector numeric)
% window : short-time window [function, length, overlap] (vector cell)
%
% OUTPUT
% stft : short-time fourier transform (matrix numeric)
% times : time values (column numeric)
% freqs : frequencies (column numeric)
% stride : window stride (scalar numeric)

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 3 || ~isvector( freqband ) || ~isnumeric( freqband )
		error( 'invalid argument: freqband' );
	end

	if nargin < 4 || ~isvector( window ) || ~iscell( window ) % TODO: check cell types?!
		error( 'invalid argument: window' );
	end

		% short-time fourier transform
	wlen = dsp.sec2smp( window{2}, rate );
	wovl = dsp.sec2smp( window{2} * window{3}, rate );
	wstr = wlen - wovl;

	[stft, freqs, times] = spectrogram( ts, window{1}( wlen ), wovl, ...
		linspace( freqband(1), freqband(2), freqband(3) ), rate );

	stride = dsp.smp2sec( wstr, rate );

end
