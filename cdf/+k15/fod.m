function fod( sd, freqs, rate, nformants, peakratio, peakgap, peakleap )
% formant-onset detector
%
% FOD( sd, nformants, peakratio, peakgap, peakleap )
% 
% INPUT
% sd : spectral decomposition (matrix numeric)
% freqs : frequencies (column numeric)
% rate : sampling rate (scalar numeric)
% nformants : number of formants (scalar numeric)
% peakratio : peak ratio (scalar numeric)
% peakgap : peak gap (scalar numeric)
% peakleap : peak leap (scalar numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( sd ) || ~isnumeric( sd )
		error( 'invalid argument: sd' );
	end

	if nargin < 2 || ~iscolumn( freqs ) || ~isnumeric( freqs ) || numel( freqs ) ~= size( sd, 1 )
		error( 'invalid argument: freqs' );
	end

	if nargin < 3 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 4 || ~isscalar( nformants ) || ~isnumeric( nformants )
		error( 'invalid argument: nformants' );
	end

	if nargin < 5 || ~isscalar( peakratio ) || ~isnumeric( peakratio )
		error( 'invalid argument: peakratio' );
	end

	if nargin < 6 || ~isscalar( peakgap ) || ~isnumeric( peakgap )
		error( 'invalid argument: peakgap' );
	end

	if nargin < 7 || ~isscalar( peakleap ) || ~isnumeric( peakleap )
		error( 'invalid argument: peakleap' );
	end

		% get peak series
	sdlen = size( sd, 2 );
	sdwidth = size( sd, 1 );

	sdmax = max( sd(:) );
	sdmin = min( sd(:) );
	pmin = sdmin + peakratio * (sdmax-sdmin);

	ps = NaN( 2*nformants, sdlen ); % pre-allocation

	for i = 1:sdlen
		p = sort( k15.m75( sd(:, i), peakratio ) );

		cj = 1; % stack peaks
		for j = 1:min( 2*nformants, numel( p ) )
			if sd(p(j), i) >= pmin
				ps(cj, i) = freqs(p(j));
				cj = cj + 1;
			end
		end
	end

		% set peak trajectories
	peakgap = dsp.sec2smp( peakgap, rate );

	trajs = cell( 0 ); % pre-allocation

	while true

			% set new trajectory start
		r = NaN;
		c = NaN;

		for i = 1:sdlen
			nnans = find( ~isnan( ps(:, i) ) );
			if ~isempty( nnans )
				c = i;
				r = nnans;
				if numel( r ) > 1
					r = randsample( r, 1 ); % choose random start
				end

				break;
			end
		end

		if isnan( r ) || isnan( c )
			break;
		end

			% start trajectory
		traj = [c, ps(r, c)];
		ps(r, c) = NaN;

			% continue trajectory
		gapc = 0;
		for i = c+1:sdlen
			if gapc > peakgap % break on too long gaps
				break;
			end

			pds = abs( ps(:, i) - traj(end, 2) ); % peak differences
			if ~any( pds <= peakleap )
				gapc = gapc + 1;
				continue;
			end

			gapc = 0; % append next nearest peak
			[~, nr] = min( pds );

			traj = cat( 1, traj, [i, ps(nr, i)] );
			ps(nr, i) = NaN;
		end

			% store trajectory
		trajs{end+1} = traj;

	end

		% remove too short trajectories
	dels = [];

	ntrajs = numel( trajs );
	for i = 1:ntrajs
		traj = trajs{i};
		if traj(end, 1) - traj(1, 1) + 1 < peakgap
			dels(end+1) = i;
		end
	end

	trajs(dels) = [];
	ntrajs = numel( trajs );

		% sort trajectories by length
	%lens = cellfun( @( x ) x(end, 1) - x(1, 1) + 1, trajs )
	%[~, order] = sort( lens, 'descend' )

	%tmp = trajs;
	%trajs = cell( 0 );
	%for i = 1:min( 2*nformants, ntrajs ) % reduce number of trajectories
		%trajs{i} = tmp{order(i)};
	%end

	%ntrajs = numel( trajs );

		% sort trajectories by median frequencies
	%mfreqs = cellfun( @( x ) median( x(:, 2) ), trajs );
	%[~, order] = sort( mfreqs, 'ascend' );

	%formants = cell( 0 );
	%for i = 1:min( nformants, ntrajs ) % set formants
		%formants{i} = trajs{order(i)};
	%end

		% DEBUG
	style = xis.hStyle.instance();
	fig = style.figure();

	xlim( dsp.smp2msec( [0, sdlen-1], rate ) );
	ylim( [min( freqs ), max( freqs )] );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % decomposition
	imagesc( dsp.smp2msec( 0:sdlen-1, rate ), freqs, sd );

	for i = 1:2*nformants % peaks
		scatter( dsp.smp2msec( 0:sdlen-1, rate ), ps(i, :), ...
			'.', 'MarkerEdgeColor', style.color( 'warm', 0 ) );
	end

	for i = 1:numel( trajs ) % trajectories
		traj = trajs{i};
		plot( dsp.smp2msec( traj(:, 1) - 1, rate ), traj(:, 2) );
	end

	%for i = 1:numel( formants ) % formants
		%formant = formants{i};
		%plot( dsp.smp2msec( formant(:, 1) - 1, rate ), formant(:, 2) );
	%end

	style.print( 'DEBUG.png' );
	delete( fig );

end

