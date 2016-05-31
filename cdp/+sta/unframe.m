function ser = unframe( ser, frame )
% short-time un-framing
%
% ser = UNFRAME( ser, frame )
%
% INPUT
% ser : time series (numeric)
% frame : frame length and stride (pair numeric)
%
% OUTPUT
% ser : unframed time series (numeric)

		% TODO: support multi-dimensional arrays!
	if ~ismatrix( ser )
		error( 'invalid argument: ser' );
	end

	overlap = frame(1)-frame(2);

		% try to call mex-version (once)
	persistent mexified;

	if isempty( mexified )

			% get current module path
		[st, i] = dbstack( '-completenames' );
		[path, ~, ~] = fileparts( st(i).file );

			% compile mex-source
		src = fullfile( path, 'expand_mex.cpp' );
		ret = mex( src, '-outdir', path );

		mexified = ~ret;
	end

	if mexified
		ser = sta.expand_mex( ser, frame ); % call mex-version

	else

			% MATLAB FALLBACK IMPLEMENTATION

			% expand frames
		ser = kron( ser, ones( frame(2), 1 ) );
		ser(end+1:end+overlap, :) = repmat( ser(end, :), overlap, 1 );

			% center frames
		f2 = floor( frame(1)/2 );
		ser = cat( 1, repmat( ser(1, :), f2, 1 ), ser );
		ser(end-f2+1:end, :) = [];

	end

		% smoothing
	%kernel = fspecial( 'average', [2*overlap + 1, 1] );
	kernel = ones( 2*overlap + 1, 1 ) / (2*overlap + 1);

	n = size( ser, 2 );
	if n >= 8 % parallelize if worthy
		parfor (i = 1:n, 4)
			ser(:, i) = filter2( kernel, ser(:, i) );
		end
	else
		ser = filter2( kernel, ser );
	end


end

