function activity_samples( indir, outdir, ids, seed, nsamples, type )
% voice activity detection samples
%
% ACTIVITY_SAMPLES( indir, outdir, ids, seed, nsamples, type )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : random seed (scalar numeric)
% nsamples : number of trial samples (scalar numeric)
% type : sample type ['any' | 'valid' | 'invalid'] (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	elseif exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

	if nargin < 4 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: seed' );
	end

	if nargin < 5 || ~isscalar( nsamples ) || ~isnumeric( nsamples )
		error( 'invalid argument: nsamples' );
	end

	if nargin < 6 || ~isrow( type ) || ~ischar( type )
		error( 'invalid argument: type' );
	end

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( '%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'voice activity detection samples...' );

	style = xis.hStyle.instance();

	cfg = cdf.hConfig(); % defaults

		% helper functions
	function labrange( y, h ) % plot labeled range
		if ~any( isnan( labr ) )
			rectangle( 'Position', [...
				dsp.smp2msec( labr(1)-r(1), run.audiorate ), y, ...
				dsp.smp2msec( labr(2)-labr(1)+1, run.audiorate ), h], ...
				'EdgeColor', style.color( 'neutral', +1 ), 'FaceColor', style.color( 'neutral', +2 ) );
		end
	end

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		if exist( cdffile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		proc.read_audio( run, run.audiofile, true );

			% sample trials
		itrials = 1:numel( run.trials );

		resplabs = [run.trials(itrials).resplab]; % constrain sample type
		respdets = [run.trials(itrials).respdet];

		rlabs = cat( 1, resplabs.range );
		rdets = cat( 1, respdets.range );

		dstarts = rdets(:, 1) - rlabs(:, 1);
		dstops = rdets(:, 2) - rlabs(:, 2);

		switch type
			case 'any' % any samples

			case 'valid' % valid samples only, TODO: never tested!
				vals = dstarts <= 0 & dstops >= 0;
				itrials(~vals) = [];

			case 'invalid' % invalid samples only
				invals = dstarts > 0 | dstops < 0;
				itrials(~invals) = [];

			otherwise
				error( 'invalid argument: type' );
		end

		if numel( itrials ) > nsamples % choose random samples
			rng( seed );
			itrials = sort( itrials(randsample( numel( itrials ), nsamples )) );
		end

			% output samples
		rundir = fullfile( outdir, sprintf( 'run_%d/', i ) );
		if exist( rundir, 'dir' ) ~= 7
			mkdir( rundir );
		end

		for j = itrials

				% prepare data
			trial = run.trials(j);
			resplab = trial.resplab;
			respdet = trial.respdet;

			r = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % signals
			relnoir = dsp.sec2smp( [trial.cue, trial.dist], run.audiorate ) + [1, 0] - r(1) + 1;

			if diff( trial.range ) > cfg.vad_maxdet
				r(2) = r(1) - 1 + dsp.sec2smp( cfg.vad_maxdet, run.audiorate );
			end

			labr = dsp.sec2smp( resplab.range, run.audiorate ) + [1, 0];
			detr = dsp.sec2smp( respdet.range, run.audiorate ) + [1, 0];

			cdts = run.audiodata(r(1):r(2), 2);
			respts = run.audiodata(r(1):r(2), 1);

			[respsd, respfreqs] = dsp.stransf( respts, run.audiorate, cfg.vad_freqband(1), cfg.vad_freqband(2), cfg.vad_nfreqs );
			noisd = respsd(:, relnoir(1):relnoir(2));

			[sdiv, threshs, vact] = k15.vad( respsd, noisd ); % activity

			xs = dsp.smp2msec( 0:r(2)-r(1), run.audiorate ); % axes scaling
			xdist = 1000 * (trial.dist - trial.range(1));
			xl = [min( xs ), max( xs )];
			yl = max( abs( [cdts; respts] ) ) * style.scale( 1/4 ) * [-1, 1];

				% plot sample
			plotfile = fullfile( rundir, sprintf( 'activity_%d_%d.png', i, j ) );
			logger.log( 'plot activity sample (''%s'')...', plotfile );

			fig = style.figure();

					% spectral divergence
			subplot( 4, 2, [1:4] );

			title( sprintf( 'ACTIVITY (subject: %d, trial: %d)', i, j ) );
			xlabel( 'time in milliseconds' );
			ylabel( 'spectral divergence in decibel' );

			xlim( xl );

			plot( xl, threshs(1) * [1, 1], 'Color', style.color( 'signal', 0 ) ); % thresholds
			plot( xl, threshs(2) * [1, 1], 'Color', style.color( 'signal', 0 ) );

			plot( xs, sdiv, 'Color', style.color( 'cold', 0 ) ); % divergence

					% waveforms and ranges
			subplot( 4, 2, 5 ); % distractor

			xlabel( 'time in milliseconds' );
			ylabel( 'distractor' );

			xlim( xl );
			ylim( yl );

			plot( xdist * [1, 1], yl, 'Color', style.color( 'signal', 0 ) );

			hl = plot( xs, cdts, 'Color', style.color( 'cold', 0 ) );

			legend( hl, sprintf( '''%s''/''%s''', trial.cuelabel, trial.distlabel ), ...
				'Location', 'northeast' );

			subplot( 4, 2, 7 ); % response

			xlabel( 'time in milliseconds' );
			ylabel( 'response' );

			xlim( xl );
			ylim( yl );

			labrange( 0, yl(2) ); % labeled range

			if ~any( isnan( detr ) ) % detected range
				rectangle( 'Position', [...
					dsp.smp2msec( detr(1)-r(1), run.audiorate ), -yl(2), ...
					dsp.smp2msec( detr(2)-detr(1)+1, run.audiorate ), yl(2)], ...
					'EdgeColor', style.color( 'signal', +1 ), 'FaceColor', style.color( 'signal', +2 ) );
			end

			hl = plot( xs, respts, 'Color', style.color( 'cold', 0 ) ); % waveform

			legend( hl, sprintf( '''%s''/''%s''', resplab.label, respdet.label ), ...
				'Location', 'northeast' );

					% spectral decomposition
			subplot( 4, 2, [6, 8] );

			xlabel( 'time in milliseconds' );
			ylabel( 'frequency in kilohertz' );

			xlim( xl );
			ylim( [min( respfreqs ), max( respfreqs )] / 1000 );

			colormap( style.gradient( 256, [1, 1, 1], style.color( 'cold', -2 ) ) );
			imagesc( xs, respfreqs/1000, log( respsd .* conj( respsd ) + eps ) );

			style.print( plotfile );

			delete( fig );

				% write sample
			audiofile = fullfile( rundir, sprintf( 'activity_%d_%d.wav', i, j ) );
			logger.log( 'write activity sample (''%s'')...', audiofile );

			ws = warning(); % disable warnings
			warning( 'off', 'all' );

			wavwrite( cat( 2, respts, cdts ), run.audiorate, audiofile );
			
			warning( ws ); % (re-)enable warnings

		end

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

