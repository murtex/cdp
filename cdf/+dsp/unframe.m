function ufr = unframe( fr, length, overlap )
% unframe short-time frames
% 
% ufr = UNFRAME( fr, length, overlap )
%
% INPUT
% fr : signal frames (matrix numeric)
% length : frame length (scalar numeric)
% overlap : frame overlap (scalar numeric)
%
% OUTPUT
% ufr : unframed frames (matrix numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( fr ) || ~isnumeric( fr ) || any( size( fr ) == 0 )
		error( 'invalid argument: fr' );
	end

	if nargin < 2 || ~isscalar( length ) || ~isnumeric( length ) || length < 1
		error( 'invalid argument: length' );
	end

	if nargin < 3 || ~isscalar( overlap ) || ~isnumeric( overlap ) || overlap < 0 || overlap >= 1
		error( 'invalid argument: overlap' );
	end

		% accumulate expanded frames
	nvals = size( fr, 1 );
	nfrs = size( fr, 2 );

	overlap = floor( overlap * length );
	stride = length - overlap;

	ufr = zeros( nvals, (nfrs-1)*stride + length ); % pre-allocation
	accs = zeros( 1, size( ufr, 2 ) );

	frstarts = (0:nfrs-1)*stride + 1;
	frstops = frstarts + length - 1;

	for i = 1:nfrs
		for j = frstarts(i):frstops(i)
			ufr(:, j) = ufr(:, j) + fr(:, i);
			accs(j) = accs(j) + 1;
		end
	end

		% average accumulation
	n = size( ufr, 2 );
	for i = 1:n
		ufr(:, i) = ufr(:, i) / accs(i);
	end

end

