function plot_formants( run, cfg, trial, flags, stitle, callback )
% plot landmarks
%
% PLOT_FORMANTS( run, cfg, trial, flags, stitle, callback )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% trial : cue-distractor trial (scalar object)
% flags : flags [redo, det, log, blend] (vector logical)
% stitle : title string (row char)
% callback : button down event dispatcher [function, argument] (vector cell)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( trial ) || ~isa( trial, 'cdf.hTrial' )
		error( 'invalid argument: trial' );
	end

	if nargin < 4 || ~isvector( flags ) || numel( flags ) ~= 4 || ~islogical( flags )
		error( 'invalid argument: flags' );
	end

	if nargin < 5 || ~isrow( stitle ) || ~ischar( stitle )
		error( 'invalid argument: stitle' );
	end

	if nargin < 6 || ~isvector( callback ) || numel( callback ) ~= 2 || ~iscell( callback )
		error( 'invalid argument: callback' );
	end

		% return with detection view, TODO!
	if flags(2)
		return;
	end

		% helpers
	style = xis.hStyle.instance();

	function stft = scale( stft ) % log scale
		if flags(3)
			stft = pow2db( abs( stft ) + eps );
		end
	end

	function [stft, times] = blend( stft, ts, window ) % blending, TODO!
		wlen = dsp.sec2smp( window{2}, run.audiorate );
		wovl = dsp.sec2smp( window{2} * window{3}, run.audiorate );
		wstr = wlen - wovl;

		stftp = stft;
		stft = zeros( size( stft, 1 ), numel( ts ) );
		hits = zeros( numel( ts ), 1 );

		nsegs = size( stftp, 2 );
		for i = 1:nsegs
			segstart = max( 1, (i-1)*wstr + 1 );
			segstop = min( numel( ts ), (i-1)*wstr + wlen );

			stft(:, segstart:segstop) = stft(:, segstart:segstop) + repmat( stftp(:, i), 1, segstop-segstart+1 );
			hits(segstart:segstop) = hits(segstart:segstop) + 1;
			%hits(segstart:segstop) = hits(segstart:segstop) + triang( segstop-segstart+1 );
		end

		for i = 1:numel( ts )
			stft(:, i) = stft(:, i) / hits(i);
		end

		times = dsp.smp2sec( 0:numel( ts )-1, run.audiorate );
	end

	function plot_marks( flegend ) % formant onsets
		h1 = scatter( (resplab.f0(1) - trial.range(1)) * 1000, resplab.f0(2), ... % manual
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'warm', +2 ), 'MarkerEdgeColor', style.color( 'warm', -2 ), ...
			'DisplayName', 'manual' );
		scatter( (resplab.f1(1) - trial.range(1)) * 1000, resplab.f1(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'warm', +2 ), 'MarkerEdgeColor', style.color( 'warm', -2 ) );
		scatter( (resplab.f2(1) - trial.range(1)) * 1000, resplab.f2(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'warm', +2 ), 'MarkerEdgeColor', style.color( 'warm', -2 ) );
		scatter( (resplab.f3(1) - trial.range(1)) * 1000, resplab.f3(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'warm', +2 ), 'MarkerEdgeColor', style.color( 'warm', -2 ) );

		h2 = scatter( (respdet.f0(1) - trial.range(1)) * 1000, respdet.f0(2), ... % detected
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'signal', +2 ), 'MarkerEdgeColor', style.color( 'signal', -2 ), ...
			'DisplayName', 'detected' );
		scatter( (respdet.f1(1) - trial.range(1)) * 1000, respdet.f1(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'signal', +2 ), 'MarkerEdgeColor', style.color( 'signal', -2 ) );
		scatter( (respdet.f2(1) - trial.range(1)) * 1000, respdet.f2(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'signal', +2 ), 'MarkerEdgeColor', style.color( 'signal', -2 ) );
		scatter( (respdet.f3(1) - trial.range(1)) * 1000, respdet.f3(2), ...
			'ButtonDownFcn', callback, ...
			'MarkerFaceColor', style.color( 'signal', +2 ), 'MarkerEdgeColor', style.color( 'signal', -2 ) );

		if flegend % legend
			hl = legend( [h1, h2], 'Location', 'southeast' );
			set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );
		end
	end

	function plot_signal( times, freqs, stft, gamma ) % spectrogram
		colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -2 ) ) );
		imagesc( times, freqs, scale( stft .^ gamma ), ...
			'ButtonDownFcn', callback );
	end

		% prepare data
	resplab = trial.resplab;
	respdet = trial.respdet;

	ovrr = dsp.sec2smp( [ ... % ranges
		min( resplab.range(1), respdet.range(1) ), ...
		max( resplab.range(2), respdet.range(2) )], run.audiorate ) + [1, 0];

	ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

	persistent stft1 times1 freqs1; % transforms
	persistent stft2 times2 freqs2;

	if flags(1) % fredo
		[stft1, times1, freqs1] = dsp.stftransf( ovrts, run.audiorate, ... % f1..f3
			cfg.formants_fx_freqband, cfg.formants_fx_window );
		stft1 = stft1 .* conj( stft1 );
		times1 = (min( resplab.range(1), respdet.range(1) ) + times1 - trial.range(1)) * 1000;

		[stft2, times2, freqs2] = dsp.stftransf( ovrts, run.audiorate, ... % f0
			cfg.formants_f0_freqband, cfg.formants_f0_window );
		stft2 = stft2 .* conj( stft2 );
		times2 = (min( resplab.range(1), respdet.range(1) ) + times2 - trial.range(1)) * 1000;

		if flags(4) % blending
			[stft1, times1] = blend( stft1, ovrts, cfg.formants_fx_window );
			[stft2, times2] = blend( stft2, ovrts, cfg.formants_f0_window );
		end
	end

		% plot spectrogram #1 (f1..f3)
	subplot( 4, 1, [1, 2], 'ButtonDownFcn', callback );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( ([...
		min( resplab.range(1), respdet.range(1) ), ...
		max( resplab.range(2), respdet.range(2) )] - trial.range(1)) * 1000 );
	ylim( cfg.formants_fx_freqband(1:2) );

	plot_signal( times1, freqs1, stft1, cfg.formants_fx_gamma );
	plot_marks( true );

		% plot spectrogram #2 (f0)
	subplot( 4, 1, 3, 'ButtonDownFcn', callback );

	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );

	xlim( ([...
		min( resplab.range(1), respdet.range(1) ), ...
		max( resplab.range(2), respdet.range(2) )] - trial.range(1)) * 1000 );
	ylim( cfg.formants_f0_freqband(1:2) );

	plot_signal( times2, freqs2, stft2, cfg.formants_f0_gamma );
	plot_marks( false );

end

