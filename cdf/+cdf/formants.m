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

		% proceed trials
	ntrials = numel( run.trials );
	nvaltrials = 0;

	logger.progress();
	for i = 1:ntrials
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
			rstart = run.resps_lab(i).range(1);
		else
			r = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0];
			rstart = resp.range(1);
		end
		if any( isnan( r ) )
			logger.progress( i, ntrials );
			continue;
		end

		ts = run.audiodata(r(1):r(2), 1);
		nvaltrials = nvaltrials + 1;

			% set spectral decomposition
		[sd, freqs] = dsp.fst( ts, run.audiorate, cfg.ftt_freqband(1), cfg.ftt_freqband(2), cfg.ftt_nfreqs );

		sd = pow2db( sd .* conj( sd ) + eps ); % decibel scale

		sdmin = min( sd(:) ); % normalization
		sdmax = max( sd(:) );
		sd = (sd - sdmin) / (sdmax - sdmin);

		sdlen = size( sd, 2 );

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
		tmptrajs = trajs;
		trajs = cell( 0 );

		for j = 1:numel( tmptrajs )
			tmp = tmptrajs{j};

			t = tmp(:, 1); % get (uncorrected) spectral values
			f = tmp(:, 2);
			fi = arrayfun( @( x ) find( freqs == x ), f );
			is = sub2ind( size( sd ), fi, t );
			sdvals = sd(is);

			[sdvalmax, sdvalmaxi] = max( sdvals ); % get tail value-range
			sdvalmin = min( sdvals(sdvalmaxi:end) );

			dels = 1:find( sdvals(1:sdvalmaxi) < (sdvalmin+sdvalmax)/2, 1, 'last' ); % trim trajectory head
			tmp(dels, :) = [];

			if ~isempty( tmp )
				trajs{end+1} = tmp;
			end
		end

			% remove stubs
		trajlens = cellfun( @( x ) x(end, 1)-x(1, 1)+1, trajs );
		trajs(trajlens < max( trajlens )/2) = [];

			% sort by median frequencies
		trajfreqs = cellfun( @( x ) median( x(:, 2) ), trajs );
		[~, order] = sort( trajfreqs );

		trajs = trajs(order);
		trajfreqs = trajfreqs(order);

			% check for distinctness, TODO: try to recover nearbys!
		if any( diff( trajfreqs ) < cfg.ftt_trajleap )
			logger.progress( i, ntrials );
			continue;
		end

			% set formant onsets, TODO: trajectories?
		ntrajs = numel( trajs );

		if ntrajs > 0
			tmp = trajs{1};
			resp.f0 = [rstart + dsp.smp2sec( tmp(1, 1)-1, run.audiorate ), tmp(1, 2)];
		end

		if ntrajs > 1
			tmp = trajs{2};
			resp.f1 = [rstart + dsp.smp2sec( tmp(1, 1)-1, run.audiorate ), tmp(1, 2)];
		end

		if ntrajs > 2
			tmp = trajs{3};
			resp.f2 = [rstart + dsp.smp2sec( tmp(1, 1)-1, run.audiorate ), tmp(1, 2)];
		end

		if ntrajs > 3
			tmp = trajs{4};
			resp.f3 = [rstart + dsp.smp2sec( tmp(1, 1)-1, run.audiorate ), tmp(1, 2)];
		end

		logger.progress( i, ntrials );
	end

		% log detection
	resps = run.resps_det;

	f0s = cat( 1, resps.f0 );
	f1s = cat( 1, resps.f1 );
	f2s = cat( 1, resps.f2 );
	f3s = cat( 1, resps.f3 );

	logger.log( 'f0s: %d/%d', sum( ~isnan( f0s(:, 1) ) ), nvaltrials );
	logger.log( 'f1s: %d/%d', sum( ~isnan( f1s(:, 1) ) ), nvaltrials );
	logger.log( 'f2s: %d/%d', sum( ~isnan( f2s(:, 1) ) ), nvaltrials );
	logger.log( 'f3s: %d/%d', sum( ~isnan( f3s(:, 1) ) ), nvaltrials );

	logger.untab();
end

