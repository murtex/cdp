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
	function f = is_valid( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if any( isnan( trials(i).resplab.range ) & isnan( trials(i).respdet.range ) )
				f(i) = false;
			end
		end
	end

	function plot_landmarks( trial, yl )
		plot( (trial.resplab.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % labeled
			'Color', style.color( 'warm', +1 ) );
		plot( (trial.resplab.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'warm', +1 ) );
		plot( (trial.respdet.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % detected
			'Color', style.color( 'signal', +1 ) );
		plot( (trial.respdet.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'Color', style.color( 'signal', +1 ) );
	end

		% event dispatching
	function fig_dispatch( src, event, type )
		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'pagedown' % trial browsing
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

					case 'return' % playback
						if nmods == 0
							sound( ovrts / max( abs( ovrts ) ), run.audiorate );
						end

					case 'escape' % quit
						if nmods == 0
							done = true;
							fig_update();
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

	function fig_update()
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

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	itrial = 1;

	done = false; % init flags

	while ~done

			% prepare data
		trial = trials(itrial);
		resplab = trial.resplab;
		respdet = trial.respdet;

		ovrr = dsp.sec2smp( [ ... % ranges
			min( resplab.range(1), respdet.range(1) ), ...
			max( resplab.range(2), respdet.range(2) )], run.audiorate ) + [1, 0];

		det1r = dsp.sec2smp( [ ...
			min( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(1), ...
			max( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(2)], run.audiorate ) + [1, 0];
		det1r(det1r < 1) = 1;
		det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet1 = ~any( isnan( det1r ) );

		det2r = dsp.sec2smp( [ ...
			min( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(1), ...
			max( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(2)], run.audiorate ) + [1, 0];
		det2r(det2r < 1) = 1;
		det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );
		fdet2 = ~any( isnan( det2r ) );

		ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

		det1ts = [];
		if fdet1
			det1ts = run.audiodata(det1r(1):det1r(2), 1);
		end

		det2ts = [];
		if fdet2
			det2ts = run.audiodata(det2r(1):det2r(2), 1);
		end

			% plot
		clf( fig );

		subplot( 4, 2, [1, 2] ); % overview
		title( sprintf( 'AUDIT_LANDMARKS (trial: %d/%d)', itrial, ntrials ) );
		xlabel( 'trial time in milliseconds' );
		ylabel( 'response' );

		xlim( ([ ...
			min( resplab.range(1), respdet.range(1) ), ...
			max( resplab.range(2), respdet.range(2) )] - trial.range(1)) * 1000 );
		yl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 );
		ylim( yl );

		plot_landmarks( trial, yl ); % landmarks

		plot( (dsp.smp2sec( (ovrr(1):ovrr(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, ovrts, ... % signal
			'Color', style.color( 'cold', -1 ) );

		if fdet1 % detail #1 (burst onset)
			subplot( 4, 2, [3, 5] );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'burst onset detail' );

			xlim( ([ ...
				min( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(1)
				max( resplab.bo, respdet.bo ) + cfg.aud_landmarks_det1(2)] - trial.range(1)) * 1000 );
			yl = max( abs( det1ts ) ) * [-1, 1] * style.scale( 1/2 );
			ylim( yl );

			plot_landmarks( trial, yl ); % landmarks

			plot( (dsp.smp2sec( (det1r(1):det1r(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, det1ts, ... % signal
				'Color', style.color( 'cold', -1 ) );
		end

		if fdet2 % detail #2 (voice onset)
			subplot( 4, 2, [4, 6] );
			xlabel( 'trial time in milliseconds' );
			ylabel( 'voice onset detail' );

			xlim( ([ ...
				min( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(1)
				max( resplab.vo, respdet.vo ) + cfg.aud_landmarks_det2(2)] - trial.range(1)) * 1000 );
			yl = max( abs( det2ts ) ) * [-1, 1] * style.scale( 1/2 );
			ylim( yl );

			plot_landmarks( trial, yl ); % landmarks

			plot( (dsp.smp2sec( (det2r(1):det2r(2)) - 1, run.audiorate ) - trial.range(1)) * 1000, det2ts, ... % signal
				'Color', style.color( 'cold', -1 ) );
		end

		s = { ... % labeled response
			'LABELED RESPONSE', ...
			'', ...
			sprintf( 'class: ''%s''', resplab.label ), ...
			'', ...
			sprintf( 'activity: [%.1f, %.1f]', (resplab.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (resplab.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (resplab.vo - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (resplab.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (resplab.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (resplab.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [0, 0, 1/3, 1/4], 'String', s );

		s = { ... % detected response
			'DETECTED RESPONSE', ...
			'', ...
			sprintf( 'class: ''%s''', respdet.label ), ...
			'', ...
			sprintf( 'activity: [%.1f, %.1f]', (respdet.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (respdet.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (respdet.vo - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (respdet.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (respdet.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (respdet.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (respdet.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s );

		s = { ... % commands
			'COMMANDS', ...
			'', ...
			'PAGEDOWN/UP: +/- 1 trial' ...
			'SHIFT+PAGEDOWN/UP: +/- 10 trials', ...
			'CONTROL+PAGEDOWN/UP: +/- 100 trials', ...
			'HOME/END: first/last trial', ...
			'', ...
			'RETURN: playback audio', ...
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

