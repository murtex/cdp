function [pows, freqs] = babbling( run, cfg, labeled, landmarks )
% get speech-weighted noise (babbling) spectrum
%
% [pows, freqs] = BABBLING( run, cfg, labeled, landmarks )
% 
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% labeled : use labeled response (scalar logical)
% landmarks : use landmarks (scalar logical)
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

	if nargin < 3 || ~isscalar( labeled ) || ~islogical( labeled )
		error( 'invalid argument: labeled' );
	end

	if nargin < 4 || ~isscalar( landmarks ) || ~islogical( landmarks )
		error( 'invalid argument: landmarks' );
	end

	logger = xis.hLogger.instance();
	logger.progress( 'estimate babbling noise...' );

		% proceed trials
	n = numel( run.trials );

	ns = 0; % pre-allocation
	pows = [];
	freqs = [];

	for i = 1:n

			% skip invalid trials
		trial = run.trials(i);

		if labeled
			if landmarks
				range = [trial.labeled.bo, trial.labeled.vr];
			else
				range = trial.labeled.range;
			end
		else
			if landmarks
				range = [trial.detected.bo, trial.detected.vr];
			else
				range = trial.detected.range;
			end
		end

		if any( isnan( range ) )
			logger.progress( i, n );
			continue;
		end

			% set signal
		noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
		respser = run.audiodata(range(1):range(2), 1);

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

