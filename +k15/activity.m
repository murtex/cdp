function [actser, lothresh, hithresh] = activity( ser, clser )
% adaptive activity detection
%
% [actser, lothresh, hithresh] = ACTIVITY( ser, clser )
%
% INPUT
% ser : noisy time series (vector numeric)
% clser : clean time series (vector numeric)
%
% OUTPUT
% actser : activity series (vector logical)
% lothresh : lower activity threshold (scalar numeric)
% hithresh : upper activity threshold (scalar numeric)

		% safeguard
	if nargin < 1 || ~isvector( ser ) || ~isnumeric( ser )
		error( 'invalid argument: ser' );
	end

	if nargin < 2 || ~isvector( clser ) || ~isnumeric( clser ) || numel( clser ) ~= numel( ser )
		error( 'invalid argument: clser' );
	end

		% try to call mex-version (once)
	persistent mexified;

	if isempty( mexified )

			% get current module path
		[st, i] = dbstack( '-completenames' );
		[path, ~, ~] = fileparts( st(i).file );

			% compile mex-source
		src = fullfile( path, 'activity_mex.cpp' );
		ret = mex( src, '-silent', '-outdir', path );

		mexified = ~ret;
	end

	if mexified
		[actser, lothresh, hithresh] = k15.activity_mex( ser, clser ); % call mex-version
		return;
	end

		% MATLAB FALLBACK IMPLEMENTATION

		% set adaptive thresholds
	sermin = min( ser );
	sermax = max( ser );
	lothresh = sermin * (1+2*log10( sermax/sermin )); % based on noisy data
	hithresh = lothresh + 0.25*(mean( clser(clser >= lothresh) )-lothresh); % based on clean data

		% set activity
	n = numel( clser );

	actser = false( size( clser ) ); % pre-allocation

	state = 1;
	statelen = 0;

	for i = 1:n
		switch state

			case 1 % no activity
				if clser(i) >= lothresh % start potential activity
					state = 2;
					statelen = 0;
				end

			case 2 % potential activity
				if clser(i) >= hithresh % assured past/current activity
					actser(i-statelen:i) = true;
					state = 3;
					statelen = 0;
				elseif clser(i) < lothresh % denied activity
					state = 1;
					statelen = 0;
				end

			case 3 % assured activity
				if clser(i) < lothresh % stop activity
					state = 1;
					statelen = 0;
				else
					actser(i) = true;
				end

		end

		statelen = statelen+1;
	end

end

