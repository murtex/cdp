function formants( run, cfg )
% formants auditing tool
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

		% init
	logger = xis.hLogger.instance(); % start logging
	logger.tab( 'formants auditing tool...' );

	trials = [run.trials]; % prepare valid trials
	itrials = 1:numel( trials );

	invalids = ~is_valid( [run.trials.resplab], 'activity' ) & ~is_valid( [run.trials.respdet], 'activity' );
	trials(invalids) = [];
	itrials(invalids) = [];

	ntrials = numel( trials );
	logger.log( 'valid trials: %d', ntrials );

	if ntrials == 0
		error( 'invalid value: ntrials' );
	end

	itrial = 1;

	fdone = false; % init flags
	fredo = true;
	fdet = false;
	flog = false;
	fblend = false;

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );

	set( fig, 'WindowKeyPressFcn', {@disp_commands, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@disp_commands, 'close'} );

		% event dispatching
	function disp_commands( src, event, type )

			% default callback
		[flags, itrial] = cdf.audit.disp_commands( src, event, type, ...
			run, cfg, trial, [false, fdone, fredo, fdet, flog], ...
			itrial, ntrials, ...
			ovrts, spects );

		fdone = flags(2);
		fredo = flags(3);
		fdet = flags(4);
		flog = flags(5);

		if flags(1) % fproc
			return;
		end

	end

		% interaction loop
	while ~fdone
		trial = trials(itrial);

			% plot
		clf( fig ); % clear figure

		[ovrts, spects] = cdf.audit.plot_formants( ... % plot spectrograms
			run, cfg, trial, [fredo, fdet, flog, fblend], ...
			sprintf( 'FORMANTS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );
			
		if ~fdet % plot info and commands
			cdf.audit.plot_info( trial, true );
			cdf.audit.plot_commands( true );
		end

			% wait for figure update
		waitfor( fig, 'Clipping' ); % (unused) clipping property change

	end

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

