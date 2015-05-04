% debug landmark detection data

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/landmark_debug.log' ); % start logging

	% prepare directories
indir = '../data/klein/cdf/landmark/';

plotdir = '../data/klein/plot/landmark_debug/';
if exist( plotdir, 'dir' ) ~= 7
	mkdir( plotdir );
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

		% plot random trials
	subjectdir = fullfile( plotdir, sprintf( '%d/', run.id ) ); % prepare subject plot directory
	if exist( subjectdir, 'dir' ) == 7
		rmdir( subjectdir, 's' );
	end
	mkdir( subjectdir );

	trials = [run.trials.detected]; % choose 10 valid trials
	rs = cat( 1, trials.range );
	trials = run.trials(~isnan( rs(:, 1) ));
	trials = randsample( trials, min( numel( trials ), 10 ) );

	n = numel( trials ); % plot
	for i = 1:n
		cdf.plot.trial_range( run, cfg, trials(i), [...
			min( trials(i).detected.range(1), trials(i).labeled.range(1) ), ...
			max( trials(i).detected.range(2), trials(i).labeled.range(2) )], ...
			trials(i).detected.range(1), ...
			fullfile( subjectdir, sprintf( '%d', trials(i).id ) ) );
		cdf.plot.trial_glottis( run, cfg, trials(i), ...
			fullfile( subjectdir, sprintf( '%d_glottis', trials(i).id ) ) );
		cdf.plot.trial_burst( run, cfg, trials(i), ...
			fullfile( subjectdir, sprintf( '%d_burst', trials(i).id ) ) );
	end

		% clean-up
	delete( run );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

