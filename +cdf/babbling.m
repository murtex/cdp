function [pows, freqs] = babbling( run, cfg )
% get speech-weighted noise (babbling) spectrum
%
% [pows, freqs] = BABBLING( run, cfg )
% 
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
%
% OUTPUT
% pows : spectral powers (row numeric)
% freqs : frequencies (row numeric)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.progress( 'estimate babbling noise...' );

		% proceed trials
	n = numel( run.trials );

	ns = 0; % pre-allocation
	pows = [];
	freqs = [];

	for i = 1:n

			% skip unlabeled trials
		trial = run.trials(i);

		if any( isnan( trial.labeled.range ) )
			logger.progress( i, n );
			continue;
		end

			% set signal
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(trial.labeled.range(1):trial.labeled.range(2), 1);

			% get full bandwidth fft
		frame = dsp.msec2smp( cfg.sta_frame, run.audiorate );
		
		noift = sta.framing( noiser, frame, cfg.sta_wnd );
		[noift, noifreqs] = sta.fft( noift, run.audiorate );

		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );

			% set response spectrum
		noimax = max( noift, [], 1 ); % denoising
		m = size( respft, 1 );
		for j = 1:m
			respft(j, :) = respft(j, :) - noimax;
		end
		respft(respft < 0) = 0;

		respft = mean( respft, 1 ); % averaging frames

			% sum spectra
		ns = ns + 1;
		if ns == 1
			pows = respft;
			freqs = respfreqs;
		else
			pows = pows + respft;
		end

		logger.progress( i, n );
	end

		% average spectra
	pows = pows / ns;

end

