function vots( indir, outdir, ids, logfile )
% vot distributions
%
% VOTS( indir, outdir, ids, logfile )
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
	logger.tab( 'vot distributions' );

	style = xis.hStyle.instance();

		% helpers
	function plot_vots( stitle, tavots, kavots )

			% prepare data
		MAXVOT = 0.2;
		MAXVOT = 5; % standardized

		SCALE = 1000;
		SCALE = 1; % standardized

		tavots(abs( tavots ) > MAXVOT) = []; % remove outliers
		kavots(abs( kavots ) > MAXVOT) = [];

		ntavots = numel( tavots );
		nkavots = numel( kavots );

		nbins = max( style.bins( tavots ), 2 * style.bins( kavots ) ); % uniform binning

		tavotpos = linspace( min( tavots ), max( tavots ), nbins );
		tavotns = hist( tavots, tavotpos );

		kavotpos = linspace( min( kavots ), max( kavots ), nbins );
		kavotns = hist( kavots, kavotpos );

			% prepare axes scaling
		yl = [0, ceil( max( cat( 2, tavotns/ntavots, kavotns/nkavots ) ) * 10 + 1 ) / 10 ] * 100;

		xl = [0, MAXVOT] * SCALE;
		xlmin = min( cat( 2, tavots, kavots ) ); % standardized
		xlmax = max( cat( 2, tavots, kavots ) );
		xl = round( max( abs( xlmin ), abs( xlmax ) ) ) * [-1, 1];

			% plot ta vots
		subplot( 2, 1, 1 );
		title( stitle );
		xlabel( 'vot in milliseconds' );
		xlabel( 'standardized vot (z-score)' ); % standardized
		ylabel( 'rate in percent' );

		xlim( xl );
		ylim( yl );

		bar( tavotpos * SCALE, tavotns/ntavots * 100, ... % distribution
			'BarWidth', 1, ...
			'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

		hl = legend( 'ta', 'Location', 'northeast' ); % legend
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

			% plot ka vots
		subplot( 2, 1, 2 );
		xlabel( 'vot in milliseconds' );
		xlabel( 'standardized vot (z-score)' ); % standardized
		ylabel( 'rate in percent' );

		xlim( xl );
		ylim( yl );

		bar( kavotpos * SCALE, kavotns/nkavots * 100, ... % distribution
			'BarWidth', 1, ...
			'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );

		hl = legend( 'ka', 'Location', 'northeast' ); % legend
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

	end

		% workload
	acc_tavots = cell( 1, numel( ids ) );
	acc_kavots = cell( 1, numel( ids ) );

	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) );
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: %s', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

			% prepare trials
		trials = [run.trials];

		distlabels = {trials.distlabel}; % none distractor condition
		%trials(~strcmp( distlabels, 'none' )) = [];

		vals = is_valid( [trials.resplab], 'class' ) & is_valid( [trials.resplab], 'landmarks' ); % validity
		trials(~vals) = [];

		resps = [trials.resplab];

		labels = {resps.label};
		taresps = resps(strcmp( labels, 'ta' ));
		karesps = resps(strcmp( labels, 'ka' ));

			% gather vots
		tavots = zscore( [taresps.vo] - [taresps.bo] );
		kavots = zscore( [karesps.vo] - [karesps.bo] );

		acc_tavots{cid} = tavots; % accumulate
		acc_kavots{cid} = kavots;

			% plot vots
		figfile = fullfile( outdir, sprintf( 'run_%d.png', id ) );
		logger.log( 'plot vot distributions (''%s'')...', figfile );
		
		fig = style.figure();

		plot_vots( ...
			sprintf( 'VOTS (subject: #%d, trials: %d [%d+%d])', id, numel( tavots ) + numel( kavots ), numel( tavots ), numel( kavots ) ), ...
			tavots, kavots );

		style.print( figfile );
		delete( fig );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% output accumulated vots
	[~, logname, ~] = fileparts( logfile );
	tafile = fullfile( outdir, sprintf( '%s_ta.mat', logname ) );
	kafile = fullfile( outdir, sprintf( '%s_ka.mat', logname ) );

	save( tafile, 'acc_tavots' );
	save( kafile, 'acc_kavots' );

		% plot accumulated vots
	tavots = cat( 2, acc_tavots{:} );
	kavots = cat( 2, acc_kavots{:} );

	figfile = fullfile( outdir, sprintf( '%s.png', logname ) );
	logger.log( 'plot vot distributions (''%s'')...', figfile );

	fig = style.figure();

	plot_vots( ...
		sprintf( 'VOTS (subjects: %d, trials: %d [%d+%d])', numel( ids ), numel( tavots ) + numel( kavots ), numel( tavots ), numel( kavots ) ), ...
		tavots, kavots );

	style.print( figfile );
	delete( fig );

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

