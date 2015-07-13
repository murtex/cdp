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
	fig = style.figure(	'Visible', 'on' );

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

					case 'normal' % set response range start
						cp = get( src, 'CurrentPoint' );
						resp.range(1) = trial.range(1) + cp(1, 1) / 1000;
						update();

					case 'alt' % set response range stop
						cp = get( src, 'CurrentPoint' );
						resp.range(2) = trial.range(1) + cp(1, 1) / 1000;
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
						update();
					case 'rightarrow'
						id = id + 1;
						if id > ntrials
							id = 1;
						end
						update();

					case 'downarrow' % zooming
						zoom = true;
						update();
					case 'uparrow'
						zoom = false;
						update();

					case 'backspace' % mode change
						mode = 'range';
					case 'b'
						mode = 'bo';
					case '0'
						mode = 'f0';
					case '1'
						mode = 'f1';
					case '2'
						mode = 'f2';
					case '3'
						mode = 'f3';
					case 'r';
						mode = 'vr';

					case 'space' % playback
						sound( respts, run.audiorate );

					case 'backspace' % reset data
						switch mode
							case 'range'
								resp.range = [NaN, NaN];
							case 'bo'
								resp.bo = NaN;
							case 'f0'
								resp.f0 = [NaN, NaN];
							case 'f1'
								resp.f1 = [NaN, NaN];
							case 'f2'
								resp.f2 = [NaN, NaN];
							case 'f3'
								resp.f3 = [NaN, NaN];
							case 'vr'
								resp.vr = NaN;
						end
						update();

				end

		end
	end

		% interaction loop
	done = false;
	zoom = false;
	recompute = true;
	mode = 'range';

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

		if ~any( isnan( resp.range ) ) && diff( resp.range ) > 0 % response range
			h = rectangle( 'Position', [ ...
				1000 * (resp.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				1000 * diff( resp.range ), abs( style.scale( -1 ) * yl(1) )], ...
				'EdgeColor', style.color( 'warm', +2 ), 'FaceColor', style.color( 'warm', +2 ), ...
				'HitTest', 'off' );
		end
		if ~isnan( resp.range(1) )
			stem( 1000 * (resp.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
		end
		if ~isnan( resp.range(2) )
			stem( 1000 * (resp.range(2) - trial.range(1)), style.scale( -1 ) * yl(1), ...
				'Color', style.color( 'warm', 0 ), ...
				'HitTest', 'off' );
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

			colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
			imagesc( xs, respfreqs, log( (respst .* conj( respst )).^3 + eps ) );
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

