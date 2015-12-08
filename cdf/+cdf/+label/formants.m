function label_formants( run, cfg )
% formants labeling tool
%
% LABEL_FORMANTS( run, cfg )
% 
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' ) % cue-distractor run
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' ) % framework configuration
		error( 'invalid argument: cfg' );
	end

		% init
	logger = xis.hLogger.instance(); % start logging
	logger.tab( 'formants labeling tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );
	figcol = get( fig, 'Color' );

	set( fig, 'WindowKeyPressFcn', {@fig_dispatch, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@fig_dispatch, 'close'} );

		% helper functions
	function f = is_valid( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if isempty( trials(i).resplab.label ) || any( isnan( trials(i).resplab.range ) )
				f(i) = false;
			end
		end
	end

	function f = is_labeled( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if any( isnan( trials(i).resplab.f0 ) ) || any( isnan( trials(i).resplab.f1 ) ) || ...
					any( isnan( trials(i).resplab.f2 ) ) || any ( isnan( trials(i).resplab.f3 ) )
				f(i) = false;
			end
		end
	end

	function i = next_unlabeled( trials, i )
		inext = find( ~is_labeled( trials(i+1:end) ), 1 );
		if ~isempty( inext )
			i = i + inext;
		end
	end

	function [stft, times] = blend( stft, ts, rate, window )
		wlen = dsp.sec2smp( window{2}, rate );
		wovl = dsp.sec2smp( window{2} * window{3}, rate );
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

		times = dsp.smp2sec( 0:numel( ts )-1, rate );
	end

	function stft = scale( stft, flog )
		if flog
			stft = pow2db( stft + eps );
		end
	end

	function plot_formants( trial )
		scatter( (trial.resplab.f0(1) - trial.range(1)) * 1000, trial.resplab.f0(2), ...
			'LineWidth', 2, 'MarkerEdgeColor', style.color( 'signal', +2 ), 'MarkerFaceColor', 'none', ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
		scatter( (trial.resplab.f1(1) - trial.range(1)) * 1000, trial.resplab.f1(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
		scatter( (trial.resplab.f2(1) - trial.range(1)) * 1000, trial.resplab.f2(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
		scatter( (trial.resplab.f3(1) - trial.range(1)) * 1000, trial.resplab.f3(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
	end

		% event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'space' % browsing
						if nmods == 0
							itrial = next_unlabeled( trials, itrial );
							fig_update( true );
						end

					case 'pagedown'
						if nmods < 2 && itrial ~= ntrials
							step = 1;
							if strcmp( event.Modifier, 'shift' )
								step = 10;
							elseif strcmp( event.Modifier, 'control' )
								step = 100;
							end
							itrial = min( itrial + step, ntrials );
							fig_update( true );
						end
					case 'pageup'
						if nmods < 2 && itrial ~= 1
							step = 1;
							if strcmp( event.Modifier, 'shift' )
								step = 10;
							elseif strcmp( event.Modifier, 'control' )
								step = 100;
							end
							itrial = max( itrial - step, 1 );
							fig_update( true );
						end

					case 'home'
						if nmods == 0 && itrial ~= 1
							itrial = 1;
							fig_update( true );
						end
					case 'end'
						if nmods == 0 && itrial ~= ntrials
							itrial = ntrials;
							fig_update( true );
						end

					case 'f' % formants setting
						if nmods == 0
							[x, y] = ginput( 3 );
							if numel( y ) > 0 && y(1) >= cfg.lab_formants_fx_freqband(1) && y(1) <= cfg.lab_formants_fx_freqband(2)
								resplab.f1(1) = trial.range(1) + x(1) / 1000;
								resplab.f1(2) = y(1);
							end
							if numel( y ) > 1 && y(2) >= cfg.lab_formants_fx_freqband(1) && y(2) <= cfg.lab_formants_fx_freqband(2)
								resplab.f2(1) = trial.range(1) + x(2) / 1000;
								resplab.f2(2) = y(2);
							end
							if numel( y ) > 2 && y(3) >= cfg.lab_formants_fx_freqband(1) && y(3) <= cfg.lab_formants_fx_freqband(2)
								resplab.f3(1) = trial.range(1) + x(3) / 1000;
								resplab.f3(2) = y(3);
							end
							fig_update( false );
						end
					case '1'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.lab_formants_fx_freqband(1) && y(1) <= cfg.lab_formants_fx_freqband(2)
								resplab.f1(1) = trial.range(1) + x(1) / 1000;
								resplab.f1(2) = y(1);
							end
							fig_update( false );
						end
					case '2'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.lab_formants_fx_freqband(1) && y(1) <= cfg.lab_formants_fx_freqband(2)
								resplab.f2(1) = trial.range(1) + x(1) / 1000;
								resplab.f2(2) = y(1);
							end
							fig_update( false );
						end
					case '3'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.lab_formants_fx_freqband(1) && y(1) <= cfg.lab_formants_fx_freqband(2)
								resplab.f3(1) = trial.range(1) + x(1) / 1000;
								resplab.f3(2) = y(1);
							end
							fig_update( false );
						end

					case 'b' % blending
						if nmods == 0
							fblend = ~fblend;
							fig_update( true );
						end

					case 'd' % decibel scale
						if nmods == 0
							flog = ~flog;
							fig_update( false );
						end

					case 'return' % playback
						if nmods == 0
							soundsc( ovrts, run.audiorate );
						end

					case 'backspace' % clearing
						if nmods == 1 && strcmp( event.Modifier, 'control' ) % clear trial
							resplab.f0 = [NaN, NaN];
							resplab.f1 = [NaN, NaN];
							resplab.f2 = [NaN, NaN];
							resplab.f3 = [NaN, NaN];
							fig_update( false );
						elseif nmods == 3 && any( strcmp( event.Modifier, 'shift' ) ) ... % clear run (valids only)
								&& any( strcmp( event.Modifier, 'control' ) )  && any( strcmp( event.Modifier, 'alt' ) )
							for i = 1:ntrials
								trials(i).resplab.f0 = [NaN, NaN];
								trials(i).resplab.f1 = [NaN, NaN];
								trials(i).resplab.f2 = [NaN, NaN];
								trials(i).resplab.f3 = [NaN, NaN];
							end
							itrial = 1;
							fig_update( true );
						end

					case 'escape' % quit
						if nmods == 0
							fdone = true;
							fig_update( false );
						end
				end

				% button presses
			case 'buttondown'
				while ~strcmp( get( src, 'Type' ), 'axes' ) % get parent axis
					src = get( src, 'Parent' );
				end

				switch get( fig, 'SelectionType' )
					case 'normal' % f0 setting
						cp = get( src, 'CurrentPoint' );
						if cp(3) >= cfg.lab_formants_f0_freqband(1) && cp(3) <= cfg.lab_formants_f0_freqband(2)
							resplab.f0(1) = trial.range(1) + cp(1) / 1000;
							resplab.f0(2) = cp(3);
							fig_update( false );
						end
				end

				% figure closing
			case 'close'
				fdone = true;
				delete( fig );
		end
	end

	function fig_update( recomp )
		frecomp = recomp; % set recomputation flag

		switch get( fig, 'Clipping' ) % flip (unused) clipping property
			case 'on'
				set( fig, 'Clipping', 'off' );
			case 'off'
				set( fig, 'Clipping', 'on' );
		end
	end

		% interaction loop
	trials = [run.trials]; % prepare valid trials
	itrials = 1:numel( trials );

	invalids = ~is_valid( trials );
	trials(invalids) = [];
	itrials(invalids) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );
	logger.log( 'unlabeled trials: %d', sum( ~is_labeled( trials ) ) );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	itrial = max( 1, next_unlabeled( trials, 0 ) );

	fdone = false; % init flags
	frecomp = true;
	fblend = false;
	flog = false;

	while ~fdone

			% prepare data
		trial = trials(itrial);
		resplab = trial.resplab;

		ovrr = dsp.sec2smp( resplab.range, run.audiorate ) + [1, 0]; % ranges

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals
		dc = mean( ovrts );
		ovrts = ovrts - dc;

		if frecomp % transforms

			[ovr_stft1, ovr_stft1_times, ovr_stft1_freqs] = dsp.stftransf( ovrts, run.audiorate, ... % f1..f3
				cfg.lab_formants_fx_freqband, cfg.lab_formants_fx_window );
			ovr_stft1 = ovr_stft1 .* conj( ovr_stft1 );
			ovr_stft1_times = (resplab.range(1) + ovr_stft1_times - trial.range(1)) * 1000;

			[ovr_stft2, ovr_stft2_times, ovr_stft2_freqs] = dsp.stftransf( ovrts, run.audiorate, ... % f0
				cfg.lab_formants_f0_freqband, cfg.lab_formants_f0_window );
			ovr_stft2 = ovr_stft2 .* conj( ovr_stft2 );
			ovr_stft2_times = (resplab.range(1) + ovr_stft2_times - trial.range(1)) * 1000;

			if fblend
				[ovr_stft1, ovr_stft1_times] = blend( ovr_stft1, ovrts, run.audiorate, cfg.lab_formants_fx_window ); % f1..f3
				ovr_stft1_times = (resplab.range(1) + ovr_stft1_times - trial.range(1)) * 1000;
				[ovr_stft2, ovr_stft2_times] = blend( ovr_stft2, ovrts, run.audiorate, cfg.lab_formants_f0_window ); % f0
				ovr_stft2_times = (resplab.range(1) + ovr_stft2_times - trial.range(1)) * 1000;
			end
		end

			% plot
		clf( fig );

		set( fig, 'Color', figcol );
		if ~is_labeled( trial )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		subplot( 4, 1, [1, 2], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} ); % f1..f3 spectrogram
		title( sprintf( 'LABEL_FORMANTS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ) );
		xlabel( 'trial time in milliseconds' );
		ylabel( 'frequency in hertz' );

		xlim( (resplab.range - trial.range(1)) * 1000 );
		ylim( cfg.lab_formants_fx_freqband(1:2) );

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % signal
		imagesc( ovr_stft1_times, ovr_stft1_freqs, scale( ovr_stft1 .^ cfg.lab_formants_fx_gamma, flog ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );

		plot_formants( trial ); % formants

		subplot( 4, 1, 3, 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} ); % f0 spectrogram
		xlabel( 'trial time in milliseconds' );
		ylabel( 'frequency in hertz' );

		xlim( (resplab.range - trial.range(1)) * 1000 );
		ylim( cfg.lab_formants_f0_freqband(1:2) );

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % signal
		imagesc( ovr_stft2_times, ovr_stft2_freqs, scale( ovr_stft2 .^ cfg.lab_formants_f0_gamma, flog ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );

		plot_formants( trial ); % formants

		cdf.audit.plot_info( trial, false ); % label information

		s = { ... % general commands
			'GENERAL COMMANDS', ...
			'', ...
			'SPACE: next unlabeled trial', ...
			'PAGEDOWN/UP: +/- 1 trial' ...
			'SHIFT+PAGEDOWN/UP: +/- 10 trials', ...
			'CONTROL+PAGEDOWN/UP: +/- 100 trials', ...
			'HOME/END: first/last trial', ...
			'', ...
			'RETURN: playback audio', ...
			'', ...
			'D: toggle decibel scale', ...
			'', ...
			'CONTROL+BACKSPACE: clear trial mode labels', ...
			'SHIFT+CONTROL+ALT+BACKSPACE: clear run mode labels', ...
			'', ...
			'ESCAPE: save and quit' };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s );

		s = { ... % mode commands
			'MODE COMMANDS', ...
			'', ...
			'LEFT: set F0 onset', ...
			'', ...
			'F: set formant onsets (3 clicks, RETURN cancels)', ...
			'1: set F1 onset (1 click, RETURN cancels)', ...
			'2: set F2 onset (1 click, RETURN cancels)', ...
			'3: set F3 onset (1 click, RETURN cancels)', ...
			'', ...
			'B: toggle blending' };

		annotation( 'textbox', [2/3, 0, 1/3, 1/4], 'String', s );

			% wait for figure update
		waitfor( fig, 'Clipping' ); % wait for (unused) clipping property change

	end

		% logging
	logger.log( 'unlabeled trials: %d', sum( ~is_labeled( trials ) ) );

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

