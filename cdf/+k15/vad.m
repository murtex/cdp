function [va, sd, dd, sdthresh, ddthresh] = vad( ft, noift, ltadj, hang )
% voice activity detector
%
% [va, sd, dd, sdthresh, ddthresh] = VAD( ft, noift, ltadj, hang )
%
% INPUT
% va : voice activity (column logical)
% ft : signal frames fourier transform (matrix numeric)
% noift : noise frames fourier transform (matrix numeric)
% ltadj : long-term adjacency (scalar numeric)
% hang : activity hangover (scalar numeric)
%
% OUTPUT
% sd : static long-term spectral distance (column numeric)
% dd : dynamic long-term spectral distance (column numeric)
% sdthresh : static distance threshold (scalar numeric)
% ddthresh : dynamic distance threshold (scalar numeric)
%
% SEE
% (2000) Burileanu, Pascalin, Burileanu, Puchiu : An Adaptive and Fast Speech Detection Algorithm
% (2003) Ramirez, Segura, Benitez, Torre, Rubio : A New Adaptive Long-Term Spectral Estimation Voice Activity Detector
% (2004) Ramirez, Segura, Benitez, Torre, Rubio : Voice Activity Detection with Long-Term Spectral Divergence Estimation
% (2005) Wu, Ren, Liu, Zhang : A Robust, Real-Time Voice Activity Detection Algorithm for Embedded Mobile Devices

		% safeguard
	if nargin < 1 || ~ismatrix( ft ) || ~isnumeric( ft ) || any( size( ft ) < 1 )
		error( 'invalid argument: ft' );
	end

	if nargin < 2 || ~ismatrix( noift ) || ~ismatrix( noift ) || any( size( noift ) < 1 ) || size( noift, 1 ) ~= size( ft, 1 )
		error( 'invalid argument: noift' );
	end

	if nargin < 3 || ~isscalar( ltadj ) || ~isnumeric( ltadj )
		error( 'invaid argument: ltadj' );
	end

	if nargin < 4 || ~isscalar( hang ) || ~isnumeric( hang )
		error( 'invalid argument: hang' );
	end

		% set one-sided power spectra
	nfreqs = ceil( (size( ft, 1 ) + 1) / 2 );

	ftpow = abs( ft(1:nfreqs, :) ).^2;
	noipow = abs( noift(1:nfreqs, :) ).^2;

	noipowmu = mean( noipow, 2 ); % average noise

		% proceed signal frames
	nfrs = size( ft, 2 );

	sd = NaN( nfrs, 1 ); % pre-allocation
	dd = NaN( nfrs, 1 );

	for i = 1+ltadj:nfrs-ltadj

			% set spectral features
		ltpow = max( ftpow(:, i-ltadj:i+ltadj), [], 2 ); % long-term envelope

		sd(i) = mean( (ltpow - noipowmu).^2 ); % static distance

		tmp = zeros( nfreqs, 1 ); % dynamic distance
		for j = 1:ltadj
			tmp = tmp + ftpow(:, i+j-1) - ftpow(:, i-j);
		end
		dd(i) = mean( (tmp / ltadj).^2 );

	end

		% set feature thresholds and convert to log-scale
	sdmin = min( sd );
	sdmax = max( sd );
	lothresh = sdmin * (1 + 2*log10( sdmax/sdmin ));
	hithresh = lothresh + 0.25 * (mean( sd(sd >= lothresh) ) - lothresh);
	sdthresh = log( lothresh * hithresh ) / 2;

	ddmin = min( dd );
	ddmax = max( dd );
	lothresh = ddmin * (1 + 2*log10( ddmax/ddmin ));
	hithresh = lothresh + 0.25 * (mean( dd(dd >= lothresh) ) - lothresh);
	ddthresh = log( lothresh * hithresh ) / 2;

	sd = log( sd );
	dd = log( dd );

		% set voice activity
	vasrc = sd >= sdthresh & dd >= ddthresh;
	va = vasrc;

	for i = 1:nfrs-1 % apply hangover
		if vasrc(i) && ~vasrc(i+1)
			hangstart = i + 1;
			hangstop = min( nfrs, i + hang );
			va(hangstart:hangstop) = true;
		end
	end

end

