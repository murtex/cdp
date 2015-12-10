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
	tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges

	tts = run.audiodata(tr(1):tr(2), 1); % signals

		% activities
	[stft, times, freqs, pwsf, t1, t2, vadet] = k15.vad( ... % detected
		tts, run.audiorate, cfg.vad_freqband, cfg.vad_window );

		% plot signal and activity
	style = xis.hStyle.instance();

	subplot( 3, 1, 1 );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'magnitude' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( max( abs( tts ) ) * [-1, 1] * style.scale( 1/2 ) );

	plot( (trial.resplab.range(1) * [1, 1] - trial.range(1)) * 1000, ylim(), ... % manual, TODO
		'Color', style.color( 'warm', +1 ) );
	plot( (trial.resplab.range(2) * [1, 1] - trial.range(1)) * 1000, ylim(), ...
		'Color', style.color( 'warm', +1 ) );

	h2 = stairs( times * 1000, vadet * max( abs( tts ) ) * -1, ... % detected
		'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'detected' );

	stairs( ... % signal
		(dsp.smp2sec( (tr(1):tr(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, [tts; tts(end)], ...
		'Color', style.color( 'cold', -1 ) );

	hl = legend( [h2], 'Location', 'southeast' );
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

		% plot spectrogram
	subplot( 3, 1, 2 );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( cfg.vad_freqband(1:2) );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
	imagesc( times * 1000, freqs, stft .^ 0.15 ); % TODO: fixed gamma!

		% plot flatness and thresholds
	subplot( 3, 1, 3 );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'power weighted spectral flatness' );

	xlim( (trial.range - trial.range(1)) * 1000 );

	h1 = plot( xlim(), pow2db( [t1, t1] + eps ), ... % thresholds
		'Color', style.color( 'warm', +1 ), ...
		'DisplayName', 'lower threshold' );
	h2 = plot( xlim(), pow2db( [t2, t2] + eps ), ...
		'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'upper threshold' );

	stairs( times * 1000, pow2db( pwsf + eps ), 'Color', style.color( 'cold', -1 ) ); % flatness

	hl = legend( [h1, h2], 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );
end

