function sync_samples( indir, outdir, ids, seed, nsamples )
% synchronization samples
%
% SYNC_SAMPLES( indir, outdir, ids, seed, nsamples )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : random seed (scalar numeric)
% nsamples : number of trial samples (scalar numeric)

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

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( '%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'synchronization samples...' );

	style = xis.hStyle.instance();

	cfg = cdf.hConfig(); % defaults

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		auxfile = fullfile( indir, sprintf( 'aux_%d.mat', i ) );

		if exist( cdffile, 'file' ) ~= 2 || exist( auxfile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		proc.read_audio( run, run.audiofile, true );

		logger.log( 'read aux data (''%s'')...', auxfile );
		load( auxfile, 'sync0', 'synchints', 'syncs' );

			% sample trials
		itrials = 1:numel( run.trials );
		itrials(isnan( syncs )) = [];

		if numel( itrials ) > nsamples
			rng( seed );

			ilast = itrials(end);
			itrials = sort( itrials(randsample( numel( itrials ), nsamples-1 )) );
			itrials(end+1) = ilast; % always keep last trial
		end

			% output samples
		rundir = fullfile( outdir, sprintf( 'run_%d/', i ) );
		if exist( rundir, 'dir' ) ~= 7
			mkdir( rundir );
		end

		for j = itrials

				% prepare data
			trial = run.trials(j);

			origcue = trial.cue - sync0 - syncs(j);
			usr = dsp.sec2smp( sync0 + origcue + 5*cfg.sync_range, run.audiorate ) + 1; % unhinted search range
			hsr = dsp.sec2smp( sync0 + synchints(j) + origcue + 5*cfg.sync_range, run.audiorate ) + 1; % hinted search range

			if any( isnan( hsr ) ) || any( isnan( usr ) )
				error( 'invalid value: hsr | usr' );
			end

			cdr = min( [hsr(1), usr(1)] ):max( [hsr(2), usr(2)] ); % signal
			cdts = run.audiodata(cdr, 2);

			xs = 1000 * (dsp.smp2sec( cdr - 1, run.audiorate ) - sync0 - origcue); % axes scaling
			xl = [min( xs ), max( xs )];
			yl = max( abs( cdts ) ) * style.scale( 1/2 ) * [-1, 1];

				% plot sample
			plotfile = fullfile( rundir, sprintf( 'sync_%d_%d.png', i, j ) );
			logger.log( 'plot sync sample (''%s'')...', plotfile );

			fig = style.figure();

					% vicinity
			subplot( 2, 1, 1 );

			title( sprintf( 'SYNC (subject: %d, trial: %d)', i, j ) );
			xlabel( 'time in milliseconds (expected: t=0)' );
			ylabel( 'distractor channel' );

			xlim( xl );
			ylim( yl );

			plot( 1000 * syncs(j) * [1, 1], yl, ... % marker
				'Color', style.color( 'signal', 0 ) );

			plot( xs, cdts, ... % signal
				'Color', style.color( 'cold', 0 ) );

					% detail
			subplot( 2, 1, 2 );

			title( sprintf( 'start: %.1fms, hint: %.1fms, offset: %.1fms', ...
				1000 * sync0, 1000 * synchints(j), 1000 * syncs(j) ) );
			xlabel( 'time in milliseconds' );
			ylabel( 'distractor channel' );

			xlim( 1000 * (syncs(j) + 5*cfg.sync_smooth * [-1, 1]) );
			ylim( yl );

			plot( 1000 * syncs(j) * [1, 1], yl, ... % marker
				'Color', style.color( 'signal', 0 ) );

			plot( xs, cdts, ... % signal
				'Color', style.color( 'cold', 0 ) );

			style.print( plotfile );

			delete( fig );

		end

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

