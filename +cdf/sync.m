function offs = sync( run, cfg, sync_resp )
% sync timing
%
% offs = SYNC( run, cfg, sync_resp )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% sync_resp : sync response timing (scalar logical)
%
% OUTPUT
% offs : sync marker offsets (row numeric)
%
% SEE
% Saha, Chakroborty, Senapati (2005)
% A new silence removal and endpoint detection algorithm for speech and speaker recognition applications

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa (cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( sync_resp ) || ~islogical( sync_resp )
		error( 'invalid argument: sync_resp' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'sync timing...' );

		% detect sync start (first tone-distractor)
	mu = mean( run.audiodata(:, 2), 1 ); % noise estimate
	sigma = std( run.audiodata(:, 2), 1, 1 );

	vcsize = dsp.msec2smp( cfg.sync_mrklen, run.audiorate ); % vicinity size
	vcthresh = cfg.sync_thresh * vcsize * sigma;

	start = 0; % pre-allocation

	for i = 1:run.audiolen
		vc = i : min( run.audiolen, i+vcsize );

		mmd = sum( abs( run.audiodata(vc, 2) - mu ) ); % mean mahalanobis dist
		if mmd >= vcthresh
			start = i-1;
			break;
		end
	end

	logger.log( 'start: %.1fms', dsp.smp2msec( start, run.audiorate ) );

		% detect sync marker offsets
	range = dsp.msec2smp( cfg.sync_range, run.audiorate );

	n = numel( run.trials );

	offs = zeros( 1, n ); % pre-allocation
	hits = false( 1, n );

	logger.progress();
	for i = 1:n

			% prepare search range
		sr = run.trials(i).cue + start;
		if i > 1
			sr = sr + offs(i-1); % use last offset as an estimate
			offs(i) = offs(i-1);
		end
		sr = sr + (range(1):range(2));

		sr(sr < 1) = []; % do not exceed audio data
		sr(sr > run.audiolen) = [];

		if isempty( sr )
			logger.progress( i, n );
			continue;
		end

			% detect marker in range
		mu = mean( run.audiodata(sr, 2), 1 ); % noise estimate
		sigma = std( run.audiodata(sr, 2), 1, 1 );

		vcthresh = cfg.sync_thresh * vcsize * sigma;

		for j = sr(1):sr(end)
			vc = j : min( sr(end), j+vcsize );

			mmd = sum( abs( run.audiodata(vc, 2) - mu ) ); % mean mahalanobis dist
			if mmd >= vcthresh
				offs(i) = j - (start + run.trials(i).cue);
				hits(i) = true;
				break;
			end
		end

		logger.progress( i, n );
	end

	offs(~hits) = NaN; % invalidate missed syncs

		% sync trials
	for i = 1:n

			% adjust timing
		run.trials(i).range = run.trials(i).range + start + offs(i);

		run.trials(i).cue = run.trials(i).cue + start + offs(i);

		run.trials(i).distbo = run.trials(i).distbo + start + offs(i);
		run.trials(i).distvo = run.trials(i).distvo + start + offs(i);

		if sync_resp % optionally for responses
			run.trials(i).detected.range = run.trials(i).detected.range + start + offs(i);
			run.trials(i).detected.bo = run.trials(i).detected.bo + start + offs(i);
			run.trials(i).detected.vo = run.trials(i).detected.vo + start + offs(i);
			run.trials(i).detected.vr = run.trials(i).detected.vr + start + offs(i);

			run.trials(i).labeled.range = run.trials(i).labeled.range + start + offs(i);
			run.trials(i).labeled.bo = run.trials(i).labeled.bo + start + offs(i);
			run.trials(i).labeled.vo = run.trials(i).labeled.vo + start + offs(i);
			run.trials(i).labeled.vr = run.trials(i).labeled.vr + start + offs(i);
		end

			% validate timing
		vals = cat( 2, ...
			run.trials(i).range, run.trials(i).cue, run.trials(i).distbo, run.trials(i).distvo, ...
			run.trials(i).detected.range, run.trials(i).detected.bo, run.trials(i).detected.vo, run.trials(i).detected.vr, ...
			run.trials(i).labeled.range, run.trials(i).labeled.bo, run.trials(i).labeled.vo, run.trials(i).labeled.vr );

		if any( vals < 1 | vals > run.audiolen )
			run.trials(i).range = [NaN, NaN]; % invalidate trial range
		end

	end

	rs = cat( 1, run.trials.range );
	logger.log( 'syncs: %d/%d', sum( ~isnan( rs(:, 1) ) ), n );

	logger.untab();
end

