function pp = peak_glottis( p, pow, ror, schwalen, schwapow )
% pair and validate glottis peaks
%
% pp = PEAK_GLOTTIS( p, pow, ror, schwalen, schwapow )
%
% INPUT
% p : peak indices (vector numeric)
% pow : subband power (vector numeric)
% ror : rate-of-rise (vector numeric)
% schwalen : schwa length (scalar numeric)
% schwapow : relative schwa power (scalar numeric)
%
% OUTPUT
% pp : sorted paired peak indices (vector numeric)

		% safeguard
	if nargin < 1 || (~isempty( p ) && ~isvector( p )) || ~isnumeric( p )
		error( 'invalid argument: p' );
	end

	if nargin < 2 || ~isvector( pow ) || ~isnumeric( pow )
		error( 'invalid argument: pow' );
	end

	if nargin < 3 || ~isvector( ror ) || ~isnumeric( ror ) || numel( ror ) ~= numel( pow )
		error( 'invalid argument: ror' );
	end

	if nargin < 4 || ~isscalar( schwalen ) || ~isnumeric( schwalen )
		error( 'invalid argument: schwalen' );
	end

	if nargin < 5 || ~isscalar( schwapow ) || ~isnumeric( schwapow )
		error( 'invalid argument: schwapow' );
	end

		% prepare peaks
	if isempty( p )
		pp = [];
		return;
	end

	p = sort( p );
	sgn = 2*((ror(p) > 0)-0.5);

	if p(1) == 1 && sgn(1) < 0 % never start directly with -peak
		p(1) = [];
		sgn(1) = [];
	end
	if p(end) == numel( ror ) && sgn(end) > 0 % never end directly with +peak
		p(end) = [];
		sgn(end) = [];
	end

		% align peaks
	pp = []; % pre-allocations

	n = numel( p );
	for i = 1:n-1

			% always start with +peak
		if i == 1 && sgn(i) < 0
			r = 1:p(i)-1;
			[~, pp(end+1)] = max( ror(r) ); % insert +peak
		end
		pp(end+1) = p(i);

			% pair consecutive peaks of same sign
		if sgn(i) == sgn(i+1)
			r = p(i)+1:p(i+1)-1;
			if sgn(i) > 0
				[~, pp(end+1)] = min( ror(r) ); % insert -peak
			else
				[~, pp(end+1)] = max( ror(r) ); % insert +peak
			end
			pp(end) = pp(end) + p(i);
		end
	end

	pp(end+1) = p(end); % always end with -peak
	if sgn(end) > 0
		r = p(end)+1:numel( ror );
		[~, pp(end+1)] = min( ror(r) ); % insert -peak
		pp(end) = pp(end) + p(end);
	end

		% delete low-powered +/-pairs
	thresh = max( pow ) + schwapow;

	del = []; % pre-allocation

	n = numel( pp )/2;
	for i = 1:n
		r = pp(2*i-1):pp(2*i);
		if sum( pow(r) >= thresh ) < schwalen
			del(end+1) = 2*i-1;
			del(end+1) = 2*i;
		end
	end

	pp(del) = [];

end

