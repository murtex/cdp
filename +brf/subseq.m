function subser = subseq( featser, intlen, intcount )
% generate subsequences and features
%
% subser = SUBSEQ( featser, intlen, intcount )
%
% INPUT
% featser : prime features time series (matrix numeric)
% intlen : minimum interval length (scalar numeric)
% intcount : number of intervals (scalar numeric)
%
% OUTPUT
% subser : series of subsequence features (numeric)

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

		% set number of subsequences
	m = size( featser, 1 ); % time series length
	n = size( featser, 2 ); % number of prime features

	r = floor( m / intlen );
	subs = r - intcount;
	if subs < 1
		subser = []; % no subdivision possible
		return;
	end

		% proceed subsequences
	nlocfeats = 2; % number of location features
	nintfeats = 3; % number of interval features

	subser = NaN( subs, nlocfeats + n*(2 + nintfeats*intcount) ); % pre-allocation

	for i = 1:subs

			% choose random endpoints (restricted by interval length)
		rndintlen = randi( [intlen, floor( m / intcount )], 1, 1 );
		t1 = randi( m - intcount*rndintlen + 1, 1, 1 );
		t2 = t1 + intcount*rndintlen - 1;

		intstarts = t1:rndintlen:t2; % interval indices
		intstops = t1+rndintlen-1:rndintlen:t2;

		vand = [ones( rndintlen, 1 ), (1:rndintlen)']; % regression matrix

			% set location features
		subser(i, 1) = (t1-1)/(m-1);
		subser(i, 2) = (t2-1)/(m-1);

			% proceed prime features
		for j = 1:n
			seqser = featser(t1:t2, j);
			ji = 2 + (j-1)*(2 + nintfeats*intcount);

				% set sequence features
			subser(i, ji+1) = mean( seqser, 1 );
			subser(i, ji+2) = var( seqser, 1, 1 );

				% proceed intervals
			for k = 1:intcount
				intser = featser(intstarts(k):intstops(k), j);
				ki = ji + 2 + (k-1)*nintfeats;

					% set interval features
				subser(i, ki+1) = mean( intser, 1 );
				subser(i, ki+2) = var( intser, 1, 1 );

				p = vand \ intser;
				subser(i, ki+3) = p(2);

			end

		end

	end

end

