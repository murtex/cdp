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

		% compile mex-file (once)
	persistent compile;

	if isempty( compile )
		[st, i] = dbstack( '-completenames' ); % get current module path
		[path, ~, ~] = fileparts( st(i).file );
		src = fullfile( path, 'scs05_mex.cpp' ); % compile mex-file
		mex( src, '-outdir', path );
		compile = false; % never check again
	end

	asi = k15.scs05_mex( ser, vic, sigma );

	return;

		% DO NOT CALL ANY CODE BELOW!
		% MATLAB TEMPLATE FOR MEX-FILE

	asi = NaN; % pre-allocation

	sermu = mean( ser ); % use series itself as noise estimation
	sersigma = std( ser, 1 );

	n = numel( ser ); % proceed series values
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

