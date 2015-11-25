function audit_landmarks( run, cfg )
% landmarks auditing tool
%
% AUDIT_LANDMARKS( run, cfg )
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
	logger.tab( 'landmarks auditing tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );

	set( fig, 'WindowKeyPressFcn', {@fig_dispatch, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@fig_dispatch, 'close'} );

		% helper functions
	function f = is_valid( trials ) % TODO: respdet!
		f = false( size( trials ) );
		for i = 1:numel( trials )
			if (~isempty( trials(i).resplab.label ) && ~any( isnan( trials(i).resplab.range ) )) ...
					|| (~isempty( trials(i).respdet.label ) && ~any( isnan( trials(i).respdet.range ) ))
				f(i) = true;
			end
		end
	end

	function ts = scale( ts, logscale )
		if logscale
			ts = mag2db( abs( ts ) + eps );
		end
	end

	function plot_landmarks( trial, yl, flegend )
		h1 = plot( (trial.resplab.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % manual
			'Color', style.color( 'warm', +1 ), ...
			'DisplayName', 'manual' );
		plot( (trial.resplab.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'warm', +1 ) );
		plot( (trial.resplab.vr * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'warm', +1 ) );
		h2 = plot( (trial.respdet.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % automatic
			'Color', style.color( 'signal', +1 ), ...
			'DisplayName', 'automatic' );
		plot( (trial.respdet.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (trial.respdet.vr * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'signal', +1 ) );

		if flegend % legend
			legend( [h1, h2], 'Location', 'southeast' );
		end
	end

		% event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'pagedown' % browsing
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

					case 'return' % playback
						if nmods == 0
							sound( ovrts / max( abs( ovrts ) ), run.audiorate );
						end

					case 'escape' % quit
						if nmods == 0
							done = true;
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

		% interaction loop
	trials = [run.trials]; % prepare valid trials
	itrials = 1:numel( trials );

	invalids = ~is_valid( trials );
	trials(invalids) = [];
	itrials(invalids) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	itrial = 1;

	done = false; % init flags
	logscale = false;

	while ~done

			% prepare data
		trial = trials(itrial);
		resplab = trial.resplab;
		respdet = trial.respdet;

		ovrr = dsp.sec2smp( [ ... % ranges
			min( resplab.range(1), respdet.range(1) ), ...
			max( resplab.range(2), respdet.range(2) )], run.audiorate ) + [1, 0];

		det1r = dsp.sec2smp( [...
			min( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(1), ...
			max( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(2)], run.audiorate ) + [1, 0];
		det1r(det1r < 1) = 1;
		det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet1 = ~any( isnan( det1r ) );

		det2r = dsp.sec2smp( [...
			min( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(1), ...
			max( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(2)], run.audiorate ) + [1, 0];
		det2r(det2r < 1) = 1;
		det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet2 = ~any( isnan( det2r ) );

		det3r = dsp.sec2smp( [...
			min( resplab.vr, respdet.vr ) + cfg.aud_landmarks_det3(1), ...
			max( resplab.vr, respdet.vr ) + cfg.aud_landmarks_det3(2)], run.audiorate ) + [1, 0];
		det3r(det3r < 1) = 1;
		det3r(det3r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet3 = ~any( isnan( det3r ) );

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

		det1ts = [];
		if fdet1
			det1ts = run.audiodata(det1r(1):det1r(2), 1);
		end

		det2ts = [];
		if fdet2
			det2ts = run.audiodata(det2r(1):det2r(2), 1);
		end

		det3ts = [];
		if fdet3
			det3ts = run.audiodata(det3r(1):det3r(2), 1);
		end

		if ~logscale % axes
			yl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 );
		else
			yl = [min( scale( ovrts, logscale ) ), max( scale( ovrts, logscale ) )];
			yl(2) = yl(1) + diff( yl ) * (1 + (style.scale( 1/2 ) - 1) / 2);
		end

			% plot
		clf( fig );

		hovr = subplot( 4, 3, [1, 3] ); % overview
		title( sprintf( 'AUDIT_LANDMARKS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ) );
		xlabel( 'trial time in milliseconds' );
		ylabel( 'landmarks' );

		xlim( ([...
			min( resplab.range(1), respdet.range(1) ), ...
			max( resplab.range(2), respdet.range(2) )] - trial.range(1)) * 1000 );
		ylim( yl );

		plot_landmarks( trial, yl, true ); % landmarks

		stairs( ... % signal
			(dsp.smp2sec( (ovrr(1):ovrr(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
			scale( [ovrts; ovrts(end)], logscale ), ...
			'Color', style.color( 'cold', -1 ) );

		hdet1 = NaN; % detail #1 (burst onset)
		if fdet1
			hdet1 = subplot( 4, 3, [4, 7] );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'burst onset detail' );

			xlim( ([...
				min( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(1), ...
				max( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(2)] - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl, false ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det1r(1):det1r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det1ts; det1ts(end)], logscale ), ...
				'Color', style.color( 'cold', -1 ) );
		end

		hdet2 = NaN; % detail #2 (voice onset)
		if fdet2
			hdet2 = subplot( 4, 3, [5, 8] );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'voice onset detail' );

			xlim( ([...
				min( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(1), ...
				max( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(2)] - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl, false ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det2r(1):det2r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det2ts; det2ts(end)], logscale ), ...
				'Color', style.color( 'cold', -1 ) );
		end

		hdet3 = NaN; % detail #3 (voice release)
		if fdet3
			hdet3 = subplot( 4, 3, [6, 9] );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'voice release detail' );

			xlim( ([...
				min( resplab.vr, respdet.vr ) + cfg.aud_landmarks_det3(1), ...
				max( resplab.vr, respdet.vr ) + cfg.aud_landmarks_det3(2)] - trial.range(1)) * 1000 );
			ylim( yl );

			plot_landmarks( trial, yl, false ); % landmarks

			stairs( ... % signal
				(dsp.smp2sec( (det3r(1):det3r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, ...
				scale( [det3ts; det3ts(end)], logscale ), ...
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

		s = { ... % automatic labels
			'AUTOMATIC LABELS', ...
			'', ...
			sprintf( 'class: ''%s''', respdet.label ), ...
			sprintf( 'activity: [%.1f, %.1f]', (respdet.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (respdet.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (respdet.vo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice release: %.1f', (respdet.vr - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (respdet.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (respdet.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (respdet.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (respdet.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s );

		s = { ... % general commands
			'GENERAL COMMANDS', ...
			'', ...
			'PAGEDOWN/UP: +/- 1 trial' ...
			'SHIFT+PAGEDOWN/UP: +/- 10 trials', ...
			'CONTROL+PAGEDOWN/UP: +/- 100 trials', ...
			'HOME/END: first/last trial', ...
			'', ...
			'RETURN: playback audio', ...
			'', ...
			'D: toggle decibel scale', ...
			'', ...
			'ESCAPE: quit' };

		annotation( 'textbox', [2/3, 0, 1/3, 1/4], 'String', s );

			% wait for figure update
		waitfor( fig, 'Clipping' ); % wait for (unused) clipping property change

	end

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

