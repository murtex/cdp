function [sync0, synchints, syncs] = sync( run, cfg )
% marker synchronization
%
% [sync0, synchints, syncs] = SYNC( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
%
% OUTPUT
% sync0 : sync start offset (scalar numeric)
% synchints : offset hints (row numeric)
% syncs : sync marker offsets (row numeric)
%
% SEE
% (2005) Saha, Chakroborty, Senapati : A New Silence Removal and Endpoint Detection Algorithm for Speech and Speaker Recognition Applications

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'marker synchronization...' );

		% pre-estimate cue/distractor noise
	ntrials = numel( run.trials );
	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	noir = [1, dsp.sec2smp( run.trials(1).dist, run.audiorate )]; % initial noise range
	if any( isnan( noir ) ) || any( noir < 1 ) || any( noir > run.audiosize(1) )
		error( 'invalid value: noir' );
	end

	noits = run.audiodata(noir(1):noir(2), 2);
	noimu = mean( noits );
	noisigma = std( noits, 1 );

		% track sync start (first activity/tone distractor)
	sync0 = 0;

	smooth = dsp.sec2smp( cfg.sync_smooth, run.audiorate );
	lsmooth = ceil( (smooth-1) / 2 );
	rsmooth = floor( (smooth-1) / 2 );

	cdts = abs( run.audiodata(:, 2) - noimu ) / noisigma / smooth; % standardization
	cdtslen = numel( cdts );

	for i = 1:cdtslen-smooth
		cdtsfr = sum( cdts(i:i+smooth-1) );

		if cdtsfr >= 3 * cfg.sync_thresh % enlarged threshold, TODO: configurable?
			sync0 = i - 1;
			break;
		end
	end

		% estimate cue/distractor noise
	noir = sync0 + dsp.sec2smp( run.trials(1).cue + cfg.sync_range, run.audiorate ) + [1, 0]; % estimated noise range

	noits = run.audiodata(noir(1):noir(2), 2);
	noimu = mean( noits);
	noisigma = std( noits, 1 );

		% track trial sync markers
	synclast = 0;

	synchints = zeros( 1, ntrials );
	syncs = NaN( 1, ntrials );

	cdts = (run.audiodata(:, 2) - noimu) / noisigma / smooth; % standardization
	cdtslen = numel( cdts );

	logger.progress()
	for i = 1:ntrials
		trial = run.trials(i);

			% set search range
		sr = dsp.sec2smp( trial.cue + cfg.sync_range, run.audiorate ) + 1;

		synchints(i) = synclast; % use last sync offset as hint
		sr = sync0 + synchints(i) + sr;

		if any( isnan( sr ) )
			continue;
		end

		sr(sr < 1) = 1; % clamp range
		sr(sr > run.audiosize(1)) = run.audiosize(1);

			% track marker
		for j = sr(1)+lsmooth:sr(2)-rsmooth
			cdtsfr = cdts(j-lsmooth:j+rsmooth);
			cdtsfr = sum( abs( cdtsfr - mean( cdtsfr ) ) ); % remove frame dc (highpass)

			if cdtsfr >= cfg.sync_thresh
				expected = sync0 + dsp.sec2smp( trial.cue, run.audiorate ) + 1;
				synclast = j - 1 - expected;
				syncs(i) = synclast;
				break;
			end
		end

			% catch lost sync
		if isnan( syncs(i) )
			logger.untab( 'LOST SYNC!' );
			if i > 1
				logger.log( 'last marker: %.3fs', ...
					dsp.smp2sec( sync0 + syncs(i-1), run.audiorate ) + run.trials(i-1).cue );
			end
			break;
		end

		logger.progress( i, ntrials );
	end

		% convert sync scale
	sync0 = dsp.smp2sec( sync0, run.audiorate );
	syncs = dsp.smp2sec( syncs, run.audiorate );
	synchints = dsp.smp2sec( synchints, run.audiorate );

	logger.log( 'sync start: %.1fms', 1000 * sync0 );
	logger.log( 'sync markers: %d/%d', sum( ~isnan( syncs ) ), ntrials );

		% apply sync offsets
	maxt = dsp.smp2sec( run.audiosize(1), run.audiorate );

	for i = 1:ntrials
		trial = run.trials(i);

			% general
		trial.range = trial.range + sync0 + syncs(i);
		trial.range(trial.range < 0) = 0;
		trial.range(trial.range > maxt) = maxt;

		trial.cue = trial.cue + sync0 + syncs(i);
		trial.dist = trial.dist + sync0 + syncs(i);

	end

		% done
	logger.untab();

end

