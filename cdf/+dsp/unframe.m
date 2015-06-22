function uft = unframe( ft, length, overlap )
% unframe short-time fourier transform
% 
% uft = UNFRAME( ft, length, overlap )
%
% INPUT
% ft : signal frames fourier transform (matrix numeric)
% length : frame length (scalar numeric)
% overlap : frame overlap (scalar numeric)
%
% OUTPUT
% uft : unframed fourier transform (matrix numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( ft ) || ~isnumeric( ft )
		error( 'invalid argument: ft' );
	end

	if nargin < 2 || ~isscalar( length ) || ~isnumeric( length ) || length < 1
		error( 'invalid argument: length' );
	end

	if nargin < 3 || ~isscalar( overlap ) || ~isnumeric( overlap ) || overlap < 0 || overlap >= 1
		error( 'invalid argument: overlap' );
	end

		% accumulate expanded frames
	nfreqs = size( ft, 1 );
	nfrs = size( ft, 2 );

	overlap = floor( overlap * length );
	stride = length - overlap;

	uft = zeros( nfreqs, (nfrs-1)*stride + length ); % pre-allocation
	accs = zeros( 1, size( uft, 2 ) );

	frstarts = (0:nfrs-1)*stride + 1;
	frstops = frstarts + length - 1;

	for i = 1:nfrs
		for j = frstarts(i):frstops(i)
			uft(:, j) = uft(:, j) + ft(:, i);
			accs(j) = accs(j) + 1;
		end
	end

		% average accumulation
	n = size( uft, 2 );
	for i = 1:n
		uft(:, i) = uft(:, i) / accs(i);
	end

end

