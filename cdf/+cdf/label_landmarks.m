function label_landmarks( run, cfg )
% landmarks labeling tool
%
% LABEL_LANDMARKS( run, cfg )
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
	logger.tab( 'landmarks labeling tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );
	figcol = get( fig, 'Color' );

	set( fig, 'WindowKeyPressFcn', {@fig_dispatch, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@fig_dispatch, 'close'} );

		% helper functions
	function f = is_valid( trials )
		f = false( size( trials ) );
		for i = 1:numel( trials )
			if ~isempty( trials(i).resplab.label ) && ~any( isnan( trials(i).resplab.range ) )
				f(i) = true;
			end
		end
	end

	function f = is_labeled( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if isnan( trials(i).resplab.bo ) || isnan( trials(i).resplab.vo ) || isnan( trials(i).resplab.vr )
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

	function i = snap( ts, t0, i, align )
		if align

			zc = sign( ts ); % find zero crossings
			zc(zc == 0) = 1;
			zc = abs( diff( zc ) / 2 );
			zc = find( zc == 1 );

			if isempty( zc )
				return;
			end

			is = dsp.sec2smp( i - t0, run.audiorate ) + 1; % choose nearest
			d = zc - is;
			d = d(find( abs( d ) == min( abs( d ) ), 1 )) + 1;
			i = dsp.smp2sec( is + d - 1, run.audiorate ) + t0;

		end
	end

	function ts = scale( ts, logscale )
		if logscale
			ts = mag2db( abs( ts ) + eps );
		end
	end

	function plot_landmarks( trial, yl )
		plot( (trial.resplab.bo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (trial.resplab.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (trial.resplab.vr * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'signal', +1 ) );
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
							fig_update();
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
							fig_update();
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
							fig_update();
						end

					case 'home'
						if nmods == 0 && itrial ~= 1
							itrial = 1;
							fig_update();
						end
					case 'end'
						if nmods == 0 && itrial ~= ntrials
							itrial = ntrials;
							fig_update();
						end

					case 'd' % decibel scale
						if nmods == 0
							logscale = ~logscale;
							fig_update();
						end

					case 'l' % landmarks setting
						if nmods == 0
							[x, ~] = ginput( 3 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.bo = x(1);
							end
							if numel( x ) > 1 && x(2) >= resplab.range(1) && x(2) <= resplab.range(2)
								resplab.vo = x(2);
							end
							if numel( x ) > 2 && x(3) >= resplab.range(1) && x(3) <= resplab.range(2)
								resplab.vr = x(3);
							end

							fig_update();
						end
					case 'b'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.bo = x(1);
							end

							fig_update();
						end
					case 'v'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.vo = x(1);
							end

							fig_update();
						end
					case 'r'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.vr = x(1);
							end

							fig_update();
						end

					case 'return' % playback
						if nmods == 0
							soundsc( ovrts, run.audiorate );
						elseif nmods == 1 && strcmp( event.Modifier, 'shift' ) && fresp
							soundsc( respts, run.audiorate );
						end

					case 'backspace' % clearing
						if nmods == 1 && strcmp( event.Modifier, 'shift' ) % clear trial
							resplab.bo = NaN;
							resplab.vo = NaN;
							resplab.vr = NaN;
							fig_update();
						elseif nmods == 2 && any( strcmp( event.Modifier, 'shift' ) ) && any( strcmp( event.Modifier, 'control' ) ) % clear run (valids only)
							for i = 1:ntrials
								trials(i).resplab.bo = NaN;
								trials(i).resplab.vo = NaN;
								trials(i).resplab.vr = NaN;
							end
							itrial = 1;
							fig_update();
						end

					case 'escape' % quit
						if nmods == 0
							done = true;
							fig_update();
						end
				end

				% button presses
			case 'buttondown'
				while ~strcmp( get( src, 'Type' ), 'axes' ) % get parent axis
					src = get( src, 'Parent' );
				end

				switch get( fig, 'SelectionType' ) % landmarks adjustment
					case 'normal'
						cp = trial.range(1) + get( src, 'CurrentPoint' ) / 1000;

						switch src
							case hdet1
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.bo = snap( ovrts, resplab.range(1), cp(1), cfg.lab_landmarks_zcsnap(1) );
									fig_update();
								end
							case hdet2
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.vo = snap( ovrts, resplab.range(1), cp(1), cfg.lab_landmarks_zcsnap(2) );
									fig_update();
								end
							case hdet3
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.vr = snap( ovrts, resplab.range(1), cp(1), cfg.lab_landmarks_zcsnap(3) );
									fig_update();
								end
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

	done = false; % init flags
	logscale = false;

	while ~done

			% prepare data
		trial = trials(itrial);
		resplab = trial.resplab;

		ovrr = dsp.sec2smp( resplab.range, run.audiorate ) + [1, 0]; % ranges

		respr = dsp.sec2smp( [resplab.bo, resplab.range(2)], run.audiorate ) + [1, 0];
		fresp = ~any( isnan( respr ) );

		det1r = dsp.sec2smp( resplab.bo + cfg.lab_landmarks_det1, run.audiorate ) + [1, 0];
		det1r(det1r < 1) = 1;
		det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet1 = ~any( isnan( det1r ) );

		det2r = dsp.sec2smp( resplab.vo + cfg.lab_landmarks_det2, run.audiorate ) + [1, 0];
		det2r(det2r < 1) = 1;
		det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet2 = ~any( isnan( det2r ) );

		det3r = dsp.sec2smp( resplab.vr + cfg.lab_landmarks_det3, run.audiorate ) + [1, 0];
		det3r(det3r < 1) = 1;
		det3r(det3r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet3 = ~any( isnan( det3r ) );

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals
		dc = mean( ovrts );
		ovrts = ovrts - dc;

		respts = [];
		if fresp
			respts = run.audiodata(respr(1):respr(2), 1) - dc;
		end

		det1ts = [];
		if fdet1
			det1ts = run.audiodata(det1r(1):det1r(2), 1) - dc;
		end

		det2ts = [];
		if fdet2
			det2ts = run.audiodata(det2r(1):det2r(2), 1) - dc;
		end

		det3ts = [];
		if fdet3
			det3ts = run.audiodata(det3r(1):det3r(2), 1) - dc;
		end

		if ~logscale % axes
			yl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 );
		else
			yl = [min( scale( ovrts, logscale ) ), max( scale( ovrts, logscale ) )];
			yl(2) = yl(1) + diff( yl ) * (1 + (style.scale( 1/2 ) - 1) / 2);
		end

			% plot
		clf( fig );

		set( fig, 'Color', figcol );
		if ~is_labeled( trial )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		hovr = subplot( 4, 3, [1, 3], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} ); % overview
		title( sprintf( 'LABEL_LANDMARKS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ) );
		xlabel( 'trial time in milliseconds' );
		ylabel( 'landmarks' );

		xlim( (resplab.range - trial.range(1)) * 1000 );
		ylim( yl );

		plot_landmarks( trial, yl ); % landmarks

		stairs( ... % signal
			(dsp.smp2sec( (ovrr(1):ovrr(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
			scale( [ovrts; ovrts(end)], logscale ), ...
			'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
			'Color', style.color( 'cold', -1 ) );

		hdet1 = NaN; % detail #1 (burst onset)
		if fdet1
			hdet1 = subplot( 4, 3, [4, 7], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'burst onset detail' );

			xlim( (resplab.bo + cfg.lab_landmarks_det1 - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det1r(1):det1r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det1ts; det1ts(end)], logscale ), ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'cold', -1 ) );
		end

		hdet2 = NaN; % detail #2 (voice onset)
		if fdet2
			hdet2 = subplot( 4, 3, [5, 8], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'voice onset detail' );

			xlim( (resplab.vo + cfg.lab_landmarks_det2 - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det2r(1):det2r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det2ts; det2ts(end)], logscale ), ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'cold', -1 ) );
		end

		hdet3 = NaN; % detail #3 (voice release)
		if fdet3
			hdet3 = subplot( 4, 3, [6, 9], 'ButtonDownFcn', {@fig_dispatch, 'buttondown'} );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'voice release detail' );

			xlim( (resplab.vr + cfg.lab_landmarks_det3 - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det3r(1):det3r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det3ts; det3ts(end)], logscale ), ...
				'ButtonDownFcn', {@fig_dispatch, 'buttondown'}, ...
				'Color', style.color( 'cold', -1 ) );
		end

		s = { ... % manual labels
			'MANUAL LABELS', ...
			'', ...
			sprintf( 'class: ''%s''', resplab.label ), ...
			sprintf( 'activity: [%.1f, %.1f]', (resplab.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (resplab.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (resplab.vo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice release: %.1f', (resplab.vr - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (resplab.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (resplab.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (resplab.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [0/3, 0, 1/3, 1/4], 'String', s );

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
			'SHIFT+BACKSPACE: clear trial mode labels', ...
			'SHIFT+CONTROL+BACKSPACE: clear run mode labels', ...
			'', ...
			'ESCAPE: save and quit' };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s );

		s = { ... % mode commands
			'MODE COMMANDS', ...
			'', ...
			'L: set landmarks (3 clicks, RETURN cancels)', ...
			'', ...
			'B: set burst onset (1 click, RETURN cancels)', ...
			'V: set voice onset (1 click, RETURN cancels)', ...
			'R: set voice release (1 click, RETURN cancels)', ...
			'', ...
			'LEFT: detail landmark', ...
			'', ...
			'SHIFT+RETURN: playback from burst' };

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

