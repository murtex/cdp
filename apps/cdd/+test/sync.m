function sync( indir, outdir, ids, logfile )
% marker synchronization statistics
%
% SYNC( indir, outdir, ids, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'marker synchronization statistics...' );

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

		auxfile = fullfile( indir, sprintf( 'run_%d_aux.mat', id ) ); % auxiliary data
		logger.tab( 'read auxiliary data (''%s'')...', auxfile );

		load( auxfile, 'sync0', 'synchints', 'syncs' );

		logger.log( 'sync start: %.1fms', 1000 * sync0 );
		logger.log( 'sync markers: %d/%d', sum( ~isnan( syncs ) ), numel( run.trials ) );

		logger.untab();

			% plot statistics
		figfile = fullfile( outdir, sprintf( 'run_%d.png', id ) );
		logger.log( 'plot marker synchronization statistics (''%s'')...', figfile );

		fig = style.figure();
		if any( isnan( syncs ) )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		title( sprintf( 'SYNC (subject: %d)', id ) );
		xlabel( 'marker position in seconds' );
		ylabel( 'marker offset in milliseconds' );

		scatter( [run.trials.cue], syncs * 1000, ...
			'Marker', '+', 'MarkerEdgeColor', style.color( 'cold', -1 ) );

		style.print( figfile );
		delete( fig );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

