function sfb( indir, outdir, ids, dist, resp, logfile )
% VOT/F1 relation check
% 
% SFB( indir, outdir, ids, dist, resp, logfile )
% 
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% dist : distractor pattern (row char)
% resp : response pattern (row char)
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

	if nargin < 4 || ~isrow( dist ) || ~ischar( dist ) % distractor pattern
		error( 'invalid argument: dist' );
	end

	if nargin < 5 || ~isrow( resp ) || ~ischar( resp ) % response pattern
		error( 'invalid argument: resp' );
	end

	if nargin < 6 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework
	addpath( '../../../akde/' );

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'VOT/F1 relation check...' );

	style = xis.hStyle.instance();

		% two-dimensional histogram
	function ns = hist2( v1, v2, p1, p2 )
		ns = zeros( numel( p1 ), numel( p2 ) );

		for i = 1:numel( v1 )
			[~, i1] = min( abs( v1(i)-p1 ) );
			[~, i2] = min( abs( v2(i)-p2 ) );
			ns(i1, i2) = ns(i1, i2) + 1;
		end
	end

		% plot check
	PLOTWIDTH = 409; % 6*59pt
	PLOTRATIO = 1; % (1+sqrt( 5 ))/2;
	PLOTEXT = 'png';

	BINFACTOR = 1;

	function plot_check( figfile, figtitle, vots, f1s, total )
		fig = style.figure( 'PaperPosition', [0, 0, (1/2 + 1) * PLOTWIDTH, 1 * PLOTWIDTH/PLOTRATIO] );
		logger.log( 'plot check (''%s'')...', figfile );

			% one-dimensional distributions
		votpos = linspace( min( vots ), max( vots ), BINFACTOR*style.bins( vots ) );
		[votns, votpos] = hist( vots, votpos );
		f1pos = linspace( min( f1s ), max( f1s ), BINFACTOR*style.bins( f1s ) );
		[f1ns, f1pos] = hist( f1s, f1pos );

		[svotns, svotpos] = ksdensity( vots );
		[sf1ns, sf1pos] = ksdensity( f1s );

		votlim = [min( votpos ), max( votpos )];
		f1lim = [min( f1pos ), max( f1pos )];

			% two-dimensional distributions
		relns = hist2( vots, f1s, votpos, f1pos );
		%relns = hist3( cat( 2, vots, f1s ), BINFACTOR*[style.bins( f1s ), style.bins( vots )] );

		[srelns, srelvotpos, srelf1pos] = akde( cat( 2, vots, f1s ) );

			% plot relation check
		subplot( 2, 3, [1, 5] );

		title( figtitle );

		xlabel( 'voice onset time in sigmas' );
		ylabel( 'f1 onset frequency in sigmas' );

		xlim( votlim );
		ylim( f1lim );

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -2 ) ) );
		imagesc( votpos, f1pos, flipud( transpose( relns ) ) );
		%imagesc( srelvotpos(1, :), srelf1pos(:, 1), flipud( reshape( srelns, size( srelvotpos ) ) ) );
		contour( srelvotpos, srelf1pos, flipud( reshape( srelns, size( srelvotpos ) ) ) );

			% plot vots
		subplot( 2, 3, 3 );

		xlabel( 'voice onset time in sigmas' );
		ylabel( 'rate' );

		xlim( votlim );

		bar( votpos, votns / numel( vots ), ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		plot( svotpos, svotns, ...
			'Color', style.color( 'neutral', 0 ) );

			% plot formant onsets
		subplot( 2, 3, 6 );

		xlabel( 'f1 onset frequency in sigmas' );
		ylabel( 'rate' );

		xlim( f1lim );

		bar( f1pos, f1ns / numel( f1s ), ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		plot( sf1pos, sf1ns, ...
			'Color', style.color( 'neutral', 0 ) );

		style.print( figfile );
		delete( fig );
	end

		% workload
	ga_vots = []; % global accumulation
	ga_f1s = [];
	ga_total = 0;

	sdist = 'all'; % prepare figure file name
	sresp = 'all';

	if dist ~= '*'
		sdist = dist;
	end
	if resp ~= '*'
		sresp = resp;
	end

	cid = 1; % proceed subjects
	for id = ids
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) );
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: %s', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

			% gather local statistics
		trials = [run.trials];
		resps = [trials.resplab];

		filt1 = true( size( trials ) ); % filter by distractors
		if dist ~= '*'
			filt1 = strcmp( {trials.distlabel}, dist );
		end

		total = numel( trials(filt1) );

		filt2 = true( size( trials ) ); % filter by response
		if resp ~= '*'
			filt2 = strcmp( {resps.label}, resp );
		end

		trials = trials(filt1 & filt2); % get vots and f1 onset frequencies
		resps = resps(filt1 & filt2);

		vots = transpose( [resps.vo] - [resps.bo] );
		f1s = cat( 1, resps.f1 );
		f1s = f1s(:, 2);

		invalids = isnan( vots ) | isnan( f1s );
		vots(invalids) = [];
		f1s(invalids) = [];

		vots = zscore( vots ); % normalize
		f1s = zscore( f1s );

			% plot local statistics
		figfile = fullfile( outdir, sprintf( '%s_%s_%d.%s', sdist, sresp, id, PLOTEXT ) );
		plot_check( figfile, sprintf( 'dist: %s, resp: %s, trials: %d/%d', sdist, sresp, numel( vots ), total ), vots, f1s, total );

			% accumulate global statistics
		ga_vots = cat( 1, ga_vots, vots );
		ga_f1s = cat( 1, ga_f1s, f1s );
		ga_total = ga_total + total;

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% plot global statistics
	figfile = fullfile( outdir, sprintf( '%s_%s.%s', sdist, sresp, PLOTEXT ) );
	plot_check( figfile, sprintf( 'dist: %s, resp: %s, trials: %d/%d', sdist, sresp, numel( ga_vots ), ga_total ), ga_vots, ga_f1s, ga_total );

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

