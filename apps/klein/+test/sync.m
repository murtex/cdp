function sync( indir, outdir, ids )
% synchronization stats
%
% SYNC( indir, outdir, ids )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)

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

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( '%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'synchronization stats...' );

	style = xis.hStyle.instance();

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

		logger.log( 'read aux data (''%s'')...', auxfile );
		load( auxfile, 'sync0', 'synchints', 'syncs' );

			% plot stats
		plotfile = fullfile( outdir, sprintf( 'sync_%d.png', i ) );
		logger.log( 'plot marker offsets (''%s'')...', plotfile );

		fig = style.figure();

		if any( isnan( syncs ) )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		title( sprintf( 'SYNC (subject: %d)', i ) );
		xlabel( 'position in seconds' );
		ylabel( 'offset in milliseconds' );

		xlim( [0, dsp.smp2sec( run.audiosize(1)-1, run.audiorate )] );

		scatter( [run.trials.cue], syncs * 1000, ...
			'Marker', '+', 'MarkerEdgeColor', style.color( 'cold', 0 ) );

		style.print( plotfile );

		delete( fig );

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

