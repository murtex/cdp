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
			if any( isnan( trials(i).resplab.range ) ) || any( isnan( trials(i).respdet.range ) )
				f(i) = false;
			end
		end
	end

	function plot_stats( stitle, dstarts, dstops )

			% prepare data
		ndstarts = numel( dstarts );
		ndstops = numel( dstops );

		MAXDELTA = 0.1; % binning

		dstarts = dstarts(abs( dstarts) <= MAXDELTA);
		dstartpos = linspace( min( dstarts ), max( dstarts ), style.bins( dstarts ) );
		dstartns = hist( dstarts, dstartpos );

		dstops = dstops(abs( dstops) <= MAXDELTA);
		dstoppos = linspace( min( dstops ), max( dstops ), style.bins( dstops ) );
		dstopns = hist( dstops, dstoppos );

		absdstarts = abs( dstarts ); % cumulative binning
		absdstartpos = linspace( min( absdstarts ), max( absdstarts ), style.bins( absdstarts ) );
		absdstartns = hist( absdstarts, absdstartpos );

		absdstops = abs( dstops );
		absdstoppos = linspace( min( absdstops ), max( absdstops ), style.bins( absdstops ) );
		absdstopns = hist( absdstops, absdstoppos );

			% plot start deltas
		subplot( 3, 2, 1 );
		title( stitle );
		xlabel( 'start delta in milliseconds' );
		ylabel( 'rate in percent' );

		xlim( MAXDELTA * [-1, 1] * 1000 );
		ylim( [0, 1] * 100 );

		bar( dstartpos * 1000, dstartns/ndstarts * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

			% plot cumulative start deltas
		subplot( 3, 2, 2 );
		xlabel( 'abs(delta) in milliseconds' );
		ylabel( 'cumulative rate in percent' );

		xlim( MAXDELTA * [0, 1] * 1000 );
		ylim( [0, 1] * 100 );

		bar( absdstartpos * 1000, cumsum( absdstartns )/ndstarts * 100, ... % deltas
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

		hl = legend( sprintf( 'outlying: %.2f%%', (1 - numel( absdstarts )/ndstarts) * 100 ), ... % legend
			'Location', 'southeast' );
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

			% plot stop deltas
		subplot( 3, 2, 3 );
		xlabel( 'stop delta in milliseconds' );
		ylabel( 'rate in percent' );

		xlim( MAXDELTA * [-1, 1] * 1000 );
		ylim( [0, 1] * 100 );

		bar( dstoppos * 1000, dstopns/ndstops * 100, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

			% plot cumulative stop deltas
		subplot( 3, 2, 4 );
		xlabel( 'abs(delta) in milliseconds' );
		ylabel( 'cumulative rate percent' );

		xlim( MAXDELTA * [0, 1] * 1000 );
		ylim( [0, 1] * 100 );

		bar( absdstoppos * 1000, cumsum( absdstopns )/ndstops * 100, ... % deltas
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

		hl = legend( sprintf( 'outlying: %.2f%%', (1 - numel( absdstops )/ndstops) * 100 ), ... % legend
			'Location', 'southeast' );
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

	end

	function plot_rates( sxlabel, ids, totlens, lablens, h1s, fa1s );

			% prepare data
		hr1s = h1s ./ lablens; % speech hit rate
		hr1 = sum( h1s ) / sum( lablens );
		far1s = fa1s ./ (totlens - lablens); % speech false alarm rate
		far1 = sum( fa1s ) / sum( totlens - lablens );

			% plot non-speech false alarm rate (far0 = 1 - hr1)
		subplot( 3, 2, 5 );
		xlabel( sxlabel );
		ylabel( {'far0 in percent', '(non-speech false alarm)'} );
		
		xlim( [min( ids ), max( ids )] );

		stairs( [ids, ids(end)] - 1/2, (1 - [hr1s; hr1s(end)]) * 100, ... % individual
			'Color', style.color( 'neutral', 0 ) );

		h = plot( xlim(), (1 - hr1) * [1, 1] * 100, ... % total
			'Color', style.color( 'cold', +2 ), ...
			'DisplayName', sprintf( 'total: %.2f%%', (1 - hr1) * 100 ) );

		hl = legend( h, 'Location', 'northeast' ); % legend
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

			% plot non-speech hit rate (hr0 = 1 - far1)
		subplot( 3, 2, 6 );
		xlabel( sxlabel );
		ylabel( {'hr0 in percent', '(non-speech hit)'} );

		xlim( [min( ids ), max( ids )] );

		stairs( [ids, ids(end)] - 1/2, (1 - [far1s; far1s(end)]) * 100, ... % individual
			'Color', style.color( 'neutral', 0 ) );

		h = plot( xlim(), (1 - far1) * [1, 1] * 100, ... % total
			'Color', style.color( 'cold', +2 ), ...
			'DisplayName', sprintf( 'total: %.2f%%', (1 - far1) * 100 ) );

		hl = legend( h, 'Location', 'southeast' ); % legend
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

	end

		% workload
	acc_ntrials = 0;
	acc_ntottrials = 0;

	acc_dstarts = [];
	acc_dstops = [];

	acc_totlens = NaN( numel( ids ), 1 );
	acc_lablens = NaN( numel( ids ), 1 );
	acc_h1s = NaN( numel( ids ), 1 );
	acc_fa1s = NaN( numel( ids ), 1 );

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

		resplabs = [trials.resplab];
		respdets = [trials.respdet];

			% gather statistics
		ntrials = numel( trials ); % trial numbers
		ntottrials = numel( run.trials );

		acc_ntrials = acc_ntrials + ntrials;
		acc_ntottrials = acc_ntottrials + ntottrials;

		logger.log( 'comparable trials: %d/%d', ntrials, ntottrials );

		labrs = cat( 1, resplabs.range ); % range deltas
		detrs = cat( 1, respdets.range );

		dstarts = detrs(:, 1) - labrs(:, 1);
		dstops = detrs(:, 2) - labrs(:, 2);

		acc_dstarts = cat( 1, acc_dstarts, dstarts );
		acc_dstops = cat( 1, acc_dstops, dstops );

		totlens = NaN( ntrials, 1 ); % perfomance rates
		lablens = NaN( ntrials, 1 );
		h1s = NaN( ntrials, 1 );
		fa1s = NaN( ntrials, 1 );

		for i = 1:ntrials
			totr = dsp.sec2smp( trials(i).range, run.audiorate ) + [1, 0]; % total range
			totr = totr(1):totr(2);
			totlens(i) = numel( totr );

			labr = dsp.sec2smp( resplabs(i).range, run.audiorate ) + [1, 0]; % manual range
			labr = labr(1):labr(2);
			lablens(i) = numel( labr );

			detr = dsp.sec2smp( respdets(i).range, run.audiorate ) + [1, 0]; % detected range
			detr = detr(1):detr(2);

			h1s(i) = numel( intersect( detr, labr ) ); % speech hits
			fa1s(i) = numel( setdiff( detr, labr ) ); % speech false alarms
		end

		acc_totlens(cid) = sum( totlens );
		acc_lablens(cid) = sum( lablens );
		acc_h1s(cid) = sum( h1s );
		acc_fa1s(cid) = sum( fa1s );

		hr1 = sum( h1s ) / sum( lablens ); % logging
		far1 = sum( fa1s ) / sum( totlens - lablens );

		logger.log( 'far0 (non-speech false alarm rate): %.2f%%', (1 - hr1) * 100 );
		logger.log( 'hr0 (non-speech hit rate): %.2f%%', (1 - far1) * 100 );

			% plot statistics
		figfile = fullfile( outdir, sprintf( 'run_%d.png', id ) );
		logger.log( 'plot activity detection statistics (''%s'')...', figfile );

		fig = style.figure();

		plot_stats( ...
			sprintf( 'ACTIVITY (subject: #%d, trials: %d/%d)', id, ntrials, ntottrials ), ...
			dstarts, dstops );

		plot_rates( 'trial index', 1:ntrials, totlens, lablens, h1s, fa1s );

		style.print( figfile );
		delete( fig );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% logging accumulated statistics
	logger.log( 'comparable trials: %d/%d', acc_ntrials, acc_ntottrials );

	acc_hr1 = sum( acc_h1s ) / sum( acc_lablens );
	acc_far1 = sum( acc_fa1s ) / sum( acc_totlens - acc_lablens );

	logger.log( 'far0 (non-speech false alarm rate): %.2f%%', (1 - acc_hr1) * 100 );
	logger.log( 'hr0 (non-speech hit rate): %.2f%%', (1 - acc_far1) * 100 );

		% plot accumulated statistics
	[~, logname, ~] = fileparts( logfile );
	figfile = fullfile( outdir, sprintf( '%s.png', logname ) );
	logger.log( 'plot activity detection statistics (''%s'')...', figfile );

	fig = style.figure();

	plot_stats( ...
		sprintf( 'ACTIVITY (subjects: %d, trials: %d/%d)', numel( ids ), acc_ntrials, acc_ntottrials ), ...
		acc_dstarts, acc_dstops );

	plot_rates( 'subject identifier', ids, acc_totlens, acc_lablens, acc_h1s, acc_fa1s );

	style.print( figfile );
	delete( fig );

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

