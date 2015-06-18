function [sync0, syncs] = sync( run, cfg )
% sync timings
%
% [sync0, syncs] = SYNC( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
%
% OUTPUT
% sync0 : sync start offset (scalar numeric)
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

			% set search range statistics
		sr = dsp.sec2smp( run.trials(i).cuepos + cfg.sync_range, run.audiorate ) + 1;

		if any( isnan( sr ) ) || any( sr < 1 ) || any( sr > run.audiosize(1) )
			continue;
		end

		noimu = mean( run.audiodata(sr(1):sr(2), 2) );
		noisigma = std( run.audiodata(sr(1):sr(2), 2), 1 );

		break; % got statistics
	end

	if isnan( noimu ) || isnan( noisigma )
		error( 'invalid value: noimu | noisigma' );
	end

		% normalize and smooth cue/distractor (mahalanobis distance to noise)
	cdts = abs( run.audiodata(:, 2) - noimu ) / noisigma;
	cdtslen = numel( cdts );

	smooth = dsp.sec2smp( cfg.sync_smooth, run.audiorate );
	cdts = cdts / smooth;
	
		% track sync start (first tone/activity)
	sync0 = NaN;

	for i = 1:cdtslen
		cdr = i:min( cdtslen, i + smooth );
		if sum( cdts(cdr) ) >= cfg.sync_thresh
			sync0 = i - 1;
			break;
		end
	end

	if isnan( sync0 )
		error( 'invalid value: sync0' );
	end

		% track sync markers
	synclast = 0;

	syncs = NaN( 1, ntrials );

	logger.progress()
	for i = 1:ntrials

			% set search range
		sr = dsp.sec2smp( run.trials(i).cuepos + cfg.sync_range, run.audiorate ) + 1;
		sr = sync0 + synclast + sr; % apply last sync offset as hint

		if any( isnan( sr ) ) || any( sr < 1 ) || any( sr > run.audiosize(1) )
			continue;
		end

			% track marker
		sr = sr(1):sr(2);
		for j = sr
			cdr = j:min( sr(end), j + smooth );
			if sum( cdts(cdr) ) >= cfg.sync_thresh
				expected = sync0 + dsp.sec2smp( run.trials(i).cuepos, run.audiorate ) + 1;
				synclast = j - 1 - expected;
				syncs(i) = synclast;
				break;
			end
		end

		logger.progress( i, ntrials );
	end

		% convert sync scale
	sync0 = dsp.smp2sec( sync0, run.audiorate );
	syncs = dsp.smp2sec( syncs, run.audiorate );

	logger.log( 'sync start: %.1fms', 1000 * sync0 );
	logger.log( 'sync markers: %d/%d', sum( ~isnan( syncs ) ), ntrials );

		% apply sync offsets
	for i = 1:ntrials
		trial = run.trials(i);

			% general
		trial.cuepos = trial.cuepos + sync0 + syncs(i);
		trial.distpos = trial.distpos + sync0 + syncs(i);

	end

	logger.untab();
end

