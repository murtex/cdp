function ftt( sd, freqs, rate, nformants, peakratio, peakgap, peakleap )
% formant trajectory tracker
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

	npeaks = 2*nformants;
	peaks = NaN( npeaks, sdlen ); % pre-allocation

	for i = 1:sdlen
		p = sort( k15.m75( sd(:, i), peakratio ) );

		cj = 1; % stack peaks
		for j = 1:min( npeaks, numel( p ) )
			if sd(p(j), i) >= pmin
				peaks(cj, i) = freqs(p(j));
				cj = cj + 1;
			end
		end
	end

		% set fundamental trajectory (assuming lowest continuous peak series)
	traj0 = k15.traj( peaks(1, :), dsp.sec2smp( peakgap, rate ), peakleap );
	traj0lens = cellfun( @( x ) x(end, 1)-x(1, 1)+1, traj0 );

	[traj0len, i] = max( traj0lens ); % keep longest trajectory
	traj0 = traj0{i};

		% set formant trajectories
	trajs = k15.traj( peaks(2:end, :), dsp.sec2smp( peakgap, rate ), peakleap );
	trajlens = cellfun( @( x ) x(end, 1)-x(1, 1)+1, trajs );

	dels = trajlens < dsp.sec2smp( peakgap, rate ); % remove too shorts
	trajs(dels) = [];

	dels = []; % remove non voicings
	for i = 1:numel( trajs )
		tmp = trajs{i};
		if tmp(end, 1) < traj0(1, 1) || tmp(1, 1) > traj0(end, 1)
			dels(end+1) = i;
		end
	end
	trajs(dels) = [];

	%trajfreqs = cellfun( @( x ) median( x(:, 2) ), trajs ); % sort median frequencies
	%[~, order] = sort( trajfreqs, 'ascend' );

	%tmp = trajs; % keep formants only
	%trajs = cell( 0 );
	%for i = 1:min( nformants-1, numel( tmp ) )
		%trajs{i} = tmp{order(i)};
	%end

		% DEBUG
	style = xis.hStyle.instance();
	fig = style.figure();

	xlim( dsp.smp2msec( [0, sdlen-1], rate ) );
	ylim( [min( freqs ), max( freqs )] );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % decomposition
	imagesc( dsp.smp2msec( 0:sdlen-1, rate ), freqs, sd );

	%for i = 1:npeaks % peaks
		%scatter( dsp.smp2msec( 0:sdlen-1, rate ), peaks(i, :), ...
			%'.', 'MarkerEdgeColor', style.color( 'warm', 0 ) );
	%end

	plot( dsp.smp2msec( traj0(:, 1), rate ), traj0(:, 2), ... % fundamental trajectory
		'Color', style.color( 'warm', 0 ) );

	for i = 1:numel( trajs ) % formant trajectories
		tmp = trajs{i};
		plot( dsp.smp2msec( tmp(:, 1), rate ), tmp(:, 2), ...
			'Color', style.color( 'warm', 0 ) );
	end

	style.print( 'DEBUG.png' );
	delete( fig );

end

