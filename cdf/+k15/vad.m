function [sdiv, threshs, vact] = vad( sd, noisd )
% voice activity detection
%
% [sdiv, threshs, vact] = VAD( sd, noisd )
%
% INPUT
% sd : signal spectral decompisition (matrix numeric)
% noisd : noise spectral decomposition (matrix numeric)
%
% OUTPUT
% sdiv : spectral divergence (row numeric)
% threshs : activity thresholds [lower, upper] (row numeric)
% vact : voice activity (row logical)
%
% SEE
% (2000) Burileanu, Pascalin, Burileanu, Puchiu : An Adaptive and Fast Speech Detection Algorithm
% (2003) Ramirez, Segura, Benitez, Torre, Rubio : A New Adaptive Long-Term Spectral Estimation Voice Activity Detector
% (2004) Ramirez, Segura, Benitez, Torre, Rubio : Voice Activity Detection with Long-Term Spectral Divergence Estimation
%
% TODO
% weight divergence by babbling spectrum or loudness curve?

		% safeguard
	if nargin < 1 || ~ismatrix( sd ) || ~isnumeric( sd )
		error( 'invalid argument: sd' );
	end

	if nargin < 2 || ~ismatrix( noisd ) || ~isnumeric( noisd ) || size( noisd, 1 ) ~= size( sd, 1 )
		error( 'invalid argument: noisd' );
	end

		% set spectral divergence
	sdlen = size( sd, 2 );

	sd = sd .* conj( sd ); % power scale
	noisd = noisd .* conj( noisd );

	noisd = mean( noisd, 2 ); % average noise

	sdiv = zeros( 1, sdlen ); % pre-allocation

	for i = 1:sdlen
		sdiv(i) = mean( sd(:, i).^2 ./ noisd.^2 ); % TODO: vectorize!
	end

		% set thresholds
	sdivmin = min( sdiv );
	sdivmax = max( sdiv );

	lothresh = sdivmin * (1 + 2*log10( sdivmax/sdivmin + eps ));
	hithresh = lothresh + 0.25 * (mean( sdiv(sdiv >= lothresh) ) - lothresh);

	threshs = [lothresh, hithresh];

		% convert to log scale
	sdiv = pow2db( sdiv + eps );
	threshs = pow2db( threshs + eps );

		% set activity
	vact = false( size( sdiv ) ); % pre-allocation

	state = 1;
	statelen = 0;

	for i = 1:sdlen
		switch state

			case 1 % no activity
				if sdiv(i) >= threshs(1) % start potential activity
					state = 2;
					statelen = 0;
				end

			case 2 % potential activity
				if sdiv(i) >= threshs(2) % assure activity
					vact(i-statelen:i) = true;
					state = 3;
					statelen = 0;
				elseif sdiv(i) < threshs(1) % deny activity
					state = 1;
					statelen = 0;
				end

			case 3 % assured activity
				if sdiv(i) < threshs(1) % stop activity
					state = 1;
					statelen = 0;
				else % continue activity
					vact(i) = true;
				end

		end

		statelen = statelen + 1;
	end

end

