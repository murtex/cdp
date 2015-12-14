function formants( run, cfg )
% formants labeling tool
%
% FORMANTS( run, cfg )
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

		% helpers
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

		% init
	logger = xis.hLogger.instance(); % start logging
	logger.tab( 'formants labeling tool...' );

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
	fredo = true;
	fdet = false;
	flog = false;
	fblend = false;

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );
	figcol = get( fig, 'Color' );

	set( fig, 'WindowKeyPressFcn', {@disp_commands, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@disp_commands, 'close'} );

		% event dispatching
	function disp_commands( src, event, type )

			% default callback
		[flags, itrial] = cdf.audit.disp_commands( src, event, type, ...
			run, cfg, trial, [false, fdone, fredo, fdet, flog], ...
			itrial, ntrials, ...
			ovrts );

		fdone = flags(2);
		fredo = flags(3);
		fdet = flags(4);
		flog = flags(5);

			% mode callback
		if flags(1) % fproc
			return;
		end

		if fdet
			return;
		end

		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'space' % trial browsing
						if nmods == 0
							itrial = next_unlabeled( trials, itrial );
							fredo = cdf.audit.disp_update( fig, true );
						end

					case 'f' % formants setting
						if nmods == 0
							[x, y] = ginput( 3 );
							if numel( y ) > 0 && y(1) >= cfg.formants_fx_freqband(1) && y(1) <= cfg.formants_fx_freqband(2)
								resplab.f1(1) = trial.range(1) + x(1) / 1000;
								resplab.f1(2) = y(1);
							end
							if numel( y ) > 1 && y(2) >= cfg.formants_fx_freqband(1) && y(2) <= cfg.formants_fx_freqband(2)
								resplab.f2(1) = trial.range(1) + x(2) / 1000;
								resplab.f2(2) = y(2);
							end
							if numel( y ) > 2 && y(3) >= cfg.formants_fx_freqband(1) && y(3) <= cfg.formants_fx_freqband(2)
								resplab.f3(1) = trial.range(1) + x(3) / 1000;
								resplab.f3(2) = y(3);
							end
							fredo = cdf.audit.disp_update( fig, false );
						end
					case '1'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.formants_fx_freqband(1) && y(1) <= cfg.formants_fx_freqband(2)
								resplab.f1(1) = trial.range(1) + x(1) / 1000;
								resplab.f1(2) = y(1);
							end
							fredo = cdf.audit.disp_update( fig, false );
						end
					case '2'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.formants_fx_freqband(1) && y(1) <= cfg.formants_fx_freqband(2)
								resplab.f2(1) = trial.range(1) + x(1) / 1000;
								resplab.f2(2) = y(1);
							end
							fredo = cdf.audit.disp_update( fig, false );
						end
					case '3'
						if nmods == 0
							[x, y] = ginput( 1 );
							if numel( y ) > 0 && y(1) >= cfg.formants_fx_freqband(1) && y(1) <= cfg.formants_fx_freqband(2)
								resplab.f3(1) = trial.range(1) + x(1) / 1000;
								resplab.f3(2) = y(1);
							end
							fredo = cdf.audit.disp_update( fig, false );
						end

					case 'backspace' % clearing
						if nmods == 1 && strcmp( event.Modifier, 'control' ) % clear trial
							resplab.f0 = [NaN, NaN];
							resplab.f1 = [NaN, NaN];
							resplab.f2 = [NaN, NaN];
							resplab.f3 = [NaN, NaN];
							fredo = cdf.audit.disp_update( fig, false );
						elseif nmods == 3 && any( strcmp( event.Modifier, 'shift' ) ) ... % clear run (valids only)
								&& any( strcmp( event.Modifier, 'control' ) )  && any( strcmp( event.Modifier, 'alt' ) )
							for i = 1:ntrials
								trials(i).resplab.f0 = [NaN, NaN];
								trials(i).resplab.f1 = [NaN, NaN];
								trials(i).resplab.f2 = [NaN, NaN];
								trials(i).resplab.f3 = [NaN, NaN];
							end
							itrial = 1;
							fredo = cdf.audit.disp_update( fig, true );
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
						if cp(3) >= cfg.formants_f0_freqband(1) && cp(3) <= cfg.formants_f0_freqband(2)
							resplab.f0(1) = trial.range(1) + cp(1) / 1000;
							resplab.f0(2) = cp(3);
							fredo = cdf.audit.disp_update( fig, false );
						end
				end

		end
	end

		% interaction loop
	while ~fdone
		trial = trials(itrial);
		resplab = trial.resplab;

			% plot
		clf( fig ); % clear figure

		set( fig, 'Pointer', 'watch' ); % set watch pointer, TODO: drawnow causes flickering!
		drawnow( 'expose' );

		set( fig, 'Color', figcol ); % indicate unlabeled trial
		if ~is_labeled( trial ) && ~fdet
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		ovrts = cdf.audit.plot_formants( ... % plot spectrograms
			run, cfg, trial, [fredo, fdet, flog, fblend], ...
			sprintf( 'FORMANTS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );
			
		if ~fdet % plot info and commands
			cdf.audit.plot_info( trial, false );
			cdf.audit.plot_commands( false );
			cdf.label.plot_commands( 'formants' );
		end

			% wait for figure update
		set( fig, 'Pointer', 'arrow' );

		waitfor( fig, 'Clipping' ); % (unused) clipping property change

	end

		% logging
	logger.log( 'unlabeled trials: %d', sum( ~is_labeled( trials ) ) );

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

