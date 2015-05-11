% sync timing

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/eyetrack/sync.log' ); % start logging

	% proceed experiments
for i = 1:2
	logger.tab( 'experiment: %d', i );

		% prepare directories
	indir = sprintf( '../data/eyetrack/%d/cdf/convert/', i );

	outdir = sprintf( '../data/eyetrack/%d/cdf/sync/', i );
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	plotdir = sprintf( '../data/eyetrack/%d/plot/sync/', i );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% proceed subjects
	ids = 16;

	for id = ids
		logger.tab( 'subject: %d', id );

			% read data
		infile = fullfile( indir, sprintf( '%d.mat', id ) );
		if exist( infile, 'file' ) ~= 2 % skip non-existent data
			logger.untab( 'skipping' );
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, 'run' );

		read_audio( run, run.audiofile, false );

			% sync timing
		offs = cdf.sync( run, cfg, false );

			% plot sync marker offsets
		cdf.plot.sync( run, offs, fullfile( plotdir, sprintf( '%d_sync', run.id ) ) );

			% write data
		run.audiodata = []; % do not write audio data

		outfile = fullfile( outdir, sprintf( '%d.mat', run.id ) );
		logger.log( 'write cdf ''%s''...', outfile );
		save( outfile, 'run' );

			% clean-up
		delete( run );

		logger.untab();
	end

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

