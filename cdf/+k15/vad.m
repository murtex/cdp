function [vafr, sdfr, ddfr, sdthresh, ddthresh] = vad( ft, noift, ltadj, hang )
% voice activity detector
%
% [vafr, sdfr, ddfr, sdthresh, ddthresh] = VAD( ft, noift, ltadj, hang )
%
% INPUT
% ft : signal frames fourier transform (matrix numeric)
% noift : noise frames fourier transform (matrix numeric)
% ltadj : long-term adjacency (scalar numeric)
% hang : activity hangover (scalar numeric)
%
% OUTPUT
% vafr : voice activity (row numeric)
% sdfr : static long-term spectral distance (row numeric)
% ddfr : dynamic long-term spectral distance (row numeric)
% sdthresh : static distance threshold (scalar numeric)
% ddthresh : dynamic distance threshold (scalar numeric)
%
% SEE
% (2000) Burileanu, Pascalin, Burileanu, Puchiu : An Adaptive and Fast Speech Detection Algorithm
% (2003) Ramirez, Segura, Benitez, Torre, Rubio : A New Adaptive Long-Term Spectral Estimation Voice Activity Detector
% (2004) Ramirez, Segura, Benitez, Torre, Rubio : Voice Activity Detection with Long-Term Spectral Divergence Estimation
% (2005) Wu, Ren, Liu, Zhang : A Robust, Real-Time Voice Activity Detection Algorithm for Embedded Mobile Devices

		% safeguard
	if nargin < 1 || ~ismatrix( ft ) || ~isnumeric( ft ) || any( size( ft ) == 0 )
		error( 'invalid argument: ft' );
	end

	if nargin < 2 || ~ismatrix( noift ) || ~ismatrix( noift ) || any( size( noift ) == 0 ) || size( noift, 1 ) ~= size( ft, 1 )
		error( 'invalid argument: noift' );
	end

	if nargin < 3 || ~isscalar( ltadj ) || ~isnumeric( ltadj )
		error( 'invaid argument: ltadj' );
	end

	if nargin < 4 || ~isscalar( hang ) || ~isnumeric( hang ) || hang < 0
		error( 'invalid argument: hang' );
	end

		% transform to power spectra
	ftpow = ft .* conj( ft );
	noipow = noift .* conj( noift );

	noipowmu = mean( noipow, 2 ); % average noise

		% proceed signal frames
	nfrs = size( ft, 2 );

	sdfr = NaN( 1, nfrs ); % pre-allocation
	ddfr = NaN( 1, nfrs );

	for i = 1+ltadj:nfrs-ltadj

			% set spectral features
		ltpow = max( ftpow(:, i-ltadj:i+ltadj), [], 2 ); % long-term envelope

		sdfr(i) = sum( (ltpow - noipowmu).^2 ); % static distance

		tmp = zeros( size( ft, 1 ), 1 ); % dynamic distance (fall)
		for j = 1:ltadj
			tmp = tmp + (ftpow(:, i+j-1) - ftpow(:, i-j)).^2;
		end
		ddfr(i) = sum( tmp / ltadj );

	end

		% set feature thresholds and convert to log-scale
	sdmin = min( sdfr );
	sdmax = max( sdfr );
	lothresh = sdmin * (1 + 2*log10( sdmax/sdmin ));
	hithresh = lothresh + 0.25 * (mean( sdfr(sdfr >= lothresh) ) - lothresh);
	sdthresh = log( lothresh * hithresh ) / 2;

	ddmin = min( ddfr );
	ddmax = max( ddfr );
	lothresh = ddmin * (1 + 2*log10( ddmax/ddmin ));
	hithresh = lothresh + 0.25 * (mean( ddfr(ddfr >= lothresh) ) - lothresh);
	ddthresh = log( lothresh * hithresh ) / 2;

	sdfr = log( sdfr ); % scale conversion
	ddfr = log( ddfr );

		% set voice activity
	vapre = double( sdfr >= sdthresh & ddfr >= ddthresh ); % thresholding
	vafr = vapre;

	for i = 1:nfrs-1 % apply hangover
		if vapre(i) && ~vapre(i+1)
			hangstart = i + 1;
			hangstop = min( nfrs, i + hang );
			vafr(hangstart:hangstop) = 1;
		end
	end
	
end

