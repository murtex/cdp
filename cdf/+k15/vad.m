function [stft, times, freqs, pwsf, t1, t2, va] = vad( ts, rate, freqband, window )
% voice activity detection
%
% VAD( ts, rate, freqband, window )
%
% INPUT
% ts : time series (column numeric)
% rate : sampling rate (scalar numeric)
% freqband : frequency band [lower, upper, count] (row numeric)
% window : short-time window [function, length, overlay] (row cell)
%
% OUTPUT
% stft : short-time fourier transform power (matrix numeric)
% times : time values (column numeric)
% freqs : frequencies (column numeric)
% pwsf : power weighted spectral flatness (row numeric)
% t1 : lower threshold (scalar numeric)
% t2 : upper threshold (scalar numeric)
% va : voice activity (column numeric)
%
% SEE
% [1] D. Burileanu, L. Pascalin, C.Burileanu, M. Puchiu: An adaptive and fast speech detection algorithm (2000)
% [2] M. Prcin, L. Müller: Heuristic and statistical methods for speec/non-speech detector design (2002)
% [3] Y. Ma, A. Nishihara: Efficient voice activity detection algorithm using long-term spectral flatness measure (2013)
% [4] S. Graf, T. Herbig, M. Buck, G. Schmidt: Features for voice activity detection: A comparative analysis (2015)

		% safeguard
	if nargin < 1 || ~iscolumn( ts ) || ~isnumeric( ts )
		error( 'invalid argument: ts' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 3 || ~isrow( freqband ) || numel( freqband ) ~= 3 || ~isnumeric( freqband )
		error( 'invalid argument: freqband' );
	end

	if nargin < 4 || ~isrow( window ) || numel( window ) ~= 3
		error( 'invalid argument: window' );
	end

		% short-time fourier transform
	[stft, times, freqs, stride] = dsp.stftransf( ts, rate, freqband, window );
	stft = stft .* conj( stft ); % powers

		% power weighted spectral flatness, SEE: [2-3]
	pwsf = geomean( stft, 1 ) ./ mean( stft, 1 ); % spectral flatness
	pwsf = sum( stft, 1 ) .* pwsf; % power weightening

		% adaptive thresholds, SEE: [1]
	smin = min( pwsf );
	smax = max( pwsf );

	t1 = smin * (1 + 2*log10( smax/smin ));
	t2 = t1 + 0.25*(mean( pwsf(pwsf > t1) ) - t1);

		% endpoint decision, SEE: [1]
	nsegs = numel( pwsf );

	va = false( nsegs, 1 ); % pre-allocation

	state = 1;
	statelen = 0;

	for i = 1:nsegs
		switch state
			case 1 % no activity
				if pwsf(i) > t1 % start potential activity
					state = 2;
					statelen = 0;
				end
			case 2 % potential activity
				if pwsf(i) >= t2 % assure (past) activity
					va(i-statelen:i) = true;
					state = 3;
					statelen = 0;
				elseif pwsf(i) <= t1 % deny activity
					state = 1;
					statelen = 0;
				end
			case 3 % assured activity
				if pwsf(i) <= t1 % stop activity
					state = 1;
					statelen = 0;
				else % continue activity
					va(i) = true;
				end
		end

		statelen = statelen + 1;
	end

end

