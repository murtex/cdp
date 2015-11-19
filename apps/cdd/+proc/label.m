function label( indir, outdir, ids, labmode, logfile )
% labeling tool
%
% LABEL( indir, outdir, ids, labmode, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (vector numeric)
% labmode : labeling mode [activity | landmarks | formants] (row char)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isvector( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isrow( labmode ) || ~ischar( labmode ) % labeling mode
		error( 'invalid argument: labmode' );
	end

	if nargin < 5 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	cfg = cdf.hConfig(); % configure framework

	cfg.lab_activity_det1 = [-0.025, 0.05];
	cfg.lab_activity_det2 = [-0.05, 0.025];
	cfg.lab_activity_zcsnap = false;

	cfg.lab_landmarks_det1 = [-0.003, 0.006];
	cfg.lab_landmarks_det2 = [-0.015, 0.030];
	cfg.lab_landmarks_det3 = [-0.030, 0.015];
	cfg.lab_landmarks_zcsnap = [false, true, true];

	cfg.lab_formants_freqband = [0, 1200];
	cfg.lab_formants_nfreqs = 100;
	cfg.lab_formants_gamma = 1.0;

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'labeling tool...' );

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

			% labeling
		switch labmode
			case 'activity'
				cdf.label_activity( run, cfg );
			case 'landmarks'
				cdf.label_landmarks( run, cfg );
			case 'formants'
				cdf.label_formants( run, cfg );
			otherwise
				error( 'invalid argument: labmode' );
		end
	
			% write data
		cdffile = fullfile( outdir, sprintf( 'run_%d.mat', id ) ); % cdf data
		logger.log( 'write cdf data (''%s'')...', cdffile );

		run.audiodata = []; % do not write redundant audio data

		save( cdffile, 'run' );

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

