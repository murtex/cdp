function test( indir, outdir, ids )
% test template
%
% TEST( indir, outdir, ids )
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
	logger.tab( 'test template...' );

		% proceed subjects
	global_respstops = [];

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
		trials = [run.trials];
		resplabs = [run.trials.resplab];
		respdets = [run.trials.respdet];

		labr = cat( 1, resplabs.range );

		respstops = labr(:, 2) - transpose( [trials.cue] );
		global_respstops = cat( 1, global_respstops, respstops );

			% log stats
		max( respstops )

			% clean up
		delete( run );

		logger.untab();
	end

		% log global stats
	max( global_respstops )

		% done
	logger.untab( 'done' );

end

