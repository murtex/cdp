function convert( indir, outdir, ids )
% conversion stats
%
% CONVERT( indir, outdir, ids )
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
	logger.tab( 'conversion stats...' );

	style = xis.hStyle.instance();

		% proceed subjects
	sexes = cell( 1, max( ids ) ); % pre-allocation
	ntrials = zeros( 1, max( ids ) );
	nresps = zeros( 1, max( ids ) );

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
		sexes{i} = run.sex;

		ntrials(i) = numel( run.trials );

		resps = [run.trials.resplab];
		ranges = cat( 1, resps.range );
		nresps(i) = sum( ~isnan( diff( ranges, 1, 2 ) ) ); % validate by response ranges

			% clean up
		delete( run );

		logger.untab();
	end

		% post-process stats
	fmals = false( 1, max( ids ) );
	ffems = false( 1, max( ids ) );

	for i = ids
		if strcmp( sexes{i}, 'm' ) % male
			fmals(i) = true;
		elseif strcmp( sexes{i}, 'w' ) % female
			ffems(i) = true;
		end
	end

		% plot stats
	plotfile = fullfile( outdir, sprintf( 'convert_%s.png', stamp ) );
	logger.log( 'plot conversion stats (''%s'')...', plotfile );

	fig = style.figure();

	title( sprintf( 'CONVERT [subjects: (%d+%d)/%d, trials: (%d+%d)/%d]', ...
		sum( fmals ), sum( ffems ), numel( ids ), ...
		sum( ntrials(fmals) ), sum( ntrials(ffems) ), sum( ntrials ) ) );
	xlabel( 'subject identifier' );
	ylabel( 'number of trials/responses' );

	xl = [min( ids ) - 0.5, max( ids ) + 0.5];
	xlim( xl );
	ylim( [0, max( ntrials )] );

			% males
	hbm = bar( ids(fmals), cat( 2, transpose( nresps(fmals) ), transpose( ntrials(fmals) - nresps(fmals) ) ), ...
		'stacked', 'BarWidth', 1 );
	set( hbm(1), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'cold', 0 ) );
	set( hbm(2), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'cold', +2 ) );

			% females
	hbf = bar( ids(ffems), cat( 2, transpose( nresps(ffems) ), transpose( ntrials(ffems) - nresps(ffems) ) ), ...
		'stacked', 'BarWidth', 1 );
	set( hbf(1), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'warm', -1 ) );
	set( hbf(2), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'warm', +1 ) );

			% legend
	legend( [hbm(2), hbf(2)], {'male', 'female'}, 'Location', 'southeast' );

			% print
	style.print( plotfile );

	delete( fig );

		% done
	logger.untab( 'done' );

end

