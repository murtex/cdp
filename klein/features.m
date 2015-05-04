% extract features

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/features.log' ); % start logging

	% prepare directories
indir = '../data/klein/cdf/landmark/';

outdir = '../data/klein/cdf/features/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% proceed subjects
ids = 17;

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
	
		% extract features
	subjectdir = fullfile( outdir, sprintf( '%d', run.id ) );
	if exist( subjectdir, 'dir' ) == 7
		rmdir( subjectdir, 's' );
	end
	mkdir( subjectdir );
	cdf.features( run, cfg, false, false, subjectdir );

	%subjectdir = fullfile( outdir, sprintf( '%d_labeled', run.id ) );
	%if exist( subjectdir, 'dir' ) == 7
		%rmdir( subjectdir, 's' );
	%end
	%mkdir( subjectdir );
	%cdf.features( run, cfg, true, false, subjectdir );

		% write data
	run.audiodata = []; % do not write audio data

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

