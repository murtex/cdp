function asi = scs05( ser, vic, sigma )
% get activity start by statistics
%
% asi = SCS05( ser, vic, sigma )
%
% INPUT
% ser : time series (vector numeric)
% vic : forward vicinity to check (scalar numeric)
% sigma : standard deviation threshold (scalar numeric)
%
% OUTPUT
% asi : activity start index (scalar numeric)

		% safeguard
	if nargin < 1 || ~isvector( ser ) || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isscalar( vic ) || ~isnumeric( vic )
		error( 'invalid argument: vic' );
	end

	if nargin < 3 || ~isscalar( sigma ) || ~isnumeric( sigma )
		error( 'invalid argument: sigma' );
	end

		% try to call mex-version (once)
	persistent mexified;

	if isempty( mexified )

			% get current module path
		[st, i] = dbstack( '-completenames' );
		[path, ~, ~] = fileparts( st(i).file );

			% compile mex-source
		src = fullfile( path, 'scs05_mex.cpp' );
		ret = mex( src, '-silent', '-outdir', path );

		mexified = ~ret;
	end

	if mexified
		asi = k15.scs05_mex( ser, vic, sigma ); % call mex-version
		return;
	end

		% MATLAB FALLBACK IMPLEMENTATION

	asi = NaN; % pre-allocation

		% use series itself as noise estimation
	sermu = mean( ser );
	sersigma = std( ser, 1 );

		% proceed series values
	n = numel( ser );
	for i = 1:n

			% get mean mahalanobis distance of forward vicinity
		vicr = i:min( n, i+vic );
		mmd = sum( abs( ser(vicr)-sermu ) ) / sersigma / vic;

			% check against sigma-threshold
		if mmd >= sigma
			asi = i;
			break;
		end

	end

end

