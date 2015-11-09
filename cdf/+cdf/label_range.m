function label_range( run, cfg )
% range labeling tool
%
% LABEL_RANGE( run, cfg )
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
	logger.tab( 'range labeling tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );

	set( fig, 'WindowKeyPressFcn', {@fig_dispatch, 'keypress'} );
	set( fig, 'WindowButtonDownFcn', {@fig_dispatch, 'buttondown'} );
	set( fig, 'CloseRequestFcn', {@fig_dispatch, 'close'} );

		% figure event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				switch event.Key
					case 'rightarrow' % browsing
						step = 1;
						if any( strcmp( event.Modifier, 'shift' ) )
							step = 10;
						end
						if any( strcmp( event.Modifier, 'control' ) )
							step = 100;
						end
						itrial = mod( itrial-1 + step, ntrials ) + 1; % forward
						fig_update();
					case 'leftarrow'
						step = 1;
						if any( strcmp( event.Modifier, 'shift' ) )
							step = 10;
						end
						if any( strcmp( event.Modifier, 'control' ) )
							step = 100;
						end
						itrial = mod( itrial-1 - step, ntrials ) + 1; % backward
						fig_update();
					case 'home'
						itrial = 1;
						fig_update();
					case 'end'
						itrial = ntrials;
						fig_update();

					case 'return' % playback
						sound( rts, run.audiorate );

					case 'l' % scaling
						logscale = ~logscale;
						fig_update();

					case 'backspace' % clearing
						trial.resplab.range = [NaN, NaN];
						fig_update();

					case 'escape' % quit
						done = true;
						fig_update();

					otherwise % DEBUG
						logger.log( 'keypress: %s', event.Key );
				end

				% button presses
			case 'buttondown'
				switch get( fig, 'SelectionType' )
					case 'normal' % range start
						cp = trial.range(1) + get( h, 'CurrentPoint' ) / 1000;
						if isnan( trial.resplab.range(2) ) || cp(1) < trial.resplab.range(2)
							trial.resplab.range(1) = cp(1);
							fig_update();
						end
					case 'alt' % range stop
						cp = trial.range(1) + get( h, 'CurrentPoint' ) / 1000;
						if isnan( trial.resplab.range(1) ) || cp(1) > trial.resplab.range(1)
							trial.resplab.range(2) = cp(1);
							fig_update();
						end
				end

				% figure closing
			case 'close'
				done = true;
				delete( fig );
		end
	end

	function fig_update()
		switch get( fig, 'Clipping' ) % flip (unused) clipping property
			case 'on'
				set( fig, 'Clipping', 'off' );
			case 'off'
				set( fig, 'Clipping', 'on' );
		end
	end

		% figure interaction loop
	done = false;

	ntrials = numel( run.trials );
	itrial = 1;

	logscale = false;

	while ~done

			% prepare data
		trial = run.trials(itrial);

		tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % range

		rts = run.audiodata(tr(1):tr(2), 1); % signal
		if logscale
			rts = log( abs( rts ) );
		end

		yl = max( abs( rts ) ) * [-1, 1] * style.scale( 1 ); % axes
		if logscale
			yl = [min( rts(~isinf( rts )) ), max( rts )];
			yl(2) = yl(2) + diff( yl ) * (style.scale( 1 ) - 1) / 2;
		end

			% plot
		clf( fig );

		h = subplot( 4, 1, [1, 3] ); % signal/range
		title( sprintf( 'LABEL_RANGE (trial: %d/%d)', itrial, ntrials ) );
		xlabel( 'time in milliseconds' );
		ylabel( 'response' );

		xlim( (trial.range - trial.range(1)) * 1000 );
		ylim( yl );

		if ~any( isnan( trial.resplab.range ) ) % range
			rectangle( 'Position', [ ...
				(trial.resplab.range(1) - trial.range(1)) * 1000, yl(1), ...
				diff( trial.resplab.range ) * 1000, yl(2)-yl(1) ], ...
				'FaceColor', style.color( 'signal', +2 ), 'EdgeColor', 'none' );
		end
		plot( (trial.resplab.range(1) * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (trial.resplab.range(2) * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'signal', +1 ) );

		plot( (dsp.smp2sec( (tr(1):tr(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, rts, ... % signal
			'Color', style.color( 'cold', -1 ) );

		str = { ... % information
			'INFORMATION', ...
			'', ...
			sprintf( 'range: [%.1f, %.1f]', (trial.resplab.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'class: ''%s''', trial.resplab.label ), ...
			'', ...
			sprintf( 'burst-onset: %.1f', (trial.resplab.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice-onset: %.1f', (trial.resplab.vo - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0-onset: [%.1f, %.1f]', (trial.resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1-onset: [%.1f, %.1f]', (trial.resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2-onset: [%.1f, %.1f]', (trial.resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3-onset: [%.1f, %.1f]', (trial.resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ) };
		annotation( 'textbox', [0, 0, 1/3, 1/4], 'String', str );

		str = { ... % general help
			'GENERAL COMMANDS', ...
			'', ...
			'LEFT: previous trial', ...
			'RIGHT: next trial', ...
			'SHIFT+LEFT: -10 trials', ...
			'SHIFT+RIGHT: +10 trials', ...
			'CTRL+LEFT: -100 trials', ...
			'CTRL+RIGHT: +100 trials', ...
			'HOME: first trial', ...
			'END: last trial', ...
			'', ...
			'RETURN: audio playback', ...
			'', ...
			'ESCAPE: quit' };
		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', str );

		str = { ... % mode help
			'MODE COMMANDS', ...
			'', ...
			'L: toggle logarithmic scale', ...
			'', ...
			'LEFT-BUTTON: range start', ...
			'RIGHT-BUTTON: range stop', ...
			'', ...
			'BACKSPACE: clear labels' };
		annotation( 'textbox', [2/3, 0, 1/3, 1/4], 'String', str );

			% wait for figure update
		waitfor( fig, 'Clipping' ); % wait for (unused) clipping property change

	end

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

