function [vafr, featfr, threshs] = vad( ft, noift, ltadj, hang )
% voice activity detector
%
% [vafr, featfr, threshs] = VAD( ft, noift, ltadj, hang )
%
% INPUT
% ft : signal frames fourier transform (matrix numeric)
% noift : noise frames fourier transform (matrix numeric)
% ltadj : long-term adjacency (scalar numeric)
% hang : activity hangover (scalar numeric)
%
% OUTPUT
% vafr : voice activity (row numeric)
% featfr : detection features (matrix numeric)
% threshs : feature thresholds (column numeric)
%
% SEE
% (2000) Burileanu, Pascalin, Burileanu, Puchiu : An Adaptive and Fast Speech Detection Algorithm
% (2002) Venkatesha Prasad, Sangwan, Jamadagni, Chiranti, Sah, Gaurav : Comparison of Voice Activity Detection Algorithms for VoIP
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

		% convert to power spectra
	ft = ft .* conj( ft );

	noift = noift .* conj( noift );
	noimu = mean( noift, 2 ); % average

		% proceed signal frames
	nfreqs = size( ft, 1 );
	nfrs = size( ft, 2 );

	f1fr = NaN( 1, nfrs ); % pre-allocation
	f3fr = NaN( 1, nfrs );
	f2fr = NaN( 1, nfrs );
	f4fr = NaN( 1, nfrs );

	dyn1diff = zeros( nfreqs, 2*ltadj );
	dyn1norm = 2*ltadj; % 2*sum( 1 ./ [1:ltadj] );

	dyn2diff = zeros( nfreqs, ltadj );
	dyn2norm = ltadj; % sum( 1 ./ [1:ltadj] )/2;

	for i = 1+ltadj:nfrs-ltadj

			% set long-term spectra
		ltenv = max( ft(:, i-ltadj:i+ltadj), [], 2 ); % envelope
		ltmu = mean( ft(:, i-ltadj:i+ltadj), 2 ); % average

			% set spectral differences
		ltenvdiff = ltenv - noimu;
		ltmudiff = ltmu - noimu;

			% set detection features
		f1fr(i) = sqrt( sum( ltmudiff.^2 ) ); % static distance
		f2fr(i) = abs( std( ltmu, 1 ) - std( noimu, 1 ) ); % flatness

		for j = 1:ltadj % (weighted) dynamic distance
			dyn1diff(:, j) = (ft(:, i) - ft(:, i-j)); % / j;
			dyn1diff(:, ltadj+j) = (ft(:, i+j) - ft(:, i)); % / j;
			dny2diff(:, j) = (ft(:, i+j) - ft(:, i-j)); % / (2*(ltadj-j+1));
		end
		f3fr(i) = sum( sqrt( sum( dyn1diff.^2, 1 ) ) ) / dyn1norm;
		f4fr(i) = sum( sqrt( sum( dny2diff.^2, 1 ) ) ) / dyn2norm;

	end

	f5fr = (f1fr + f2fr + f3fr + f4fr) / 4; % weighted sum

		% set feature thresholds and convert to log-scale
	f1fr(f1fr < eps) = eps; % prepare for log scale
	f3fr(f3fr < eps) = eps;
	f2fr(f2fr < eps) = eps;
	f4fr(f4fr < eps) = eps;
	f5fr(f5fr < eps) = eps;

	f1min = min( f1fr ); % set thresholds
	f1max = max( f1fr );
	lothresh = f1min * (1 + 2*log10( f1max/f1min ));
	hithresh = lothresh + 0.25 * (mean( f1fr(f1fr >= lothresh) ) - lothresh);
	f1thresh = log( lothresh * hithresh ) / 2;

	f2min = min( f2fr );
	f2max = max( f2fr );
	lothresh = f2min * (1 + 2*log10( f2max/f2min ));
	hithresh = lothresh + 0.25 * (mean( f2fr(f2fr >= lothresh) ) - lothresh);
	f2thresh = log( lothresh * hithresh ) / 2;

	f3min = min( f3fr );
	f3max = max( f3fr );
	lothresh = f3min * (1 + 2*log10( f3max/f3min ));
	hithresh = lothresh + 0.25 * (mean( f3fr(f3fr >= lothresh) ) - lothresh);
	f3thresh = log( lothresh * hithresh ) / 2;

	f4min = min( f4fr );
	f4max = max( f4fr );
	lothresh = f4min * (1 + 2*log10( f4max/f4min ));
	hithresh = lothresh + 0.25 * (mean( f4fr(f4fr >= lothresh) ) - lothresh);
	f4thresh = log( lothresh * hithresh ) / 2;

	f5thresh = (f1thresh + f2thresh + f3thresh + f4thresh) / 4; % weighted sum

	f1fr = log( f1fr ); % scale conversion
	f2fr = log( f2fr );
	f3fr = log( f3fr );
	f4fr = log( f4fr );
	f5fr = log( f5fr );

		% prepare voice activity
	vapre = 2*(f1fr >= f1thresh) + 2*(f2fr >= f2thresh) + (f3fr >= f3thresh) + (f4fr >= f4thresh) + ...
		(f5fr >= f5thresh) >= 3; % apply weighted thresholds
	vafr = vapre;

	%for i = 1:nfrs-1 % apply hangover
		%if vapre(i) && ~vapre(i+1)
			%hangstart = i + 1;
			%hangstop = min( nfrs, i + hang );
			%vafr(hangstart:hangstop) = true;
		%end
	%end

		% set output
	vafr = double( vafr );
	
	featfr = cat( 1, f1fr, f2fr, f3fr, f4fr, f5fr );
	threshs = cat( 1, f1thresh, f2thresh, f3thresh, f4thresh, f5thresh );

end

