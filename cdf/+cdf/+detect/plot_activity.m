function plot_activity( run, cfg, trial, stitle )
% plot activity detection
%
% PLOT_ACTIVITY( run, cfg, trial, stitle )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% trial : cue-distractor trial (scalar object)
% stitle : title string (row char)
%
% SEE
% [1] cdf.detect.activity
% [2] k15.vad

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( trial ) || ~isa( trial, 'cdf.hTrial' );
		error( 'invalid argument: trial' );
	end

	if nargin < 4 || ~isrow( stitle ) || ~ischar( stitle )
		error( 'invalid argument: stitle' );
	end

		% prepare data
	style = xis.hStyle.instance();

	tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges
	resplabr = dsp.sec2smp( trial.resplab.range, run.audiorate ) + [1, 0];

	tts = run.audiodata(tr(1):tr(2), 1); % signals

	yl = max( abs( tts ) ) * [-1, 1] * style.scale( 1/2 ); % axes

		% set activities
	valab = false( numel( tts ), 1 ); % manual
	valab((resplabr(1):resplabr(2)) - tr(1)) = true;

	[stft, times, freqs, stride, pwsf, t1, t2, vadet] = k15.vad( ... % detected
		tts, run.audiorate, cfg.vad_freqband, cfg.vad_window );

		% plot signal and activities
	subplot( 3, 1, 1 );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'magnitude' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( yl );

	h1 = stairs( ... % manual
		(dsp.smp2sec( (tr(1):tr(2)+1) - 1 - 1/2, run.audiorate ) - trial.range(1)) * 1000, ...
		[valab; valab(end)] * yl(2) / style.scale( 1/2 ), ...
		'Color', style.color( 'warm', +1 ), ...
		'DisplayName', 'manual' );

	h2 = stairs( ... % detected
		([times, times(end) + stride] - stride/2) * 1000, ...
		[vadet; vadet(end)] * yl(1) / style.scale( 1/2 ), ...
		'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'detected' );

	stairs( ... % signal
		(dsp.smp2sec( (tr(1):tr(2)+1) - 1 - 1/2, run.audiorate ) - trial.range(1)) * 1000, ...
		[tts; tts(end)], ...
		'Color', style.color( 'neutral', 0 ) );

	hl = legend( [h1, h2], 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

		% plot spectrogram
	subplot( 3, 1, 2 );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( cfg.vad_freqband(1:2) );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -2 ) ) );
	imagesc( times * 1000, freqs, stft .^ 0.15 ); % TODO: fixed gamma!

		% plot flatness and thresholds
	subplot( 3, 1, 3 );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'power weighted spectral flatness' );

	xlim( (trial.range - trial.range(1)) * 1000 );

	h1 = plot( xlim(), pow2db( [t1, t1] + eps ), ... % thresholds
		'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'lower threshold' );
	h2 = plot( xlim(), pow2db( [t2, t2] + eps ), ...
		'LineStyle', '--', 'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'upper threshold' );

	size( times )
	size( pwsf )

	stairs( ... % flatness
		([times, times(end) + stride] - stride/2) * 1000, ...
		pow2db( [pwsf, pwsf(end)] + eps ), ...
		'Color', style.color( 'neutral', 0 ) ); % flatness

	hl = legend( [h1, h2], 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );
end

