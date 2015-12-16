function activity( indir, outdir, ids, logfile )
% activity detection statistics
%
% ACTIVITY( indir, outdir, ids, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (vector numeric)
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

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'activity detection statistics...' );

	style = xis.hStyle.instance();

		% helpers
	function f = is_comparable( trials )
		f = true( numel( trials ) );
		for i = 1:numel( trials )
			if isnan( trials(i).resplab.bo ) || isnan( trials(i).resplab.vr ) ...
					|| any( isnan( trials(i).respdet.range ) )
				f(i) = false;
			end
		end
	end

	function plot_stats( stitle, dstarts, dstops )

			% prepare data
		ndstarts = numel( dstarts );
		ndstops = numel( dstops );

		MAXDELTA = 0.3; % binning

		dstarts = dstarts(abs( dstarts) <= MAXDELTA);
		dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) );
		dstartns = hist( dstarts, dstartpos );

		dstops = dstops(abs( dstops) <= MAXDELTA);
		dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) );
		dstopns = hist( dstops, dstoppos );

		valdstarts = abs( dstarts(dstarts <= 0) ); % cumulative binning
		valdstartpos = linspace( min( valdstarts ), max( valdstarts ), style.bins( valdstarts ) );
		valdstartns = hist( valdstarts, valdstartpos );

		valdstops = dstops(dstops >= 0);
		valdstoppos = linspace( min( valdstops ), max( valdstops ), style.bins( valdstops ) );
		valdstopns = hist( valdstops, valdstoppos );

			% plot start deltas
		subplot( 2, 2, 1 );
		title( stitle );
		xlabel( 'start delta in milliseconds' );
		ylabel( 'rate in percent' );

		xlim( MAXDELTA * [-1, 1] * 1000 );
		ylim( [0, 100] );

		bar( dstartpos * 1000, dstartns / ndstarts * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

			% plot cumulative start deltas
		subplot( 2, 2, 2 );
		xlabel( 'valid delta in milliseconds' );
		ylabel( 'cumulative rate in percent' );

		xlim( MAXDELTA * [0, 1] * 1000 );
		ylim( [0, 100] );

		bar( valdstartpos * 1000, cumsum( valdstartns ) / ndstarts * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

			% plot stop deltas
		subplot( 2, 2, 3 );
		xlabel( 'stop delta in milliseconds' );
		ylabel( 'rate in percent' );

		xlim( MAXDELTA * [-1, 1] * 1000 );
		ylim( [0, 100] );

		bar( dstoppos * 1000, dstopns / ndstops * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

			% plot cumulative stop deltas
		subplot( 2, 2, 4 );
		xlabel( 'valid delta in milliseconds' );
		ylabel( 'cumulative rate in percent' );

		xlim( MAXDELTA * [0, 1] * 1000 );
		ylim( [0, 100] );

		bar( valdstoppos * 1000, cumsum( valdstopns ) / ndstops * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

	end

		% workload
	acc_ntrials = 0;
	acc_ntottrials = 0;

	acc_dstarts = [];
	acc_dstops = [];

	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) ); % cdf
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: %s', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

			% prepare comparable trials
		trials = [run.trials];
		trials(~is_comparable( trials )) = [];

		logger.log( 'comparable trials: %d/%d', numel( trials ), numel( run.trials ) );

			% gather statistics
		resplabs = [trials.resplab];
		respdets = [trials.respdet];
		resprs = cat( 1, respdets.range );

		ntrials = numel( trials );
		ntottrials = numel( run.trials );

		dstarts = resprs(:, 1) - transpose( [resplabs.bo] );
		dstops = resprs(:, 2) - transpose( [resplabs.vr] );

		acc_ntrials = acc_ntrials + ntrials; % accumulate
		acc_ntottrials = acc_ntottrials + ntottrials;

		acc_dstarts = cat( 1, acc_dstarts, dstarts );
		acc_dstops = cat( 1, acc_dstops, dstops );

			% plot statistics
		figfile = fullfile( outdir, sprintf( 'run_%d.png', id ) );
		logger.log( 'plot activity detection statistics (''%s'')...', figfile );

		fig = style.figure();

		plot_stats( ...
			sprintf( 'ACTIVITY (subject: #%d, trials: %d/%d)', id, ntrials, ntottrials ), ...
			dstarts, dstops );

		style.print( figfile );
		delete( fig );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% plot accumulated statistics
	[~, logname, ~] = fileparts( logfile );
	figfile = fullfile( outdir, sprintf( '%s.png', logname ) );
	logger.log( 'plot activity detection statistics (''%s'')...', figfile );

	fig = style.figure();

	plot_stats( ...
		sprintf( 'ACTIVITY (subjects: %d, trials: %d/%d)', numel( ids ), acc_ntrials, acc_ntottrials ), ...
		acc_dstarts, acc_dstops );

	style.print( figfile );
	delete( fig );

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

