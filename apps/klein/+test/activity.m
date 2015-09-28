function activity( indir, outdir, ids )
% activity stats
%
% ACTIVITY( indir, outdir, ids )
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
	logger.tab( 'activity stats...' );

	style = xis.hStyle.instance();

		% helper functions
	MAXDELTA = 0.3;

	function figstats( plotfile, figtitle, ... % activity stats
			nresplabs, ...
			dstarts, dstartpos, dstartns, ndstarts, valdstartpos, valdstartns, nvaldstarts, ...
			dstops, dstoppos, dstopns, ndstops, valdstoppos, valdstopns, nvaldstops )

		logger.log( 'plot activity stats (''%s'')...', plotfile );

		fig = style.figure();

		if any( dstarts > 0 ) | any( dstops < 0 )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

			% starts
		subplot( 2, 2, 1 ); % actual

		title( figtitle );
		xlabel( 'range start delta in milliseconds' );
		ylabel( 'rate in percent' );

		xlim( 1000 * MAXDELTA * [-1, 1] );
		ylim( [0, 100] );

		hb = bar( 1000 * dstartpos, 100 * dstartns / ndstarts, ...
			'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

		plot( [0, 0], [0, 100], 'Color', style.color( 'signal', 0 ) );

		legend( hb, sprintf( 'detected (%d [%.1f%%])', ndstarts, 100 * ndstarts / nresplabs ), ...
			'Location', 'northeast' );

		subplot( 2, 2, 2 ); % cumulative

		xlabel( 'range start delta in milliseconds' );
		ylabel( 'cumulative rate in percent' );

		xlim( [0, 1000 * MAXDELTA] );
		ylim( [0, 100] );

		hb = bar( 1000 * valdstartpos, 100 * cumsum( valdstartns ) / ndstarts, ...
			'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

		legend( hb, sprintf( 'valid (%d [%.1f%%])', nvaldstarts, 100 * nvaldstarts / nresplabs ), ...
			'Location', 'southeast' );

			% stops
		subplot( 2, 2, 3 ); % actual

		xlabel( 'range stop delta in milliseconds' );
		ylabel( 'rate' );

		xlim( 1000 * MAXDELTA * [-1, 1] );
		ylim( [0, 100] );

		hb = bar( 1000 * dstoppos, 100 * dstopns / ndstops, ...
			'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

		plot( [0, 0], [0, 100], 'Color', style.color( 'signal', 0 ) );

		legend( hb, sprintf( 'detected (%d [%.1f%%])', ndstops, 100 * ndstops / nresplabs ), ...
			'Location', 'northwest' );

		subplot( 2, 2, 4 ); % cumulative

		xlabel( 'range stop delta in milliseconds' );
		ylabel( 'cumulative rate in percent' );

		xlim( [0, 1000 * MAXDELTA] );
		ylim( [0, 100] );

		hb = bar( 1000 * valdstoppos, 100 * cumsum( valdstopns ) / ndstops, ...
			'BarWidth', 1, 'FaceColor', style.color( 'cold', 0 ), 'EdgeColor', 'none' );

		legend( hb, sprintf( 'valid (%d [%.1f%%])', nvaldstops, 100 * nvaldstops / nresplabs ), ...
			'Location', 'southeast' );

			% done
		style.print( plotfile );

		delete( fig );

	end

		% proceed subjects
	global_nruns = 0; % pre-allocation

	global_sexes = cell( 1, max( ids ) );

	global_ntrials = zeros( 1, max( ids ) );
	global_nresplabs = zeros( 1, max( ids ) );

	global_dstarts = [];
	global_ndstarts = 0;
	global_dstops = [];
	global_ndstops = 0;

	global_valdstarts = [];
	global_nvaldstarts = 0;
	global_valdstops = [];
	global_nvaldstops = 0;

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

			% gather stats
		resplabs = [run.trials.resplab];
		respdets = [run.trials.respdet];

		rlabs = cat( 1, resplabs.range ); % comparable ranges
		uclabs = isnan( diff( rlabs, 1, 2 ) );
		rdets = cat( 1, respdets.range );
		ucdets = isnan( diff( rdets, 1, 2 ) );

		rlabs(uclabs | ucdets, :) = [];
		rdets(uclabs | ucdets, :) = [];

		dstarts = rdets(:, 1) - rlabs(:, 1); % range deltas
		ndstarts = numel( dstarts );
		dstops = rdets(:, 2) - rlabs(:, 2);
		ndstops = numel( dstops );

		valdstarts = abs( dstarts(dstarts <= 0) );
		nvaldstarts = numel( valdstarts );
		valdstops = dstops(dstops >= 0);
		nvaldstops = numel( valdstops );

		global_nruns = global_nruns + 1; % global stats

		global_sexes{i} = run.sex;

		global_ntrials(i) = numel( run.trials );
		global_nresplabs(i) = sum( ~uclabs );

		global_dstarts = cat( 1, global_dstarts, dstarts );
		global_ndstarts = global_ndstarts + ndstarts;
		global_dstops = cat( 1, global_dstops, dstops );
		global_ndstops = global_ndstops + ndstops;

		global_valdstarts = cat( 1, global_valdstarts, valdstarts );
		global_nvaldstarts = global_nvaldstarts + nvaldstarts;
		global_valdstops = cat( 1, global_valdstops, valdstops );
		global_nvaldstops = global_nvaldstops + nvaldstops;

		dstarts(abs( dstarts ) > MAXDELTA ) = []; % binning
		valdstarts(abs( valdstarts ) > MAXDELTA ) = [];
		dstops(abs( dstops ) > MAXDELTA ) = [];
		valdstops(abs( valdstops ) > MAXDELTA ) = [];

		dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) );
		dstartns = hist( dstarts, dstartpos );
		valdstartpos = linspace( min( valdstarts ), max( valdstarts ), style.bins( valdstarts ) );
		valdstartns = hist( valdstarts, valdstartpos );

		dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) );
		dstopns = hist( dstops, dstoppos );
		valdstoppos = linspace( min( valdstops ), max( valdstops ), style.bins( valdstops ) );
		valdstopns = hist( valdstops, valdstoppos );

			% plot stats
		plotfile = fullfile( outdir, sprintf( 'activity_%d.png', i ) );
		figtitle = sprintf( 'ACTIVITY (subject: %d, resps: %d/%d)', i, global_nresplabs(i), global_ntrials(i) );

		figstats( plotfile, figtitle, ...
			global_nresplabs(i), ...
			dstarts, dstartpos, dstartns, ndstarts, valdstartpos, valdstartns, nvaldstarts, ...
			dstops, dstoppos, dstopns, ndstops, valdstoppos, valdstopns, nvaldstops )

			% clean up
		delete( run );

		logger.untab();
	end

		% post-process global stats
	global_dstarts(abs( global_dstarts ) > MAXDELTA ) = []; % binning
	global_valdstarts(abs( global_valdstarts ) > MAXDELTA ) = [];
	global_dstops(abs( global_dstops ) > MAXDELTA ) = [];
	global_valdstops(abs( global_valdstops ) > MAXDELTA ) = [];

	global_dstartpos = linspace( min( global_dstarts ), max( global_dstarts ), style.bins( global_dstarts ) );
	global_dstartns = hist( global_dstarts, global_dstartpos );
	global_valdstartpos = linspace( min( global_valdstarts ), max( global_valdstarts ), style.bins( global_valdstarts ) );
	global_valdstartns = hist( global_valdstarts, global_valdstartpos );

	global_dstoppos = linspace( min( global_dstops ), max( global_dstops ), style.bins( global_dstops ) );
	global_dstopns = hist( global_dstops, global_dstoppos );
	global_valdstoppos = linspace( min( global_valdstops ), max( global_valdstops ), style.bins( global_valdstops ) );
	global_valdstopns = hist( global_valdstops, global_valdstoppos );

		% plot global stats
	plotfile = fullfile( outdir, 'activity.png' );
	figtitle = sprintf( 'ACTIVITY (subjects: %d, resps: %d/%d)', global_nruns, sum( global_nresplabs ), sum( global_ntrials ) );

	figstats( plotfile, figtitle, ...
		sum( global_nresplabs ), ...
		global_dstarts, global_dstartpos, global_dstartns, global_ndstarts, global_valdstartpos, global_valdstartns, global_nvaldstarts, ...
		global_dstops, global_dstoppos, global_dstopns, global_ndstops, global_valdstoppos, global_valdstopns, global_nvaldstops )

		% plot summary
	plotfile = fullfile( outdir, 'activity_sum.png' );
	logger.log( 'plot activity summary (''%s'')...', plotfile );

		% done
	logger.untab( 'done' );

end

