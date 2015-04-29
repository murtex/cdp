% debug extraction data

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( 'extract_debug.log' ); % start logging

	% prepare directories
indir = 'cdf/extract/';

plotdir = 'plot/extract_debug/';
if exist( plotdir, 'dir' ) ~= 7
	mkdir( plotdir );
end

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% proceed subjects
ids = [27, 32]

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

		% plot some trials
	subjectdir = fullfile( plotdir, sprintf( '%d/', run.id ) ); % prepare subject plot directory
	if exist( subjectdir, 'dir' ) == 7
		rmdir( subjectdir, 's' );
	end
	mkdir( subjectdir );

	rs = cat( 1, run.trials.range ); % choose 10 valid trials
	trials = run.trials(~isnan( rs(:, 1) ));
	trials = randsample( trials, min( numel( trials ), 20 ) );

	n = numel( trials ); % plot
	for i = 1:n
		cdf.plot.trial_range( run, cfg, trials(i), ...
			trials(i).range, trials(i).range(1), ...
			fullfile( subjectdir, sprintf( '%d', trials(i).id ) ) );
		cdf.plot.trial_extract( run, cfg, trials(i), ...
			fullfile( subjectdir, sprintf( '%d_extract', trials(i).id ) ) );
	end

		% clean-up
	delete( run );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

