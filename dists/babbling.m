% babbling test

	% init
clear( 'all' );

addpath( '../' ); % set path to cue-distractor package

logger = xis.hLogger.instance( '../data/dists/babbling.log' ); % start logging

	% load babbling spectrum
filename = '../data/klein/cdf/babbling/global.mat';
logger.log( 'read babbling spectrum ''%s''...', filename );
load( filename, 'global_pows', 'global_freqs' );

	% prepare for at least 1s noise
rate = 2*global_freqs(end);
lsrc = 2*(numel( global_pows )-1);
ldst = 2^nextpow2( rate );

	% re-build two-sided, linear spectrum
ft = sqrt( global_pows * lsrc*lsrc ); % magnitudes

ft = cat( 2, ft(1), kron( ft(2:end), ones( 1, ceil( ldst/lsrc ) ) ) ); % expanding
ft = filter2( fspecial( 'average', [1, ceil( ldst/lsrc )] ), ft ); % smoothing

phi = cat( 2, 0, 2*pi * rand( 1, numel( ft )-2 ), 0 ); % random phases
ft = exp( i*phi ) .* ft;

ft = cat( 2, ft, conj( fliplr( ft(2:end-1) ) ) ); % two-sided
ft(1) = 0; % zero mean

	% generate noise
noi = ifft( ft );
noi = noi / (1.05 * max( abs( noi ) )); % ~95% normalization

	% store noise wave file 
filename = '../data/dists/babbling.wav';
logger.log( 'write babbling ''%s''...', filename );
wavwrite( noi, rate, filename );

	% mix distractors
distfiles = {'../data/dists/ka.wav', '../data/dists/ta.wav' };
snrs = [-21, -18, -15, -12, -9, -6, -3, 0, 3, 6, 9, 12, 15, 18, 21]; % integers!

noi = cat( 2, noi, noi )'; % loop noise once

for distfile = distfiles
	logger.tab( 'mix distractor ''%s''...', distfile{:} );

		% load distractor wave file
	[path, name, ext] = fileparts( distfile{:} );

	[dist, distrate] = wavread( distfile{:}, 'double' );
	if size( dist, 2 ) ~= 1 || distrate ~= rate
		error( 'invalid distractor' );
	end

	dist = dist - mean( dist ); % remove dc
	dist = dist / (1.05 * max( abs( dist ) )); % ~95% normalization

		% proceed target snrs
	silence = zeros( ceil( rate/2 ), 1 );
	noidistser = cat( 1, silence, dist, silence );

	snrs = sort( snrs, 'descend' );
	for snr = snrs

			% choose noise part randomly
		distlen = numel( dist );
		noilen = numel( noi );
		noistart = randi( noilen-distlen+1, 1, 1 );
		noistop = noistart+distlen-1;

			% scale noise power to match snr
		distpow = sum( dist .* dist ) / distlen;
		noipow = sum( noi(noistart:noistop) .* noi(noistart:noistop) ) / distlen;
		noiscale = sqrt( distpow / (10^(snr/10)) / noipow );

			% mix noise and fade ends
		noidist = dist + noiscale*noi(noistart:noistop);
		noidist = noidist / (1.05 * max( abs( noidist ) )); % ~95% normalization

		fade = linspace( 0, 1, ceil( rate/1000 ) )'; % 1ms
		noidist(1:numel( fade )) = noidist(1:numel( fade )) .* fade;
		noidist(end-numel( fade )+1:end) = noidist(end-numel( fade )+1:end ) .* flipud( fade );

			% write noisy wave file
		if snr >= 0
			filename = fullfile( path, sprintf( '%s_p%02ddb%s', name, snr, ext ) );
		else
			filename = fullfile( path, sprintf( '%s_m%02ddb%s', name, -snr, ext ) );
		end
		logger.log( 'write distractor ''%s''...', filename );
		wavwrite( noidist, rate, filename );

			% append to series
		noidistser = cat( 1, noidistser, silence, noidist, silence );

	end

		% write series wave file
	noidistser = noidistser / (1.05 * max( abs( noidistser ) )); % ~95% normalization

	filename = fullfile( path, sprintf( '%s_series%s', name, ext ) );
	logger.log( 'write series ''%s''...', filename );
	wavwrite( noidistser, rate, filename );

	logger.untab();
end

	% exit
logger.log( 'done.' ); % stop logging
delete( logger );

