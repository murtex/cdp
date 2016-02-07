function sync( indir, outdir, ids, logfile )
% marker synchronization
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

	cfg = cdf.hConfig(); % configure framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'marker synchronization...' );

		% workload
	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) ); % cdf data
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: ''%s''', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

		proc.read_audio( run, run.audiofile ); % audio data

			% sync markers
		[sync0, synchints, syncs] = cdf.sync( run, cfg );

			% write data
		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', id ) ); % cdf data
		logger.log( 'write cdf data (''%s'')...', cdffile );

		run.audiodata = []; % do not write redundant audio data

		save( cdffile, 'run' );

		auxfile = fullfile( outdir, sprintf( 'run_%d_aux.mat', id ) ); % auxiliary data
		logger.log( 'write auxiliary data (''%s'')...', auxfile );

		save( auxfile, 'sync0', 'synchints', 'syncs' );

		cfgfile = fullfile( outdir, sprintf( 'run_%d_cfg.mat', id ) ); % configuration
		logger.log( 'write configuration (''%s'')...', cfgfile );

		save( cfgfile, 'cfg' );

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

