clearvars( '-except', '-regexp', '^fig\d*$' );
ws = warning();
warning( 'off', 'MATLAB:audiovideo:wavread:functionToBeRemoved' );

	% -----------------------------------------------------------------------
    % load wave file
	% -----------------------------------------------------------------------
[xi, fS, nS] = wavread( 'taf.wav' );

N = numel( xi ); % number of samples
L = (N - 1) / fS; % length in seconds
ti = linspace( 0, L, N ); % discrete time values

	% -----------------------------------------------------------------------
	% apply equal loudness filter
	% -----------------------------------------------------------------------

switch fS % yulewalk filter
	case 32000
		EL80=[0,120;20,113;30,103;40,97;50,93;60,91;70,89;80,87;90,86;100,85;200,78;300,76;400,76;500,76;600,76;700,77;800,78;900,79.5;1000,80;1500,79;2000,77;2500,74;3000,71.5;3700,70;4000,70.5;5000,74;6000,79;7000,84;8000,86;9000,86;10000,85;12000,95;15000,110;fS/2,115];
	case {44100, 48000}
		EL80=[0,120;20,113;30,103;40,97;50,93;60,91;70,89;80,87;90,86;100,85;200,78;300,76;400,76;500,76;600,76;700,77;800,78;900,79.5;1000,80;1500,79;2000,77;2500,74;3000,71.5;3700,70;4000,70.5;5000,74;6000,79;7000,84;8000,86;9000,86;10000,85;12000,95;15000,110;20000,125;fS/2,140];
	otherwise
		error( 'invalid sampling fS' );
end

f = EL80(:, 1) ./ (fS/2);
m = 10 .^ ((70 - EL80(:, 2)) / 20);

[By, Ay] = yulewalk( 10, f, m );
xif = filter( By, Ay, xi );

[Bb, Ab] = butter( 2, 150 / (fS/2), 'high' ); % butterworth filter
xif = filter( Bb, Ab, xif );

    % -----------------------------------------------------------------------
    % segment signal
    % -----------------------------------------------------------------------
wsize = 15; % window size in milliseconds
woverlap = 66; % window overlap in percent
wfunc = @hamming; % window function

wsizen = ceil( wsize/1000 * fS ); % windowing in number of samples
woverlapn = ceil( woverlap/100 * wsize/1000 * fS );
wstriden = wsizen - woverlapn;

nsegs = floor( N / wstriden ); % number of segments

Nz = (nsegs-1)*wstriden + wsizen; % zero-pad signal
xiz = cat( 1, xif, zeros( Nz - N, 1 ) );

xj = zeros( wsizen, nsegs ); % split segments
tj = zeros( 1, nsegs );
for i = 1:nsegs
    xj(:, i) = xiz((i-1)*wstriden+1:(i-1)*wstriden+wsizen); % split signal
    xj(:, i) = xj(:, i) .* wfunc( wsizen ); % apply window function
    tj(i) = round( (i-1)*wstriden + wsizen/2 ) / fS;
end

    % -----------------------------------------------------------------------
    % compute spectrogram
    % -----------------------------------------------------------------------
fftsize = 8192;

fNy = fS / 2; % prepare frequencies
f = (0:fftsize-1) / fftsize * fS;
f(f >= fNy) = f(f >= fNy) - fS;

Pj = []; % pre-allocation
for i = 1:nsegs

		% one-sided fourier coefficients
    X = fft( xj(:, i), fftsize ) / fftsize;
	X(f < 0) = [];

		% power conversion
    P = abs( X ) .^ 2;
    P = 2 * P(2:end); % rescaling w/o DC
	P(P < 100*eps) = NaN; % mask very low values

		% accumulate for spectrogram
    Pj = cat( 2, Pj, P );

end

f(f < 0) = []; % positive frequencies only
f = f(2:end); % remove DC

    % -----------------------------------------------------------------------
    % glottal activity detection
    % -----------------------------------------------------------------------
fmin = 200; % frequency band limit
fmax = 500;

Pj(f < fmin | f > fmax, :) = [];
f(f < fmin | f > fmax) = [];

gp = max( Pj, [], 1 ); % follow most prominent frequency

		% undo windowing
gpx = kron( gp, ones( 1, wstriden ) );
gpx(end+1:end+woverlapn) = repmat( gpx(end), woverlapn, 1 );
gpx = cat( 2, NaN( 1, round( (tj(1) - mean( diff( tj ) ) / 2) * fS ) ), gpx );

		% smoothing
avg = ones( 1, 2*woverlapn+1 ) / (2*woverlapn+1);
gpx = filter2( avg, gpx, 'full' );
gpx(1:numel( gpx )-woverlapn) = gpx(woverlapn+1:end);

gpx = gpx(1:N);
gpx = 10 * log10( gpx );

		% rate of rise
dt = 25; % milliseconds
ldt = floor( (dt/1000 * fS) / 2 );
rdt = ceil( (dt/1000 * fS) / 2 );

gpr = zeros( size( gpx ) );
for i = 1:N
	li = max( 1, i - ldt );
	ri = min( N, i + rdt );
	gpr(i) = gpx(ri) - gpx(li);
end

		% peaks
gthresh = 6; % peak threshold
schwalen = ceil( 20/1000 * fS ); % schwa
schwapow = -20;

gcp = peak( gpr, gthresh ); % candidates
gp = peakg( gcp, gpx, gpr, schwalen, schwapow ); % chosen

	% -----------------------------------------------------------------------
	% burst detection
	% -----------------------------------------------------------------------
pidelta = 1;
piwidth = 10;
pithreshs = [20, 10];

pidx = plosion( xif, ceil( pidelta/1000 * fS ), ceil( piwidth/1000 * fS ) );

boi = find( pidx >= max( pithreshs ), 1, 'first' ); % upper threshold first
if isempty( boi )
	boi = find( pidx >= min( pithreshs ), 1, 'first' ); % lower threshold next
end

	% -----------------------------------------------------------------------
	% plot waveform
	% -----------------------------------------------------------------------
if exist( 'fig1', 'var' ) ~= 1 || ~ishandle( fig1 ) % prepare figure window
	fig1 = figure( ...
		'Color', [0.9, 0.9, 0.9], 'InvertHardcopy', 'off', ...
		'PaperPosition', [0, 0, 8, 5], ...
		'defaultAxesFontName', 'DejaVu Sans Mono', 'defaultAxesFontSize', 16, 'defaultAxesFontWeight', 'bold', ...
		'defaultAxesNextPlot', 'add', ...
		'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on' );
end

figure( fig1 ); % set and clear current figure
clf( fig1 );

set( fig1, 'Name', sprintf( 'WAVEFORM (%dHz, %dbit)', fS, nS ) ); % set labels
title( get( fig1, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( 'amplitude' );

xlim( [0, L] ); % set axes
ylim( [-1, 1] * 1.1 );

if ~isempty( boi )
	stem( boi / fS, 1, ...
		'Color', 'red', 'LineWidth', 2, ...
		'MarkerSize', 4, 'MarkerFaceColor', 'red', 'ShowBaseLine', 'on' );
end

if numel( gp ) > 0 % glottal landmarks
	stem( gp(1) / fS, 1, ...
		'Color', 'red', 'LineWidth', 2, ...
		'MarkerSize', 4, 'MarkerFaceColor', 'red', 'ShowBaseLine', 'on' );
end
if numel( gp ) > 1
	stem( gp(2) / fS, -1, ...
		'Color', 'red', 'LineWidth', 2, ...
		'MarkerSize', 4, 'MarkerFaceColor', 'red', 'ShowBaseLine', 'on' );
end

plot( ti, xi, ... % plot linear waveform
	'Color', 'blue', 'LineWidth', 2, 'DisplayName', 'waveform' );

h = legend( {'landmarks'}, 'Location', 'northeast' ); % legend
set( h, 'Color', [0.9825, 0.9825, 0.9825] );

	% -----------------------------------------------------------------------
	% plot spectrogram
	% -----------------------------------------------------------------------
if exist( 'fig2', 'var' ) ~= 1 || ~ishandle( fig2 ) % prepare figure window
	fig2 = figure( ...
		'Color', [0.9, 0.9, 0.9], 'InvertHardcopy', 'off', ...
		'PaperPosition', [0, 0, 8, 5], ...
		'defaultAxesFontName', 'DejaVu Sans Mono', 'defaultAxesFontSize', 16, 'defaultAxesFontWeight', 'bold', ...
		'defaultAxesNextPlot', 'add', ...
		'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on' );
end

figure( fig2 ); % set and clear current figure
clf( fig2 );

set( fig2, 'Name', sprintf( 'SPECTROGRAM (%dms, %d%%)', wsize, woverlap ) ); % set labels
title( get( fig2, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( 'frequency in hertz' );

xlim( [0, L] ); % set axes
ylim( [fmin, fmax] );

colormap( flipud( colormap( 'gray' ) ) ); % plot spectral powers
imagesc( tj, f, Pj .^ 0.1 );

	% -----------------------------------------------------------------------
	% plot glottal activity detection
	% -----------------------------------------------------------------------
if exist( 'fig3', 'var' ) ~= 1 || ~ishandle( fig3 ) % prepare figure window
	fig3 = figure( ...
		'Color', [0.9, 0.9, 0.9], 'InvertHardcopy', 'off', ...
		'PaperPosition', [0, 0, 8, 5], ...
		'defaultAxesFontName', 'DejaVu Sans Mono', 'defaultAxesFontSize', 16, 'defaultAxesFontWeight', 'bold', ...
		'defaultAxesNextPlot', 'add', ...
		'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on' );
end

figure( fig3 ); % set and clear current figure
clf( fig3 );

set( fig3, 'Name', 'GLOTTAL ACTIVITY DETECTION' ); % set labels
title( get( fig3, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( {'glottal power ROR', sprintf( '(%dms) in decibel', dt )} );

xlim( [0, L] ); % set axes

h0 = plot( [0, L], gthresh * [1, 1], ... % thresholds
	'Color', 'red', 'LineWidth', 2, 'LineStyle', '--', ...
	'DisplayName', 'thresholds' );
plot( [0, L], -gthresh * [1, 1], ...
	'Color', 'red', 'LineWidth', 2, 'LineStyle', '--' );

for i = 1:numel( gcp ) % candidate peaks
	h1 = stem( gcp / fS, gpr(gcp), ...
		'Color', 'red', 'LineWidth', 2, 'LineStyle', '--', ...
		'MarkerSize', 4, 'MarkerFaceColor', 'red', 'ShowBaseLine', 'on', ...
		'DisplayName', 'candidate peaks' );
end
for i = 1:numel( gp ) % chosen peaks
	h2 = stem( gp / fS, gpr(gp), ...
		'Color', 'red', 'LineWidth', 2, ...
		'MarkerSize', 4, 'MarkerFaceColor', 'red', 'ShowBaseLine', 'on', ...
		'DisplayName', 'chosen peaks' );
end

plot( ti, gpr, ... % rate of rise
	'Color', 'blue', 'LineWidth', 2 );

h = legend( [h0, h1(1), h2(1)], 'Location', 'northeast' ); % legend
set( h, 'Color', [0.9825, 0.9825, 0.9825] );

	% -----------------------------------------------------------------------
	% plot plosion detection
	% -----------------------------------------------------------------------
if exist( 'fig4', 'var' ) ~= 1 || ~ishandle( fig4 ) % prepare figure window
	fig4 = figure( ...
		'Color', [0.9, 0.9, 0.9], 'InvertHardcopy', 'off', ...
		'PaperPosition', [0, 0, 8, 5], ...
		'defaultAxesFontName', 'DejaVu Sans Mono', 'defaultAxesFontSize', 16, 'defaultAxesFontWeight', 'bold', ...
		'defaultAxesNextPlot', 'add', ...
		'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on' );
end

figure( fig4 ); % set and clear current figure
clf( fig4 );

set( fig4, 'Name', 'RELEASE BURST DETECTION' ); % set labels
title( get( fig4, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( 'logarithmic plosion index' );

xlim( [0, L] ); % set axes

for i = 1:numel( pithreshs ) % thresholds
	plot( [0, L], log( pithreshs(i) ) * [1, 1], ...
		'Color', 'red', 'LineWidth', 2, 'LineStyle', '--' );
end

plot( ti(pidx > eps), log( pidx(pidx > eps) ), ... % plot plosion index
	'Color', 'blue', 'LineWidth', 2 );

warning( ws );

