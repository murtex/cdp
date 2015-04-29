% convert raw data

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( 'convert.log' ); % start logging

	% prepare directories
indir = 'raw/';

outdir = 'cdf/convert/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

	% proceed subjects
ids = 1:47;

for id = ids
	logger.tab( 'subject: %d', id );

		% read (raw) data
	basefile = fullfile( indir, sprintf( 'participant_%d', id ) );
	logfile = sprintf( '%s.txt', basefile );
	audiofile = sprintf( '%s_1.wav', basefile );
	labelfile = sprintf( '%s.xlsx', basefile );
	if exist( logfile, 'file' ) ~= 2 || exist( audiofile, 'file' ) ~= 2 || exist( labelfile, 'file' ) ~= 2 % skip partial data
		logger.untab( 'skipping' );
		continue;
	end

	run = cdf.hRun();

	read_audio( run, audiofile, true );
	read_trials( run, logfile );
	read_labels( run, labelfile );

		% write (cdf) data
	outfile = fullfile( outdir, sprintf( '%d.mat', run.id ) );
	logger.log( 'write cdf ''%s''...', outfile );
	save( outfile, 'run' );

		% clean-up
	delete( run );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

