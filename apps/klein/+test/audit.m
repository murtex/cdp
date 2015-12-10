function audit( indir, ids, audmode, logfile )
% auditing tool
%
% AUDIT( indir, ids, audmode, logfile )
%
% INPUT
% indir : input directory (row char)
% ids : subject identifiers (vector numeric)
% audmode : auditing mode [activity | landmarks | formants] (row char)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isvector( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 3 || ~isrow( audmode ) || ~ischar( audmode ) % auditing mode
		error( 'invalid argument: audmode' );
	end

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	addpath( '../../cdf/' ); % include framework

	cfg = cdf.hConfig(); % configure framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'auditing tool...' );

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

			% auditing
		switch audmode
			case 'activity'
				cdf.audit.activity( run, cfg );
			case 'landmarks'
				cdf.audit.landmarks( run, cfg );
			case 'formants'
				cdf.audit.formants( run, cfg );
			otherwise
				error( 'invalid argument: audmode' );
		end
	
			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end


