% get speech-weighted noise (babbling) spectrum

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/klein/babbling.log' ); % start logging

	% prepare directories
indir = '../data/klein/cdf/sync/';

outdir = '../data/klein/cdf/babbling/';
if exist( outdir, 'dir' ) ~= 7
	mkdir( outdir );
end

plotdir = '../data/klein/plot/babbling/';
if exist( plotdir, 'dir' ) ~= 7
	mkdir( plotdir );
end

	% prepare average spectrum
ns = 0;
tmp_pows = [];

global_pows = [];
global_freqs = [];

	% configure framework
cfg = cdf.hConfig(); % use defaults

	% proceed subjects
ids = 6:47; % some syncs are malicious

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

		% get babbling spectrum
	[pows, freqs] = cdf.babbling( run, cfg, true, true );

		% plot spectra
	cdf.plot.babbling( pows, freqs, fullfile( plotdir, sprintf( '%d_babbling', run.id ) ) );

	ns = ns + 1;
	if ns == 1
		tmp_pows = pows;
		global_pows = tmp_pows;
		global_freqs = freqs;
	else
		tmp_pows = tmp_pows + pows;
		global_pows = tmp_pows / ns;
	end
	cdf.plot.babbling( global_pows, global_freqs, fullfile( plotdir, 'global_babbling' ) );

		% write data
	outfile = fullfile( outdir, sprintf( '%d.mat', run.id ) );
	logger.log( 'write cdf ''%s''...', outfile );
	save( outfile, 'pows', 'freqs' );

	outfile = fullfile( outdir, 'global.mat' );
	logger.log( 'write cdf ''%s''...', outfile );
	save( outfile, 'global_pows', 'global_freqs' );

		% clean-up
	delete( run );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

