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
	salab = false( numel( tts ), 1 ); % manual

	if ~any( isnan( resplabr ) )
		salab((resplabr(1):resplabr(2)) - tr(1)) = true;
	end

	[stft, times, freqs, stride, pwsf, vathresh1, vathresh2, vadet] = k15.vad( ... % detected
		tts, run.audiorate, cfg.vad_freqband, cfg.vad_window );

	[sbpw, sathresh1, sathresh2, sadet] = k15.sad( vadet, stft, times, freqs, cfg.sad_subband );

		% plot signal amd activites
	subplot( 4, 1, 1 );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'magnitude' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( yl );

	h1 = stairs( ... % manual
		(dsp.smp2sec( (tr(1):tr(2)+1) - 1 - 1/2, run.audiorate ) - trial.range(1)) * 1000, ...
		[salab; salab(end)] * yl(2) / style.scale( 1/2 ), ...
		'Color', style.color( 'warm', +1 ), ...
		'DisplayName', 'manual' );

	h2 = stairs( ... % detected voice
		([times, times(end) + stride] - stride/2) * 1000, ...
		[vadet; vadet(end)] * yl(1) / style.scale( 3/2 ), ...
		'Color', style.color( 'cold', +2 ), ...
		'DisplayName', 'detected voice' );

	h3 = stairs( ... % detected speech
		([times, times(end) + stride] - stride/2) * 1000, ...
		[sadet; sadet(end)] * yl(1) / style.scale( 1/2 ), ...
		'Color', style.color( 'signal', +1 ), ...
		'DisplayName', 'detected speech' );

	stairs( ... % signal
		(dsp.smp2sec( (tr(1):tr(2)+1) - 1 - 1/2, run.audiorate ) - trial.range(1)) * 1000, ...
		[tts; tts(end)], ...
		'Color', style.color( 'neutral', 0 ) );

	hl = legend( [h1, h2, h3], 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

		% plot spectrogram and subband
	subplot( 4, 1, 2 );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( cfg.vad_freqband(1:2) );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -2 ) ) ); % spectrogram
	imagesc( times * 1000, freqs, stft .^ 0.15 ); % TODO: fixed gamma!

	h1 = plot( xlim(), cfg.sad_subband(1) * [1, 1], ... % subband
		'Color', style.color( 'cold', +2 ), ...
		'DisplayName', 'speech subband' );
	plot( xlim(), cfg.sad_subband(2) * [1, 1], ...
		'Color', style.color( 'cold', +2 ) );

	hl = legend( h1, 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

		% plot voice flatness and thresholds
	subplot( 4, 1, 3 );

	xlabel( 'trial time in milliseconds' );
	ylabel( {'power weighted spectral flatness', '(voice detection)'} );

	xlim( (trial.range - trial.range(1)) * 1000 );

	h1 = plot( xlim(), pow2db( [vathresh1, vathresh1] + eps ), ... % thresholds
		'Color', style.color( 'cold', +2 ), ...
		'DisplayName', 'thresholds' );
	plot( xlim(), pow2db( [vathresh2, vathresh2] + eps ), ...
		'Color', style.color( 'cold', +2 ) );

	stairs( ... % flatness
		([times, times(end) + stride] - stride/2) * 1000, ...
		pow2db( [pwsf, pwsf(end)] + eps ), ...
		'Color', style.color( 'neutral', 0 ) );

	hl = legend( h1, 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

		% plot speech power and thresholds
	subplot( 4, 1, 4 );

	xlabel( 'time in milliseconds' );
	ylabel( {'subband power', '(speech detection)'} );

	xlim( (trial.range - trial.range(1)) * 1000 );

	h1 = plot( xlim(), pow2db( [sathresh1, sathresh1] + eps ), ... % thresholds
		'Color', style.color( 'cold', +2 ), ...
		'DisplayName', 'thresholds' );
	plot( xlim(), pow2db( [sathresh2, sathresh2] + eps ), ...
		'Color', style.color( 'cold', +2 ) );

	stairs( ... % power
		([times, times(end) + stride] - stride/2) * 1000, ...
		pow2db( [sbpw, sbpw(end)] + eps ), ...
		'Color', style.color( 'neutral', 0 ) );

	hl = legend( h1, 'Location', 'northeast' ); % legend
	set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );

end

