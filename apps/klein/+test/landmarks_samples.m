function landmarks_samples( indir, outdir, ids, seed, nsamples, type )
% landmarks samples
%
% LANDMARKS_SAMPLES( indir, outdir, ids, seed, nsamples, type )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : random seed (scalar numeric)
% nsamples : number of trial samples (scalar numeric)
% type : sample type ['any'] (row char)

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
	logger.tab( 'landmarks samples...' );

	style = xis.hStyle.instance();

	cfg = cdf.hConfig(); % defaults

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

		switch type % constrain sample type
			case 'any' % any samples

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

			labr = dsp.sec2smp( resplab.range, run.audiorate ) + [1, 0]; % signals
			detr = dsp.sec2smp( respdet.range, run.audiorate ) + [1, 0];

			r = [min( labr(1), detr(1) ), max( labr(2), detr(2) )];
			if any( isnan( r ) )
				r = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % fallback
			end
			
			cdts = run.audiodata(r(1):r(2), 2);
			respts = run.audiodata(r(1):r(2), 1);
			
			[respsd, respfreqs] = dsp.stransf( respts, run.audiorate, cfg.lmd_freqband(1), cfg.lmd_freqband(2), cfg.lmd_nfreqs );

			xs = dsp.smp2msec( 0:r(2)-r(1), run.audiorate ); % axes scaling
			xl = [min( xs ), max( xs )];
			yl = max( abs( [cdts; respts] ) ) * style.scale( 1/4 ) * [-1, 1];

				% plot sample
			plotfile = fullfile( rundir, sprintf( 'landmarks_%d_%d.png', i, j ) );
			logger.log( 'plot landmarks sample (''%s'')...', plotfile );

			fig = style.figure();

					% waveforms and landmarks
			subplot( 4, 2, 5 ); % distractor

			xlabel( 'time in milliseconds' );
			ylabel( 'distractor' );

			xlim( xl );
			ylim( yl );

			hl = plot( xs, cdts, 'Color', style.color( 'cold', 0 ) );

			legend( hl, sprintf( '''%s''/''%s''', trial.cuelabel, trial.distlabel ), ...
				'Location', 'northeast' );

			subplot( 4, 2, 7 ); % response

			xlabel( 'time in milliseconds' );
			ylabel( 'response' );

			xlim( xl );
			ylim( yl );

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
			audiofile = fullfile( rundir, sprintf( 'landmarks_%d_%d.wav', i, j ) );
			logger.log( 'write landmarks sample (''%s'')...', audiofile );

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

