function label( run, cfg )
% label data
%
% LABEL( run, cfg )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'label data...' );

	style = xis.hStyle.instance();

		% create interactive plot
	fig = style.figure( 'Visible', 'on' );

	set( fig, 'CloseRequestFcn', {@dispatch, 'close'} );
	set( fig, 'WindowKeyPressFcn', {@dispatch, 'keypress'} );
	set( fig, 'WindowKeyReleaseFcn', {@dispatch, 'keyrelease'} );

		% event dispatching
	function id = prev_trial( id )
		while true
			id = id - 1;
			if id < 1
				id = numel( run.trials );
			end

			if ~any( isnan( run.trials( id ).range ) )
				break;
			end
		end
	end

	function id = next_trial( id )
		while true
			id = id + 1;
			if id > numel( run.trials )
				id = 1;
			end

			if ~any( isnan( run.trials( id ).range ) )
				break;
			end
		end
	end

	function update()
		switch get( fig, 'Clipping' ) % flip unused clipping property
			case 'on'
				set( fig, 'Clipping', 'off' );
			case 'off'
				set( fig, 'Clipping', 'on' );
		end
	end

	function dispatch( src, event, type )
		switch type

			case 'close' % closing
				done = true;
				delete( fig );

			%case 'buttonup' % mouse input
			%case 'buttondown'
				%switch get( fig, 'SelectionType' )

					%case 'normal' % range start
						%cp = get( src, 'CurrentPoint' );
						%resp.range(1) = trial.range(1) + cp(1, 1) / 1000;
						%recompute = true;
						%update();

					%case 'alt' % range stop
						%cp = get( src, 'CurrentPoint' );
						%resp.range(2) = trial.range(1) + cp(1, 1) / 1000;
						%recompute = true;
						%update();

				%end

			case 'keypress' % keyboard input
			case 'keyrelease'
				switch event.Key

					case 'escape' % quit
						done = true;
						update();

					case 'leftarrow' % cycling
						id = prev_trial( id );
						recompute = true;
						update();
					case {'rightarrow', 'space'}
						id = next_trial( id );
						recompute = true;
						update();

					case 'downarrow' % zooming
						zoom = true;
						update();
					case 'uparrow'
						zoom = false;
						update();

					case 'add' % contrast
						contrast = contrast + 0.5;
						update();
					case 'subtract'
						contrast = contrast - 0.5;
						if contrast < 1
							contrast = 1;
						end
						update();

					case 'return' % playback
						sound( respts, run.audiorate );

					case 'backspace' % reset data
						%resp.range = [NaN, NaN];
						%resp.bo = NaN;
						%resp.vo = NaN;
						%resp.vr = NaN;
						resp.f0 = [NaN, NaN];
						resp.f1 = [NaN, NaN];
						resp.f2 = [NaN, NaN];
						resp.f3 = [NaN, NaN];
						recompute = true;
						update();

					%case 'b' % landmarks
						%if zoom
							%[x, ~] = ginput( 1 );
							%if ~isempty( x )
								%resp.bo = trial.range(1) + x / 1000;
								%update();
							%end
						%end
					%case 'v'
						%if zoom
							%[x, ~] = ginput( 1 );
							%if ~isempty( x )
								%resp.vo = trial.range(1) + x / 1000;
								%update();
							%end
						%end
					%case 'r'
						%if zoom
							%[x, ~] = ginput( 1 );
							%if ~isempty( x )
								%resp.vr = trial.range(1) + x / 1000;
								%update();
							%end
						%end

					case 'f' % formants
						if zoom
							[x, y] = ginput( 4 );
							if numel( x ) > 0 && numel( y ) > 0
								resp.f0(1) = trial.range(1) + x(1) / 1000;
								resp.f0(2) = y(1);
							end
							if numel( x ) > 1 && numel( y ) > 1
								resp.f1(1) = trial.range(1) + x(2) / 1000;
								resp.f1(2) = y(2);
							end
							if numel( x ) > 2 && numel( y ) > 2
								resp.f2(1) = trial.range(1) + x(3) / 1000;
								resp.f2(2) = y(3);
							end
							if numel( x ) > 3 && numel( y ) > 3
								resp.f3(1) = trial.range(1) + x(4) / 1000;
								resp.f3(2) = y(4);
							end
							update();
						end
					case '0'
						if zoom
							[x, y] = ginput( 1 );
							if ~isempty( x ) && ~isempty( y )
								resp.f0(1) = trial.range(1) + x / 1000;
								resp.f0(2) = y;
								update();
							end
						end
					case '1'
						if zoom
							[x, y] = ginput( 1 );
							if ~isempty( x ) && ~isempty( y )
								resp.f1(1) = trial.range(1) + x / 1000;
								resp.f1(2) = y;
								update();
							end
						end
					case '2'
						if zoom
							[x, y] = ginput( 1 );
							if ~isempty( x ) && ~isempty( y )
								resp.f2(1) = trial.range(1) + x / 1000;
								resp.f2(2) = y;
								update();
							end
						end
					case '3'
						if zoom
							[x, y] = ginput( 1 );
							if ~isempty( x ) && ~isempty( y )
								resp.f3(1) = trial.range(1) + x / 1000;
								resp.f3(2) = y;
								update();
							end
						end

					%otherwise % DEBUG
						%event.Key

				end

		end
	end

		% interaction loop
	done = false;

	zoom = false;
	recompute = true;

	contrast = 3;

	ntrials = numel( run.trials );
	id = 1;

	while ~done

			% prepare data
		trial = run.trials(id);

		resp = run.resps_lab(id);

		if zoom % signal range
			respr = dsp.sec2smp( resp.range, run.audiorate ) + [1, 0];
			if any( isnan( respr ) )
				zoom = false;
			end
		end
		if ~zoom
			respr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0];
			if any( isnan( respr ) )
				error( 'invalid value: respr' );
			end
		end

		respts = run.audiodata(respr(1):respr(2), 1); % signal

		if zoom && recompute
			[respst, respfreqs] = dsp.fst( respts, run.audiorate, cfg.lab_freqband(1), cfg.lab_freqband(2), cfg.lab_nfreqs );
			recompute = false;
		end

		xs = 1000 * (dsp.smp2sec( respr(1):respr(2), run.audiorate ) - trial.range(1)); % axes scaling
		xl = [min( xs ), max( xs )];

			% plot signal
		clf( fig );

		if zoom
			subplot( 2, 1, 1 );
		end
		title( sprintf( 'trial: %d/%d', id, ntrials ) );
		xlabel( 'trial-time in milliseconds' );
		ylabel( 'response magnitude' );

		xlim( xl );
		yl = max( abs( respts ) ) * style.scale( 1/2 ) * [-1, 1];
		ylim( yl );

		if ~zoom && ~any( isnan( resp.range ) ) && diff( resp.range ) > 0 % response range
			rectangle( 'Position', [ ...
				1000 * (resp.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				1000 * diff( resp.range ), abs( style.scale( -1 ) * yl(1) )], ...
				'EdgeColor', style.color( 'warm', +2 ), 'FaceColor', style.color( 'warm', +2 ), ...
				'HitTest', 'off' );
		end
		if ~zoom && ~isnan( resp.range(1) )
			stem( 1000 * (resp.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
		end
		if ~zoom && ~isnan( resp.range(2) )
			stem( 1000 * (resp.range(2) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
		end

		if ~isnan( resp.bo ) % landmarks
			stem( 1000 * (resp.bo - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp.bo - trial.range(1)), style.scale( -1 ) * yl(1), ...
					'Color', style.color( 'warm', 0 ), ...
					'HitTest', 'off' );
			end
		end
		if ~isnan( resp.vo )
			stem( 1000 * (resp.vo - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp.vo - trial.range(1)), style.scale( -1 ) * yl(1), ...
					'Color', style.color( 'warm', 0 ), ...
					'HitTest', 'off' );
			end
		end
		if ~isnan( resp.vr )
			stem( 1000 * (resp.vr - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp.vr - trial.range(1)), style.scale( -1 ) * yl(1), ...
					'Color', style.color( 'warm', 0 ), ...
					'HitTest', 'off' );
			end
		end

		stairs( xs, respts, ... % signal
			'Color', style.color( 'cold', -1 ), ...
			'HitTest', 'off' );

		if ~zoom
			set( gca(), 'ButtonDownFcn', {@dispatch, 'buttondown'} );
		end

			% plot spectrogram
		if zoom
			subplot( 2, 1, 2 );
			xlabel( 'trial-time in milliseconds' );
			ylabel( 'frequency in hertz' );

			xlim( xl );
			ylim( [min( respfreqs ), max( respfreqs )] );

			colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) ); % spectrogram
			imagesc( xs, respfreqs, log( (respst .* conj( respst )).^contrast + eps ), ...
				'HitTest', 'off' );

			if ~any( isnan( resp.f0 ) )
				scatter( 1000 * (resp.f0(1) - trial.range(1)), resp.f0(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp.f1 ) )
				scatter( 1000 * (resp.f1(1) - trial.range(1)), resp.f1(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp.f2 ) )
				scatter( 1000 * (resp.f2(1) - trial.range(1)), resp.f2(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp.f3 ) )
				scatter( 1000 * (resp.f3(1) - trial.range(1)), resp.f3(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end

		end

			% dispatch interaction events
		waitfor( fig, 'Clipping' ); % misuse unused clipping property change

	end

		% done
	if ishandle( fig )
		delete( fig );
	end

	logger.untab();
end

