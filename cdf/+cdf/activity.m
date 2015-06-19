function activity( run, cfg )
% detect voice activity
%
% ACTIVITY( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'detect voice activity...' );

		% proceed trials
	ntrials = numel( run.trials );

	logger.progress();
	for i = 1:ntrials
		trial = run.trials(i);
		resp = run.resps_det(i);

			% reset activity
		resp.startpos = NaN;
		resp.stoppos = NaN;

			% set noise and response signals
		noir = dsp.sec2smp( [trial.cuepos, trial.distpos], run.audiorate ) + 1; % noise range
		if any( isnan( noir ) ) || any( noir < 1 ) || any( noir > run.audiosize(1) )
			logger.progress( i, ntrials );
			continue;
		end

		respr = [dsp.sec2smp( trial.cuepos, run.audiorate ) + 1, run.audiosize(1)]; % response range
		if i < ntrials
			respr(2) = dsp.sec2smp( run.trials(i+1).cuepos, run.audiorate );
		end
		if any( isnan( respr ) ) || any( respr < 1 ) || any( respr > run.audiosize(1) )
			logger.progress( i, ntrials );
			continue;
		end

		noits = run.audiodata(noir(1):noir(2), 1); % signals
		respts = run.audiodata(respr(1):respr(2), 1);

		if isempty( noits ) || isempty( respts ) % TODO: allow empty noise signal!
			logger.progress( i, ntrials );
			continue;
		end

			% get short-time fourier transforms
		frlength = dsp.sec2smp( 0.01, run.audiorate ); % TODO: configure!
		froverlap = 0.5;
		frwindow = @rectwin;

		noifr = dsp.frame( noits, frlength, froverlap, frwindow ); % short-time framing
		respfr = dsp.frame( respts, frlength, froverlap, frwindow );

		[noift, noifreqs] = dsp.fft( noifr, run.audiorate ); % fourier transforms
		[respft, respfreqs] = dsp.fft( respfr, run.audiorate );

			% DEBUG
		size( noifr )
		size( noift )
		size( noifreqs )

		size( respfr )
		size( respft )
		size( respfreqs )

			% DEBUG
		figure();

		subplot( 4, 1, 1 );
		plot( noits );

		subplot( 4, 1, 2 );
		imagesc( log( abs( noift ) ) );

		subplot( 4, 1, 3 );
		plot( respts );

		subplot( 4, 1, 4 );
		imagesc( log( abs( respft ) ) );

		print( 'bla.png', '-dpng', '-r120' );

		error( 'DEBUG' );

		logger.progress( i, ntrials );
	end

	logger.untab();
end

