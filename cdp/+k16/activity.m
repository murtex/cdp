clearvars( '-except', '-regexp', '^fig\d*$' );
ws = warning();
warning( 'off', 'MATLAB:audiovideo:wavread:functionToBeRemoved' );

	% -----------------------------------------------------------------------
    % load wave file
	% -----------------------------------------------------------------------
[xi, fS, nS] = wavread( 'haiku.wav' );

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
wsize = 20; % window size in milliseconds
woverlap = 50; % window overlap in percent
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
fftsize = 4096;

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
	% voice detection
	% -----------------------------------------------------------------------
fmin = 0; % frequency band limit
fmax = 1000;

Pj(f < fmin | f > fmax, :) = [];
f(f < fmin | f > fmax) = [];

		% power weighted spectral flatness
pwsf = geomean( Pj, 1 ) ./ mean( Pj, 1 ); % spectral flatness
pwsf = sum( Pj, 1 ) .* pwsf; % power weightening

		% adaptive thresholding
smin = min( pwsf );
smax = max( pwsf );

pwsf1 = smin * (1 + 2*log10( smax/smin ));
pwsf2 = pwsf1 + 0.25*(mean( pwsf(pwsf > pwsf1) ) - pwsf1);

		% endpoint decision
va = false( nsegs, 1 ); % pre-allocation

state = 1;
statelen = 0;

for i = 1:nsegs
	switch state
		case 1 % no activity
			if pwsf(i) > pwsf1 % start potential activity
				state = 2;
				statelen = 0;
			end
		case 2 % potential activity
			if pwsf(i) >= pwsf2 % assure (past) activity
				va(i-statelen:i) = true;
				state = 3;
				statelen = 0;
			elseif pwsf(i) <= pwsf1 % deny activity
				state = 1;
				statelen = 0;
			end
		case 3 % assured activity
			if pwsf(i) <= pwsf1 % stop activity
				state = 1;
				statelen = 0;
			else % continue activity
				va(i) = true;
			end
	end

	statelen = statelen + 1;
end

	% -----------------------------------------------------------------------
	% speech detection
	% -----------------------------------------------------------------------
vfmin = 200; % voicing subband
vfmax = 500;

sbpw = sum( Pj(f >= vfmin & f <= vfmax, :), 1 );

	% adaptive thresholds, SEE: [1]
smin = min( sbpw );
smax = max( sbpw );

sbpw1 = smin * (1 + 2*log10( smax/smin ));
sbpw2 = sbpw1 + 0.25*(mean( sbpw(sbpw > sbpw1) ) - sbpw1);

	% validate voice activities
dva = diff( [false; va; false] );

starts = find( dva == 1 );
stops = find( dva == -1 ) - 1;

sa = va; % pre-allocation

for i = 1:numel( starts )
	if ~any( sbpw(starts(i):stops(i)) > sbpw2 )
		sa(starts(i):stops(i)) = false; % voicin-subband must be present for speech
	end
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

h1 = stairs( tj - mean( diff( tj ) ) / 2, sa, ... % plot activity
	'Color', 'red', 'LineWidth', 2, 'DisplayName', 'activity' );
h2 = plot( ti, xi, ... % plot linear waveform
	'Color', 'blue', 'LineWidth', 2, 'DisplayName', 'waveform' );

h = legend( [h1], 'Location', 'southeast' );
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

%h1 = stairs( tj - mean( diff( tj ) ) / 2, sa * max( f ), ... % plot activity
	%'Color', 'red', 'LineWidth', 2, 'DisplayName', 'activity'  );

h2 = plot( [0, L], vfmin * [1, 1], ... % subband
	'Color', 'blue', 'LineWidth', 2, 'DisplayName', 'subband' );
plot( [0, L], vfmax * [1, 1], ...
	'Color', 'blue', 'LineWidth', 2 );

h = legend( [h2], 'Location', 'northeast' );
set( h, 'Color', [0.9825, 0.9825, 0.9825] );

	% -----------------------------------------------------------------------
	% plot voice detection
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

set( fig3, 'Name', 'VOICE DETECTION' ); % set labels
title( get( fig3, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( {'power weighted spectral', 'flatness in decibel'} );

xlim( [0, L] ); % set axes

stairs( tj - mean( diff( tj ) ) / 2, 10 * log10( pwsf ), ... % plot power weighted spectral flatness
	'Color', 'blue', 'LineWidth', 2 );
plot( [0, L], 10 * log10( pwsf1 ) * [1, 1], ... % thresholds
	'Color', 'red', 'LineWidth', 2 );
plot( [0, L], 10 * log10( pwsf2 ) * [1, 1], ...
	'Color', 'red', 'LineWidth', 2 );

	% -----------------------------------------------------------------------
	% plot speech detection
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

set( fig4, 'Name', 'SPEECH DETECTION' ); % set labels
title( get( fig4, 'Name' ) );

xlabel( 'time in seconds' );
ylabel( {'subband power', 'in decibel'} );

xlim( [0, L] ); % set axes

stairs( tj - mean( diff( tj ) ) / 2, 10 * log10( sbpw ), ... % plot power weighted spectral flatness
	'Color', 'blue', 'LineWidth', 2 );
plot( [0, L], 10 * log10( sbpw1 ) * [1, 1], ... % thresholds
	'Color', 'red', 'LineWidth', 2 );
plot( [0, L], 10 * log10( sbpw2 ) * [1, 1], ...
	'Color', 'red', 'LineWidth', 2 );

warning( ws );

