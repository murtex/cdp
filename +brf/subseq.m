function subser = subseq( featser, intlen, intcount )
% generate subsequential features
%
% subser = SUBSEQ( featser, intlen, intcount )
%
% INPUT
% featser : feature time series (matrix numeric)
% intlen : minimum interval length (scalar numeric)
% intcount : number of intervals (scalar numeric)
%
% OUTPUT
% subser : series of sequential features (numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( featser ) || ~isnumeric( featser )
		error( 'invalid argument: featser' );
	end

	if nargin < 2 || ~isscalar( intlen ) || ~isnumeric( intlen )
		error( 'invalid argument: intlen' );
	end

	if nargin < 3 || ~isscalar( intcount ) || ~isnumeric( intcount )
		error( 'invalid argument: intcount' );
	end

		% set number of sequences
	m = size( featser, 1 ); % length
	n = size( featser, 2 ); % features

	r = floor( m / intlen );
	subs = r - intcount;
	if subs < 1
		subser = []; % no subdivision possible
		return;
	end

		% proceed sequences
	subser = NaN( subs, 4 + 3*intcount, n ); % pre-allocation

	for i = 1:subs

			% choose random endpoints
		rndintlen = randi( [intlen, floor( m / intcount )], 1, 1 );
		t1 = randi( m - intcount*rndintlen + 1, 1, 1 );
		t2 = t1 + intcount*rndintlen - 1;

			% set sequence features
		subser(i, 1, :) = (t1-1)/(m-1) * ones( 1, n ); % relative endpoints
		subser(i, 2, :) = (t2-1)/(m-1) * ones( 1, n );
		subser(i, 3, :) = mean( featser(t1:t2, :), 1 ); % statistics
		subser(i, 4, :) = var( featser(t1:t2, :), 1, 1 );

			% proceed intervals
		vand = [ones( rndintlen, 1 ), (1:rndintlen)'];

		starts = t1:rndintlen:t2;
		stops = t1+rndintlen-1:rndintlen:t2;

		for j = 1:intcount
			ji = 4 + 3*(j-1);

				% set interval features
			intser = featser(starts(j):stops(j), :);

			subser(i, ji+1, :) = mean( intser, 1 ); % statistics
			subser(i, ji+2, :) = var( intser, 1, 1 );

				% absolute slopes
			for k = 1:n
				p = vand \ intser(:, k);
				subser(i, ji+3, k) = p(2);
			end

		end

	end

end

