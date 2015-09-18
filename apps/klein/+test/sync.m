function sync( indir, outdir, ids )
% test raw syncings
%
% SYNC( indir, outdir, ids )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir )
		error( 'invalid argument: indir' );
	end
	
	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

		% check/prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	auxdir = fullfile( indir, 'aux/' );
	if exist( auxdir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( 'test_sync_%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'test raw syncings...' );

	style = xis.hStyle.instance();

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		auxfile = fullfile( auxdir, sprintf( 'run_%d_sync_aux.mat', i ) );

		if exist( cdffile, 'file' ) ~= 2 || exist( auxfile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		logger.log( 'read aux data (''%s'')...', auxfile );
		load( auxfile, 'sync0', 'synchints', 'syncs' );

			% plot syncings
		plotfile = fullfile( outdir, sprintf( 'test_sync_run_%d.png', i ) );
		logger.log( 'plot syncings (''%s'')...', plotfile );

		fig = style.figure();

		if any( isnan( syncs ) )
			set( fig, 'Color', style.color( 'warm', +2 ) );
		end

		title( sprintf( 'syncing (subject: %d)', i ) );
		xlabel( 'marker position in seconds' );
		ylabel( 'marker offset in milliseconds' );

		xlim( [0, dsp.smp2sec( run.audiosize(1)-1, run.audiorate )] );

		scatter( [run.trials.cue], 1000 * syncs, ...
			'Marker', '+', ...
			'MarkerEdgeColor', style.color( 'cold', 0 ), 'MarkerFaceColor', style.color( 'cold', 0 ) );

		style.print( plotfile );

		delete( fig );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

