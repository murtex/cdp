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

			case 'buttonup' % mouse input
			case 'buttondown'
				switch get( fig, 'SelectionType' )

					case 'normal' % range start
						cp = get( src, 'CurrentPoint' );
						resp_lab.range(1) = trial.range(1) + cp(1, 1) / 1000;
						recompute = true;
						update();

					case 'alt' % range stop
						cp = get( src, 'CurrentPoint' );
						resp_lab.range(2) = trial.range(1) + cp(1, 1) / 1000;
						recompute = true;
						update();

				end

			case 'keypress' % keyboard input
			case 'keyrelease'
				switch event.Key

					case 'escape' % quit
						done = true;
						update();

					case 'leftarrow' % cycle trials
						id = id - 1;
						if id < 1
							id = ntrials;
						end
						recompute = true;
						update();
					case 'rightarrow'
						id = id + 1;
						if id > ntrials
							id = 1;
						end
						recompute = true;
						update();
					case 'pageup'
						id = id - 10;
						if id < 1
							id = ntrials;
						end
						recompute = true;
						update();
					case 'pagedown'
						id = id + 10;
						if id > ntrials
							id = 1;
						end
						recompute = true;
						update();
					case 'space'
						id = id + 1;
						if id > ntrials
							id = 1;
						end
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
						resp_lab.range = [NaN, NaN];
						resp_lab.bo = NaN;
						resp_lab.vo = NaN;
						resp_lab.vr = NaN;
						resp_lab.f0 = [NaN, NaN];
						resp_lab.f1 = [NaN, NaN];
						resp_lab.f2 = [NaN, NaN];
						resp_lab.f3 = [NaN, NaN];
						recompute = true;
						update();

					case 'b' % landmarks
						if zoom
							[x, ~] = ginput( 1 );
							if ~isempty( x )
								resp_lab.bo = trial.range(1) + x / 1000;
								update();
							end
						end
					case 'v'
						if zoom
							[x, ~] = ginput( 1 );
							if ~isempty( x )
								resp_lab.vo = trial.range(1) + x / 1000;
								update();
							end
						end
					case 'r'
						if zoom
							[x, ~] = ginput( 1 );
							if ~isempty( x )
								resp_lab.vr = trial.range(1) + x / 1000;
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

		resp_det = run.resps_det(id);
		resp_lab = run.resps_lab(id);

		if isnan( resp_lab.range(1) ) && ~isnan( resp_det.range(1) ) % detection hints
			resp_lab.range(1) = resp_det.range(1);
		end
		if isnan( resp_lab.range(2) ) && ~isnan( resp_det.range(2) )
			resp_lab.range(2) = resp_det.range(2);
		end
		if isnan( resp_lab.bo ) && ~isnan( resp_det.bo )
			resp_lab.bo = resp_det.bo;
		end
		if isnan( resp_lab.vo ) && ~isnan( resp_det.vo )
			resp_lab.vo = resp_det.vo;
		end
		if isnan( resp_lab.vr ) && ~isnan( resp_det.vr )
			resp_lab.vr = resp_det.vr;
		end

		if zoom % signal range
			respr = dsp.sec2smp( resp_lab.range, run.audiorate ) + [1, 0];
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

		if ~zoom && ~any( isnan( resp_lab.range ) ) && diff( resp_lab.range ) > 0 % response range
			rectangle( 'Position', [ ...
				1000 * (resp_lab.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				1000 * diff( resp_lab.range ), abs( style.scale( -1 ) * yl(1) )], ...
				'EdgeColor', style.color( 'warm', +2 ), 'FaceColor', style.color( 'warm', +2 ), ...
				'HitTest', 'off' );
		end
		if ~zoom && ~isnan( resp_lab.range(1) )
			stem( 1000 * (resp_lab.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
		end
		if ~zoom && ~isnan( resp_lab.range(2) )
			stem( 1000 * (resp_lab.range(2) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
		end

		if ~isnan( resp_lab.bo ) % landmarks
			stem( 1000 * (resp_lab.bo - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp_lab.bo - trial.range(1)), style.scale( -1 ) * yl(1), ...
					'Color', style.color( 'warm', 0 ), ...
					'HitTest', 'off' );
			end
		end
		if ~isnan( resp_lab.vo )
			stem( 1000 * (resp_lab.vo - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp_lab.vo - trial.range(1)), style.scale( -1 ) * yl(1), ...
					'Color', style.color( 'warm', 0 ), ...
					'HitTest', 'off' );
			end
		end
		if ~isnan( resp_lab.vr )
			stem( 1000 * (resp_lab.vr - trial.range(1)), style.scale( -1 ) * yl(2), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
			if zoom
				stem( 1000 * (resp_lab.vr - trial.range(1)), style.scale( -1 ) * yl(1), ...
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

			if ~any( isnan( resp_lab.f0 ) )
				scatter( 1000 * (resp_lab.f0(1) - trial.range(1)), resp_lab.f0(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp_lab.f1 ) )
				scatter( 1000 * (resp_lab.f1(1) - trial.range(1)), resp_lab.f1(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp_lab.f2 ) )
				scatter( 1000 * (resp_lab.f2(1) - trial.range(1)), resp_lab.f2(2), ...
					'MarkerEdgeColor', style.color( 'warm', 0 ), 'MarkerFaceColor', 'none', ...
					'HitTest', 'off' );
			end
			if ~any( isnan( resp_lab.f3 ) )
				scatter( 1000 * (resp_lab.f3(1) - trial.range(1)), resp_lab.f3(2), ...
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
