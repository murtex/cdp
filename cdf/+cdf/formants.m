function formants( run, cfg, lab )
% track formant trajectories
%
% FORMANTS( run, cfg, lab )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% lab : labeled input flag (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( lab ) || ~islogical( lab )
		error( 'invalid argument: lab' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'track formant trajectories...' )

		% DEBUG
	if exist( 'debug/', 'dir' ) == 7
		rmdir( 'debug/', 's' );
	end

		% proceed trials
	ntrials = numel( run.trials );

	logger.progress();
	for i = 1:10 % [7, 8, 9, 10, 17, 19] % DEBUG
		trial = run.trials(i);
		resp = run.resps_det(i);

			% reset formants
		resp.f0 = [NaN, NaN];
		resp.f1 = [NaN, NaN];
		resp.f2 = [NaN, NaN];
		resp.f3 = [NaN, NaN];

			% set response signal
		if lab
			r = dsp.sec2smp( run.resps_lab(i).range, run.audiorate ) + [1, 0];
		else
			r = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0];
		end
		if any( isnan( r ) )
			logger.progress( i, ntrials );
			continue;
		end

		ts = run.audiodata(r(1):r(2), 1);

			% set spectral decomposition
		[sd, freqs] = dsp.fst( ts, run.audiorate, cfg.ftt_freqband(1), cfg.ftt_freqband(2), cfg.ftt_nfreqs );

		sd = pow2db( sd .* conj( sd ) + eps ); % decibel scale

		sdmin = min( sd(:) ); % normalization
		sdmax = max( sd(:) );
		sd = (sd - sdmin) / (sdmax - sdmin);

		sdlen = size( sd, 2 );

		%sd = sd .* conj( sd );
		%sdg = sd .^ cfg.ftt_gamma;
		%sd = log( sd + eps );
		%sdg = log( sdg + eps );

			% get peaks and link trajectories
		sdg = sd .^ cfg.ftt_gamma; % gamma correction

		nformants = 4;
		npeaks = 2 * nformants;
		peaks = NaN( npeaks, sdlen ); % pre-allocation

		for j = 1:sdlen
			p = sort( k15.m75( sdg(:, j), cfg.ftt_peakratio ) );

			n = min( npeaks, numel( p ) ); % stack peaks
			peaks(1:n, j) = freqs(p(1:n));
		end

		trajs = k15.traj( peaks, dsp.sec2smp( cfg.ftt_trajgap, run.audiorate ), cfg.ftt_trajleap );

			% trim fade-ins
		%tmptrajs = trajs;
		%trajs = cell( 0 );

		%for j = 1:numel( tmptrajs )
			%tmp = tmptrajs{j};

			%t = tmp(:, 1); % get (uncorrected) spectral values
			%f = tmp(:, 2);
			%fi = arrayfun( @( x ) find( freqs == x ), f );
			%is = sub2ind( size( sd ), fi, t );
			%sdvals = sd(is);

			%[sdvalmax, sdvalmaxi] = max( sdvals ); % get tail value-range
			%sdvalmin = min( sdvals(sdvalmaxi:end) );

			%dels = 1:find( sdvals(1:sdvalmaxi) < (sdvalmin+sdvalmax)/2, 1, 'last' ); % trim trajectory head
			%tmp(dels, :) = [];

			%if ~isempty( tmp )
				%trajs{end+1} = tmp;
			%end
		%end

			% remove stubs
		trajlens = cellfun( @( x ) x(end, 1)-x(1, 1)+1, trajs );
		trajs(trajlens < max( trajlens )/2) = [];

			% sort by median frequencies
		trajfreqs = cellfun( @( x ) median( x(:, 2) ), trajs );
		[~, order] = sort( trajfreqs );
		trajs = trajs(order);

			% DEBUG
		debugdir = sprintf( 'debug/%d/', i );
		if exist( debugdir, 'dir' ) == 7
			rmdir( debugdir, 's' );
		end
		mkdir( debugdir );
		logger.log( debugdir );
	
		style = xis.hStyle.instance();

			% DEBUG: formants
		fig = style.figure();

		xlabel( 'time in milliseconds' );
		ylabel( 'frequency in hertz' );

		xlim( dsp.smp2msec( [0, sdlen-1], run.audiorate ) );
		ylim( [min( freqs ), max( freqs )] );

		colormap( style.gradient( 256, [1, 1, 1], style.color( 'cold', -2 ) ) ); % decomposition
		imagesc( dsp.smp2msec( 0:sdlen-1, run.audiorate ), freqs, sd );

		%for j = 1:npeaks % peaks
			%scatter( dsp.smp2msec( 0:sdlen-1, run.audiorate ), peaks(j, :), ...
				%'.', 'MarkerEdgeColor', style.color( 'warm', 0 ) );
		%end

		for j = 1:numel( trajs ) % trajectories
			tmp = trajs{j};
			plot( dsp.smp2msec( tmp(:, 1)-1, run.audiorate ), tmp(:, 2), ...
				'Color', [237, 177, 32]/255.0 );
		end

		style.print( fullfile( 'debug/', sprintf( 'f_%d.png', i ) ) );
		style.print( fullfile( debugdir, sprintf( 'f_%d.png', i ) ) );
		delete( fig );

			% DEBUG: formants (gamma)
		fig = style.figure();

		xlabel( 'time in milliseconds' );
		ylabel( 'frequency in hertz' );

		xlim( dsp.smp2msec( [0, sdlen-1], run.audiorate ) );
		ylim( [min( freqs ), max( freqs )] );

		colormap( style.gradient( 256, [1, 1, 1], style.color( 'cold', -2 ) ) ); % decomposition
		imagesc( dsp.smp2msec( 0:sdlen-1, run.audiorate ), freqs, sdg );

		for j = 1:npeaks % peaks
			scatter( dsp.smp2msec( 0:sdlen-1, run.audiorate ), peaks(j, :), ...
				'.', 'MarkerEdgeColor', style.color( 'warm', 0 ) );
		end

		for j = 1:numel( trajs ) % trajectories
			tmp = trajs{j};
			plot( dsp.smp2msec( tmp(:, 1)-1, run.audiorate ), tmp(:, 2), ...
				'Color', [237, 177, 32]/255.0 );
		end

		style.print( fullfile( 'debug/', sprintf( 'f_%d-g.png', i ) ) );
		style.print( fullfile( debugdir, sprintf( 'f_%d-g.png', i ) ) );
		delete( fig );

			% DEBUG: trajectories
		for j = 1:numel( trajs )
			fig = style.figure();

			xlabel( 'time in milliseconds' );
			ylabel( 'spectral value' );

			xlim( dsp.smp2msec( [0, sdlen-1], run.audiorate ) );
			ylim( [0, 1] );

			tmp = trajs{j};
			t = tmp(:, 1);
			f = tmp(:, 2);
			fi = arrayfun( @( x ) find( freqs == x ), f );
			is = sub2ind( size( sd ), fi, t );
			sdvals = sd(is);

			plot( dsp.smp2msec( t-1, run.audiorate ), sdvals, ...
				'Color', style.color( 'warm', 0 ) );

			style.print( fullfile( debugdir, sprintf( 'f_%d-t_%d.png', i, j ) ) );
			delete( fig );
		end

		logger.progress( i, ntrials );
	end

	logger.untab();
end

