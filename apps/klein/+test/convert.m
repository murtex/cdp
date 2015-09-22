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
	ntrials(ids) = 0; % pre-allocation
	nlabtrials(ids) = 0;

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

			% update trial numbers
		ntrials(i) = numel( run.trials );

		resps = run.resps_lab;
		ranges = cat( 1, resps.range );
		nlabtrials(i) = sum( ~isnan( diff( ranges, 1, 2 ) ) ); % validate by trial range

			% clean up
		delete( run );

		logger.untab();
	end

		% plot trial numbers
	plotfile = fullfile( outdir, sprintf( 'convert_%s.png', stamp ) );
	logger.log( 'plot trial numbers (''%s'')...', plotfile );

	fig = style.figure();

	title( sprintf( 'conversion (subjects: %d)', numel( ids ) ) );
	xlabel( 'subject identifier' );
	ylabel( 'number of trials' );

	xlim( [min( ids )-0.5, max( ids )+0.5] );
	ylim( [0, max( ntrials )] );

	hb = bar( ids, cat( 2, transpose( nlabtrials ), transpose( ntrials-nlabtrials ) ), ...
		'stacked', 'BarWidth', 1 );

	set( hb(1), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'cold', 0 ) );
	set( hb(2), 'EdgeColor', style.color( 'neutral', -2 ), 'FaceColor', style.color( 'cold', +2 ) );

	legend( [hb(2), hb(1)], {'total', 'labeled'}, ...
		'Location', 'southeast' );

	style.print( plotfile );

	delete( fig );

		% done
	logger.untab( 'done' );

end

