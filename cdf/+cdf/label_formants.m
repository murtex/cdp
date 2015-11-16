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
			if any( isnan( trials(i).resplab.range ) )
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

		% event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'space' % trial browsing
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
							[x, y] = ginput( 4 );
							if numel( y ) > 0 && y(1) >= min( ovrfreqs(ovrfreqs > 0) ) && y(1) <= max( ovrfreqs )
								resp.f0(1) = trial.range(1) + x(1) / 1000;
								resp.f0(2) = y(1);
							end
							if numel( y ) > 1 && y(2) >= min( ovrfreqs(ovrfreqs > 0) ) && y(2) <= max( ovrfreqs )
								resp.f1(1) = trial.range(1) + x(2) / 1000;
								resp.f1(2) = y(2);
							end
							if numel( y ) > 2 && y(3) >= min( ovrfreqs(ovrfreqs > 0) ) && y(3) <= max( ovrfreqs )
								resp.f2(1) = trial.range(1) + x(3) / 1000;
								resp.f2(2) = y(3);
							end
							if numel( y ) > 3 && y(4) >= min( ovrfreqs(ovrfreqs > 0) ) && y(4) <= max( ovrfreqs )
								resp.f3(1) = trial.range(1) + x(4) / 1000;
								resp.f3(2) = y(4);
							end
							fig_update( false );
						end
					case '0'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= min( ovrfreqs(ovrfreqs > 0) ) && y(1) <= max( ovrfreqs )
								resp.f0(1) = trial.range(1) + x(1) / 1000;
								resp.f0(2) = y(1);
							end
							fig_update( false );
						end
					case '1'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= min( ovrfreqs(ovrfreqs > 0) ) && y(1) <= max( ovrfreqs )
								resp.f1(1) = trial.range(1) + x(1) / 1000;
								resp.f1(2) = y(1);
							end
							fig_update( false );
						end
					case '2'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= min( ovrfreqs(ovrfreqs > 0) ) && y(1) <= max( ovrfreqs )
								resp.f2(1) = trial.range(1) + x(1) / 1000;
								resp.f2(2) = y(1);
							end
							fig_update( false );
						end
					case '3'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= min( ovrfreqs(ovrfreqs > 0) ) && y(1) <= max( ovrfreqs )
								resp.f3(1) = trial.range(1) + x(1) / 1000;
								resp.f3(2) = y(1);
							end
							fig_update( false );
						end

					case 'return' % playback
						if nmods == 0
							sound( ovrts / max( abs( ovrts ) ), run.audiorate );
						end

					case 'backspace' % clearing
						if nmods == 0
							resp.f0 = [NaN, NaN];
							resp.f1 = [NaN, NaN];
							resp.f2 = [NaN, NaN];
							resp.f3 = [NaN, NaN];
							fig_update( false );
						end

					case 'escape' % quit
						if nmods == 0
							done = true;
							fig_update( false );
						end

					otherwise % DEBUG
						logger.log( 'keypress: %s', event.Key );
				end

				% figure closing
			case 'close'
				done = true;
				delete( fig );
		end
	end

	function fig_update( recomp )
		recompute = recomp; % set recomputation flag

		switch get( fig, 'Clipping' ) % flip (unused) clipping property
			case 'on'
				set( fig, 'Clipping', 'off' );
			case 'off'
				set( fig, 'Clipping', 'on' );
		end
	end

		% interaction loop
	trials = [run.trials]; % prepare trials
	trials(~is_valid( trials )) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );
	logger.log( 'unlabeled trials: %d', sum( ~is_labeled( trials ) ) );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	itrial = max( 1, next_unlabeled( trials, 0 ) );

	done = false; % init flags
	recompute = true;

	while ~done

			% prepare data
		trial = trials(itrial);
		resp = trial.resplab;

		ovrr = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0]; % ranges

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

		if recompute
			[ovrst, ovrfreqs] = dsp.stransf( ovrts, run.audiorate, cfg.lab_formants_freqband(1), cfg.lab_formants_freqband(2), cfg.lab_formants_nfreqs );
		end

			% plot
		clf( fig );

		set( fig, 'Color', figcol );
		if ~is_labeled( trial )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		subplot( 4, 1, 1 ); % overview
		title( sprintf( 'LABEL_FORMANTS (trial: %d/%d)', itrial, ntrials ) );
		xlabel( 'trial time in milliseconds' );
		ylabel( 'response' );

		xlim( (resp.range - trial.range(1)) * 1000 );
		yl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 );
		ylim( yl );

		plot( (dsp.smp2sec( (ovrr(1):ovrr(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, ovrts, ... % signal
			'Color', style.color( 'cold', -1 ) );

		subplot( 4, 1, [2, 3] ); % spectrogram
		xlabel( 'trial time in milliseconds' );
		ylabel( 'frequency in hertz' );

		xlim( (resp.range - trial.range(1)) * 1000 );
		ylim( [min( ovrfreqs(ovrfreqs > 0) ), max( ovrfreqs )] );

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % signal
		imagesc( (dsp.smp2sec( (ovrr(1):ovrr(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, ovrfreqs, ...
			log( (ovrst .* conj( ovrst )) .^ cfg.lab_formants_gamma + eps ) );

		scatter( (resp.f0(1) - trial.range(1)) * 1000, resp.f0(2), ... % onsets
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ) );
		scatter( (resp.f1(1) - trial.range(1)) * 1000, resp.f1(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ) );
		scatter( (resp.f2(1) - trial.range(1)) * 1000, resp.f2(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ) );
		scatter( (resp.f3(1) - trial.range(1)) * 1000, resp.f3(2), ...
			'MarkerEdgeColor', style.color( 'signal', +1 ), 'MarkerFaceColor', style.color( 'signal', +2 ) );

		s = { ... % information
			'INFORMATION', ...
			'-----------', ...
			'', ...
			sprintf( 'class: ''%s''', resp.label ), ...
			'', ...
			sprintf( 'activity: [%.1f, %.1f]', (resp.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (resp.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (resp.vo - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (resp.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (resp.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (resp.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (resp.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [0, 0, 1/3, 1/4], 'String', s );

		s = { ... % general commands
			'GENERAL COMMANDS', ...
			'----------------', ...
			'', ...
			'SPACE: next unlabeled trial', ...
			'PAGEDOWN/UP: +/- 1 trial' ...
			'SHIFT+PAGEDOWN/UP: +/- 10 trials', ...
			'CONTROL+PAGEDOWN/UP: +/- 100 trials', ...
			'HOME/END: first/last trial', ...
			'', ...
			'RETURN: playback audio', ...
			'', ...
			'BACKSPACE: clear labels', ...
			'', ...
			'ESCAPE: save and quit' };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s );

		s = { ... % specific commands
			'SPECIFIC COMMANDS', ...
			'-----------------', ...
			'', ...
			'F: set formant onsets', ...
			'0: set F0 onset', ...
			'1: set F1 onset', ...
			'2: set F2 onset', ...
			'3: set F3 onset' };

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

