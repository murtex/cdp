function extract( run, cfg )
% extract responses
%
% EXTRACT( run, cfg )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'extract responses...' );

		% proceed trials
	n = numel( run.trials );

	nstarts = 0;
	nstops = 0;

	logger.progress();
	for i = 1:n

			% reset response range
		trial = run.trials(i);

		trial.detected.range = [NaN, NaN];

		if any( isnan( trial.range ) ) % skip invalid trials
			logger.progress( i, n );
			continue;
		end

			% set signals
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(trial.range(1):trial.range(2), 1);

			% get full bandwidth fft
		frame = sta.msec2smp( cfg.sta_frame, run.audiorate );

		noift = sta.framing( noiser, frame, cfg.sta_wnd );
		[noift, noifreqs] = sta.fft( noift, run.audiorate );
		[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.sta_band );

		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );
		[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.sta_band );

			% set total powers
		resppow = sum( respft, 2 );

		noimax = max( noift, [], 1 ); % denoising
		m = size( respft, 1 );
		for j = 1:m
			respft(j, :) = respft(j, :) - noimax;
		end
		respft(respft < eps) = eps;

		respclpow = sum( respft, 2 );

			% smoothing
		resppow = sta.unframe( resppow, frame );
		resppow = resppow(1:size( respser, 1 ));

		respclpow = sta.unframe( respclpow, frame );
		respclpow = respclpow(1:size( respser, 1 ));

			% get activity
		[respact, lothresh, hithresh] = k15.activity( resppow, respclpow );

			% set response range
		d = diff( cat( 1, false, respact, false ) );

		astart = find( d == 1, 1, 'first' ); % first active range
		astop = find( d == -1, 1, 'first' ) - 1;

		if ~isempty( astart ) && ~isempty( astop )
			trial.detected.range(1) = trial.range(1) + astart-1;
			trial.detected.range(2) = trial.range(1) + astop-1;
			nstarts = nstarts + 1;
			nstops = nstops + 1;
		end

		logger.progress( i, n );
	end

	logger.log( 'starts: %d/%d', nstarts, n );
	logger.log( 'stops: %d/%d', nstops, n );

	logger.untab();
end

