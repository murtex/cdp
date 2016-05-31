function pp = peakg( p, pow, ror, schwalen, schwapow )
% pair and validate glottis peaks
%
% pp = PEAKG( p, pow, ror, schwalen, schwapow )
%
% INPUT
% p : peak indices (column numeric)
% pow : subband power (vector numeric)
% ror : rate-of-rise (vector numeric)
% schwalen : schwa length (scalar numeric)
% schwapow : relative schwa power (scalar numeric)
%
% OUTPUT
% pp : sorted paired peak indices (vector numeric)

		% safeguard
	if nargin < 1 || (~isempty( p ) && ~iscolumn( p )) || ~isnumeric( p )
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

		% sort peak order
	p = sort( p );

		% always start with +peak
	while numel( p ) > 0 && ror(p(1)) < 0
		[vmax, imax] = max( ror(1:p(1)) );
		if vmax > 0
			p = cat( 1, imax-1+1, p );
		else
			p = p(2:end);
		end
	end

		% always end with -peak
	while numel( p ) > 0 && ror(p(end)) > 0
		[vmin, imin] = min( ror(p(end):end) );
		if vmin < 0
			p = cat( 1, p, imin-1+p(end) );
		else
			p = p(1:end-1);
		end
	end

		% try to insert pairing peaks
	pp = []; % pre-allocation

	for i = 1:numel( p )-1
		pp(end+1) = p(i);

		if ror(p(i)) < 0 && ror(p(i+1)) < 0 % consecutive -peaks
			[vmax, imax] = max( ror(p(i):p(i+1)) );
			if vmax > 0 % insert +peak
				pp(end+1) = imax-1+p(i);
			end
		elseif ror(p(i)) > 0 && ror(p(i+1)) > 0 % consecutive +peaks
			[vmin, imin] = min( ror(p(i):p(i+1)) );
			if vmin < 0 % insert -peak
				pp(end+1) = imin-1+p(i);
			end
		end

		pp(end+1) = p(i+1);
	end

		% remove weakest consecutive peaks
	i = 1;
	while numel( pp ) > i
		if ror(pp(i)) < 0 && ror(pp(i+1)) < 0 % consecutive -peaks
			if ror(pp(i)) >= ror(pp(i+1)) % remove weakest/first
				pp(i) = [];
			else
				pp(i+1) = [];
			end
			continue;
		elseif ror(pp(i)) > 0 && ror(pp(i+1)) > 0 % consecutive +peaks
			if ror(pp(i)) <= ror(pp(i+1)) % remove weakest/first
				pp(i) = [];
			else
				pp(i+1) = [];
			end
			continue;
		end

		i = i+1;
	end

		% remove peaks based on schwa settings
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

