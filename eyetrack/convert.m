% convert raw data

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/eyetrack/convert.log' ); % start logging

	% proceed experiments
for i = 1:2
	logger.tab( 'experiment: %d', i );

		% prepare directories
	indir = '../data/eyetrack/raw/';

	outdir = sprintf( '../data/eyetrack/%d/cdf/convert/', i );
	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% proceed subjects
	ids = 1:31;

	for id = ids
		logger.tab( 'subject: %d', id );

			% read (raw) data
		basefile = fullfile( indir, sprintf( 'participant_%d', id ) );
		logfile = sprintf( '%s_%d.txt', basefile, i );
		audiofile = sprintf( '%s_%d.wav', basefile, i );
		if exist( logfile, 'file' ) ~= 2 || exist( audiofile, 'file' ) ~= 2 % skip partial data
			logger.untab( 'skipping' );
			continue;
		end

		run = cdf.hRun();

		read_audio( run, audiofile, true );
		read_trials( run, logfile );

			% write (cdf) data
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

