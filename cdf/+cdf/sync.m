function [sync0, synchints, syncs] = sync( run, cfg )
% sync timings
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
	logger.tab( 'sync timings...' );

		% estimate cue/distractor noise
	noimu = NaN;
	noisigma = NaN;

	ntrials = numel( run.trials );
	for i = 1:ntrials
		trial = run.trials(i);

			% set search range
		sr = dsp.sec2smp( trial.cue + cfg.sync_range, run.audiorate ) + [1, 0];
		if any( isnan( sr ) ) || any( sr < 1 ) || any( sr > run.audiosize(1) ) || isempty( sr(1):sr(2) )
			continue;
		end

			% set statistics
		noimu = mean( run.audiodata(sr(1):sr(2), 2) );
		noisigma = std( run.audiodata(sr(1):sr(2), 2), 1 );

		break;

	end

	if isnan( noimu ) || isnan( noisigma )
		error( 'invalid value: noimu | noisigma' );
	end

		% normalize and smooth cue/distractor data (mahalanobis distance to noise)
	cdts = (run.audiodata(:, 2) - noimu) / noisigma;
	cdtslen = numel( cdts );

	smooth = dsp.sec2smp( cfg.sync_smooth, run.audiorate );
	cdts = cdts / smooth;
	
		% track sync start (first tone/activity)
	sync0 = NaN;

	for i = 1:cdtslen
		cdr = i:min( cdtslen, i + smooth );
		if sum( abs( cdts(cdr) ) ) >= cfg.sync_thresh
			sync0 = i - 1;
			break;
		end
	end

	if isnan( sync0 )
		error( 'invalid value: sync0' );
	end

		% track sync markers
	synclast = 0;

	synchints = zeros( 1, ntrials );
	syncs = NaN( 1, ntrials );

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
		sr = sr(1):sr(2);
		for j = sr
			cdr = j:min( sr(end), j + smooth );
			tmp = cdts(cdr);
			tmp = sum( abs( tmp - mean( tmp ) ) ); % center snippet (highpass)
			if tmp >= cfg.sync_thresh
				expected = sync0 + dsp.sec2smp( trial.cue, run.audiorate ) + 1;
				synclast = j - 1 - expected;
				syncs(i) = synclast;
				break;
			end
		end

			% lost sync
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

	logger.untab();
end

