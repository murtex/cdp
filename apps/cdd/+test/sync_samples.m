function sync_samples( indir, outdir, ids, ntrials, rndseed, logfile )
% marker synchronization samples
%
% SYNC_SAMPLES( indir, outdir, ids, ntrials, rndseed, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (vector numeric)
% ntrials : number of trials (scalar numeric)
% rndseed : randomization rndseed (scalar numeric)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isvector( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isscalar( ntrials ) || ~isnumeric( ntrials ) % number of trials
		error( 'invalid argument: ntrials' );
	end

	if nargin < 5 || ~isscalar( rndseed ) || ~isnumeric( rndseed ) % randomization seed
		error( 'invalid argument: rndseed' );
	end

	if nargin < 6 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'marker synchronization samples...' );

	style = xis.hStyle.instance();

		% workload
	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) ); % cdf data
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: %s', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

		proc.read_audio( run, run.audiofile ); % audio data

		auxfile = fullfile( indir, sprintf( 'run_%d_aux.mat', id ) ); % auxiliary data
		logger.tab( 'read auxiliary data (''%s'')...', auxfile );

		load( auxfile, 'sync0', 'synchints', 'syncs' );

		logger.log( 'sync start: %.1fms', 1000 * sync0 );
		logger.log( 'sync markers: %d/%d', sum( ~isnan( syncs ) ), numel( run.trials ) );

		logger.untab();

		cfgfile = fullfile( indir, sprintf( 'run_%d_cfg.mat', id ) ); % configuration
		logger.log( 'read configuration (''%s'')...', cfgfile );

		load( cfgfile, 'cfg' );

			% sample trials
		itrials = 1:numel( run.trials );

		itrials(isnan( syncs )) = []; % skip invalids

		if numel( itrials ) > ntrials % sample randomly, always keep last (valid) trial
			rng( rndseed );

			ilast = itrials(end);
			itrials = sort( itrials(randsample( numel( itrials ), ntrials-1 )) );
			itrials(end+1) = ilast;
		end

			% plot trials
		plotdir = fullfile( outdir, sprintf( 'run_%d', id ) );
		if exist( plotdir, 'dir' ) ~= 7
			mkdir( plotdir );
		end

		for itrial = itrials

				% prepare
			trial = run.trials(itrial);

			detected_cue = trial.cue; % ranges
			original_cue = detected_cue - syncs(itrial);
			expected_cue = original_cue + synchints(itrial);

			sr = dsp.sec2smp( cfg.sync_range * style.scale( 1 ) + expected_cue, run.audiorate ) + [1, 0];
			detr = dsp.sec2smp( cfg.sync_smooth * [-1, 1] * style.scale( 1 ) + detected_cue, run.audiorate ) + [1, 0];

			sts = run.audiodata(sr(1):sr(2), 2); % signals
			detts = run.audiodata(detr(1):detr(2), 2);

				% plot
			figfile = fullfile( plotdir, sprintf( 'trial_%d.png', itrial ) );
			logger.log( 'plot marker synchronization sample (''%s'')...', figfile );

			fig = style.figure();

			subplot( 2, 1, 1 ); % search range

			title( sprintf( 'SYNC_SAMPLE (subject: %d, trial: %d)', id, itrial ) );
			xlabel( 'time in milliseconds (expected: 0)' );
			ylabel( 'distractor' );

			xlim( cfg.sync_range * style.scale( 1 ) * 1000 );
			ylim( max( abs( sts ) ) * [-1, 1] * style.scale( 1 ) );

			h1 = plot( (expected_cue * [1, 1] - expected_cue) * 1000, [-1, 1], ...
				'DisplayName', 'expected', 'Color', style.color( 'cold', +1 ) );
			h2 = plot( (original_cue * [1, 1] - expected_cue) * 1000, [-1, 1], ...
				'DisplayName', 'original', 'Color', style.color( 'warm', +1 ) );
			h3 = plot( (detected_cue * [1, 1] - expected_cue) * 1000, [-1, 1], ...
				'DisplayName', 'detected', 'Color', style.color( 'signal', +1 ) );
			plot( (dsp.smp2sec( (sr(1):sr(2)) - 1, run.audiorate ) - expected_cue) * 1000, sts, ...
				'Color', style.color( 'cold', -1 ) );

			legend( [h1, h2, h3], 'Location', 'southwest' );

			subplot( 2, 1, 2 ); % detail

			xlabel( 'time in milliseconds (detected: 0)' );
			ylabel( 'distractor' );

			xlim( cfg.sync_smooth * [-1, 1] * style.scale( 1 ) * 1000 );
			ylim( max( abs( detts ) ) * [-1, 1] * style.scale( 1 ) );

			h = plot( (detected_cue * [1, 1] - detected_cue) * 1000, [-1, 1], ...
				'DisplayName', 'detected', 'Color', style.color( 'signal', +1 ) );
			plot( (dsp.smp2sec( (detr(1):detr(2)) - 1, run.audiorate ) - detected_cue) * 1000, detts, ...
				'Color', style.color( 'cold', -1 ) );

			legend( h, 'Location', 'southwest' );

			style.print( figfile );
			delete( fig );

		end

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

