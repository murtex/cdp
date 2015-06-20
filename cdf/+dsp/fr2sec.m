function sec = fr2sec( fr, length, overlap, rate )
% frame number to position/seconds
%
% sec = FR2SEC( fr, length, overlap, rate )
%
% INPUT
% fr : frame number (numeric)
% length : frame length (scalar numeric)
% overlap : frame overlap (scalar numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% sec : position/seconds (numeric)

		% safeguard
	if nargin < 1 || ~isscalar( fr ) || ~isnumeric( fr )
		error( 'invalid argument: fr' );
	end

	if nargin < 2 || ~isscalar( length ) || ~isnumeric( length ) || length < 1
		error( 'invalid argument: length' );
	end

	if nargin < 3 || ~isscalar( overlap ) || ~isnumeric( overlap ) || overlap < 0 || overlap >= 1
		error( 'invalid argument: overlap' );
	end

	if nargin < 4 || ~isscalar( rate ) || ~isnumeric( rate ) || rate <= 0
		error( 'invalid argument: rate' );
	end

		% convert scale
	overlap = floor( overlap * length );
	stride = length - overlap;

	if mod( length, 2 ) == 0
		sec = dsp.smp2sec( (fr-1) * stride + ceil( length/2 ), rate );
	else
		sec = dsp.smp2sec( (fr-1) * stride + ceil( length/2 ) - 1, rate );
	end

end

