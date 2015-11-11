function label_activity( run, cfg )
% activity labeling tool
%
% LABEL_ACTIVITY( run, cfg )
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
	logger.tab( 'activity labeling tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );
	figcol = get( fig, 'Color' );

	set( fig, 'WindowKeyPressFcn', {@fig_dispatch, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@fig_dispatch, 'close'} );

		% figure event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				switch event.Key
					case 'space' % browse
						rrs = cat( 1, resps(itrial+1:end).range );
						if ~isempty( rrs )
							itrial = itrial + min( find( isnan( rrs(:, 1) ), 1, 'first' ), find( isnan( rrs(:, 2) ), 1, 'first' ) );
							fig_update();
						end

					case {'rightarrow', 'downarrow'}
						step = 1;
						if any( strcmp( event.Modifier, 'shift' ) )
							step = 10;
						end
						if any( strcmp( event.Modifier, 'control' ) )
							step = 100;
						end
						itrial = min( itrial + step, ntrials );
						fig_update();
					case {'leftarrow', 'uparrow'}
						step = 1;
						if any( strcmp( event.Modifier, 'shift' ) )
							step = 10;
						end
						if any( strcmp( event.Modifier, 'control' ) )
							step = 100;
						end
						itrial = max( itrial - step, 1 );
						fig_update();

					case 'home'
						itrial = 1;
						fig_update();
					case 'end'
						itrial = ntrials;
						fig_update();

					case 'return' % playback, TODO: untested!
						sound( ovrts, run.audiorate );

					case 'l' % scaling
						logscale = ~logscale;
						fig_update();

					case 'backspace' % clearing
						resp.range = [NaN, NaN];
						fig_update();

					case 'escape' % quit
						done = true;
						fig_update();

					otherwise % DEBUG
						logger.log( 'keypress: %s', event.Key );
				end

				% button presses
			case 'buttondown'
				while ~strcmp( get( src, 'Type' ), 'axes' ) % get parent axes
					src = get( src, 'Parent' );
				end

				switch get( fig, 'SelectionType' )
					case 'normal' % set range start
						cp = trial.range(1) + get( src, 'CurrentPoint' ) / 1000;
						if isnan( resp.range(2) ) || cp(1) < resp.range(2)
							resp.range(1) = cp(1);
							fig_update();
						end
					case 'alt' % set range stop
						cp = trial.range(1) + get( src, 'CurrentPoint' ) / 1000;
						if isnan( resp.range(1) ) || cp(1) > resp.range(1)
							resp.range(2) = cp(1);
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

	logscale = false;

	trials = [run.trials];
	ntrials = numel( trials );
	itrial = 1;

	resps = [trials.resplab];

	while ~done

			% prepare data
		trial = trials(itrial); % objects
		resp = resps(itrial);

		ovrr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges
		det1r = dsp.sec2smp( resp.range(1) + cfg.lab_activity_det1, run.audiorate ) + [1, 0];
		det2r = dsp.sec2smp( resp.range(2) + cfg.lab_activity_det2, run.audiorate ) + [1, 0];

		det1r(det1r < 1) = 1;
		det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		det2r(det2r < 1) = 1;
		det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

		det1f = ~any( isnan( det1r ) );
		det2f = ~any( isnan( det2r ) );

		if ~det1f || ~det2f
			set( fig, 'Color', style.color( 'signal', +2 ) );
		else
			set( fig, 'Color', figcol );
		end

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals
		if det1f
			det1ts = run.audiodata(det1r(1):det1r(2), 1);
		end
		if det2f
			det2ts = run.audiodata(det2r(1):det2r(2), 1);
		end

		if logscale
			ovrts = log( abs( ovrts ) );
			if det1f
				det1ts = log( abs( det1ts ) );
			end
			if det2f
				det2ts = log( abs( det2ts ) );
			end
		end

		ovryl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1 ); % axes
		if det1f
			det1yl = max( abs( det1ts ) ) * [-1, 1] * style.scale( 1 );
		end
		if det2f
			det2yl = max( abs( det2ts ) ) * [-1, 1] * style.scale( 1 );
		end

		if logscale
			ovryl = [min( ovrts(~isinf( ovrts )) ), max( ovrts )];
			ovryl(2) = ovryl(2) + diff( ovryl ) * (style.scale( 1 ) - 1) / 2;
			if det1f
				det1yl = [min( det1ts(~isinf( det1ts )) ), max( det1ts )];
				det1yl(2) = det1yl(2) + diff( det1yl ) * (style.scale( 1 ) - 1) / 2;
			end
			if det2f
				det2yl = [min( det2ts(~isinf( det2ts )) ), max( det2ts )];
				det2yl(2) = det2yl(2) + diff( det2yl ) * (style.scale( 1 ) - 1) / 2;
			end
		end

			% plot
		clf( fig );

		hovr = subplot( 4, 2, [1, 2], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} ); % overview
		title( sprintf( 'LABEL_ACTIVITY (trial: %d/%d)', itrial, ntrials ) );
		xlabel( 'time in milliseconds' );
		ylabel( 'response' );

		xlim( (trial.range - trial.range(1)) * 1000 );
		ylim( ovryl );

		if ~any( isnan( resp.range ) ) % range
			rectangle( 'Position', [ ...
				(resp.range(1) - trial.range(1)) * 1000, ovryl(1), ...
				diff( resp.range ) * 1000, ovryl(2)-ovryl(1) ], ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'FaceColor', style.color( 'signal', +2 ), 'EdgeColor', 'none' );
		end
		plot( (resp.range(1) * [1, 1] - trial.range(1)) * 1000, ovryl, ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (resp.range(2) * [1, 1] - trial.range(1)) * 1000, ovryl, ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'signal', +1 ) );

		plot( (dsp.smp2sec( (ovrr(1):ovrr(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, ovrts, ... % signal
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'cold', -1 ) );

		if det1f % detail #1
			hdet1 = subplot( 4, 2, [3, 5], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
			xlabel( 'time in milliseconds' );
			ylabel( 'range start detail' );

			xlim( (resp.range(1) + cfg.lab_activity_det1 - trial.range(1)) * 1000 );
			ylim( det1yl );

			if ~any( isnan( resp.range ) ) % range
				rectangle( 'Position', [ ...
					(resp.range(1) - trial.range(1)) * 1000, det1yl(1), ...
					diff( resp.range ) * 1000, det1yl(2)-det1yl(1) ], ...
					'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
					'FaceColor', style.color( 'signal', +2 ), 'EdgeColor', 'none' );
			end
			plot( (resp.range(1) * [1, 1] - trial.range(1)) * 1000, det1yl, ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'signal', +1 ) );
			plot( (resp.range(2) * [1, 1] - trial.range(1)) * 1000, det1yl, ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'signal', +1 ) );

			plot( (dsp.smp2sec( (det1r(1):det1r(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, det1ts, ... % signal
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'cold', -1 ) );
		end

		if det2f % detail #2
			hdet2 = subplot( 4, 2, [4, 6], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
			xlabel( 'time in milliseconds' );
			ylabel( 'range stop detail' );

			xlim( (resp.range(2) + cfg.lab_activity_det2 - trial.range(1)) * 1000 );
			ylim( det2yl );

			if ~any( isnan( resp.range ) ) % range
				rectangle( 'Position', [ ...
					(resp.range(1) - trial.range(1)) * 1000, det2yl(1), ...
					diff( resp.range ) * 1000, det2yl(2)-det2yl(1) ], ...
					'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
					'FaceColor', style.color( 'signal', +2 ), 'EdgeColor', 'none' );
			end
			plot( (resp.range(1) * [1, 1] - trial.range(1)) * 1000, det2yl, ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'signal', +1 ) );
			plot( (resp.range(2) * [1, 1] - trial.range(1)) * 1000, det2yl, ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'signal', +1 ) );

			plot( (dsp.smp2sec( (det2r(1):det2r(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, det2ts, ... % signal
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'cold', -1 ) );
		end

		str = { ... % information
			'INFORMATION', ...
			'', ...
			sprintf( 'range: [%.1f, %.1f]', (resp.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (resp.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (resp.vo - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'class: ''%s''', resp.label ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (resp.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (resp.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (resp.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (resp.f0 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [0, 0, 1/3, 1/4], 'String', str );

		str = { ... % general help
			'GENERAL KEYS', ...
			'', ...
			'SPACE: next unlabeled trial', ...
			'', ...
			'ARROWS: browse trials', ...
			'SHIFT+ARROWS: -/+ 10 trials', ...
			'CTRL+ARROWS: -/+ 100 trials', ...
			'HOME: first trial', ...
			'END: last trial', ...
			'', ...
			'RETURN: play audio', ...
			'', ...
			'BACKSPACE: clear labels', ...
			'', ...
			'ESCAPE: quit' };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', str );

		str = { ... % mode help
			'MODE KEYS', ...
			'', ...
			'L: toggle logarithmic scale', ...
			'', ...
			'LEFT-BUTTON: set range start', ...
			'RIGHT-BUTTON: set range stop' };

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

