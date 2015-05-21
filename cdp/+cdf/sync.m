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

		% detect sync zero-point (first 'tone' distractor)
	vic = dsp.msec2smp( cfg.sync_mrklen, run.audiorate );

	zoffs = k15.scs05( run.audiodata(:, 2), vic, cfg.sync_thresh ) - 1;
	if isnan( zoffs )
		error( 'invalid argument: run' );
	end

	logger.log( 'zero-point: %.1fms', dsp.smp2msec( zoffs, run.audiorate ) );

		% detect sync marker offsets
	range = dsp.msec2smp( cfg.sync_range, run.audiorate );

	n = numel( run.trials );

	offs = zeros( 1, n ); % pre-allocation
	hits = false( 1, n );

	for i = 1:n

			% prepare search range
		sr = run.trials(i).cue + zoffs;
		if i > 1
			sr = sr + offs(i-1); % use last offset as an estimate
			offs(i) = offs(i-1);
		end
		sr = sr + (range(1):range(2));

		sr(sr < 1) = []; % do not exceed audio data
		sr(sr > run.audiolen) = [];

		if isempty( sr ) % skip empty search range
			logger.progress( i, n );
			continue;
		end

			% detect marker start and set offset
		moffs = k15.scs05( run.audiodata(sr, 2), vic, cfg.sync_thresh );
		moffs = sr(1)+moffs-1 - zoffs - run.trials(i).cue;

		if ~isnan( moffs )
			offs(i) = moffs;
			hits(i) = true;
		end

	end

	offs(~hits) = NaN; % invalidate missed syncs

	logger.log( 'syncs: %d/%d', sum( ~isnan( offs ) ), n );

		% sync trials
	for i = 1:n

			% adjust timing
		run.trials(i).range = run.trials(i).range + zoffs + offs(i);

		run.trials(i).cue = run.trials(i).cue + zoffs + offs(i);

		run.trials(i).distbo = run.trials(i).distbo + zoffs + offs(i);
		run.trials(i).distvo = run.trials(i).distvo + zoffs + offs(i);

		if sync_resp % optionally for responses
			run.trials(i).detected.range = run.trials(i).detected.range + zoffs + offs(i);
			run.trials(i).detected.bo = run.trials(i).detected.bo + zoffs + offs(i);
			run.trials(i).detected.vo = run.trials(i).detected.vo + zoffs + offs(i);
			run.trials(i).detected.vr = run.trials(i).detected.vr + zoffs + offs(i);

			run.trials(i).labeled.range = run.trials(i).labeled.range + zoffs + offs(i);
			run.trials(i).labeled.bo = run.trials(i).labeled.bo + zoffs + offs(i);
			run.trials(i).labeled.vo = run.trials(i).labeled.vo + zoffs + offs(i);
			run.trials(i).labeled.vr = run.trials(i).labeled.vr + zoffs + offs(i);
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

	logger.untab();
end

