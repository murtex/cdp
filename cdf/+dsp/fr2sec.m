function sec = fr2sec( fr, length, overlap, rate )
% frames to seconds
%
% sec = FR2SEC( fr, length, overlap, rate )
%
% INPUT
% fr : frame (numeric)
% length : short-time framing length (scalar numeric)
% overlap : short-time framing overlap (scalar numeric)
% rate : sampling rate (scalar numeric)
%
% OUTPUT
% sec : seconds (numeric)

		% safeguard
	if nargin < 1 || ~isnumeric( fr )
		error( 'invalid argument: fr' );
	end

	if nargin < 2 || ~isscalar( length ) || ~isnumeric( length )
		error( 'invalid argument: length' );
	end

	if nargin < 3 || ~isscalar( overlap ) || ~isnumeric( overlap )
		error( 'invalid argument: overlap' );
	end

	if nargin < 4 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

		% convert scalae
	overlap = floor( overlap * length ); % convert scale
	stride = length - overlap;

	sec = dsp.smp2sec( fr * stride, rate );

end

