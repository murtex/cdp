function pp = peakg( p, pow, ror, schwalen, schwapow )
% validate and pair glottal candidate peaks
%
% pp = PEAKG( p, pow, ror, schwalen, schwapow )
%
% INPUT
% p : (candidate) peak indices (column numeric)
% pow : subband power (vector numeric)
% ror : rate-of-rise (vector numeric)
% schwalen : schwa length (scalar numeric)
% schwapow : relative schwa power (scalar numeric)
%
% OUTPUT
% pp : paired glottal peak indices (vector numeric)

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

		% pair candidate peaks
	p = sort( p );

	pp = [];
	for i = 1:numel( p )-1
		pp(end+1) = p(i); % accept current peak

		insrange = p(i)+1:p(i+1)-1;
		if ror(p(i)) <= 0 && ror(p(i+1)) <= 0 % insert +peak between consecutive -peaks
			[~, insindex] = max( ror(insrange) );
			pp(end+1) = p(i) + insindex; % unconditional insertion

		elseif ror(p(i)) >= 0 && ror(p(i+1)) >= 0 % insert -peak between consecutive +peaks
			[~, insindex] = min( ror(insrange) );
			pp(end+1) = p(i) + insindex; % unconditional insertion

		end
	end

	if numel( p ) > 1 % accept last peak
		pp(end+1) = p(end);
	end

		% validate peak margins
	while numel( pp ) > 0 && ror(pp(1)) <= 0 % start with +peak
		pp(1) = [];
	end

	if numel( pp ) > 0 && ror(pp(end)) >= 0 % stop with -peak
		[~, insindex] = min( ror(pp(end)+1:end) );
		if ~isempty( insindex )
			pp(end+1) = pp(end) + insindex; % unconditional insertion
		end
	end

	while numel( pp ) > 0 && ror(pp(end)) >= 0
		pp(end) = [];
	end

end

