function activity( run, cfg )
% activity auditing tool
%
% ACTIVITY( run, cfg )
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
	logger.tab( 'activity auditing tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );

	set( fig, 'WindowKeyPressFcn', {@disp_commands, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@disp_commands, 'close'} );

		% helpers
	function f = is_valid( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if any( isnan( trials(i).range ) )
				f(i) = false;
			end
		end
	end

		% event dispatcher
	function disp_commands( src, event, type )

			% default callback
		[flags, itrial] = cdf.audit.disp_commands( src, event, type, ...
			run, cfg, trial, [false, fdone, fredo, fdet, flog], ...
			itrial, ntrials );

		fdone = flags(2);
		fredo = flags(3);
		fdet = flags(4);
		flog = flags(5);

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

	itrial = 12; % DEBUG

	fdone = false; % init flags
	fredo = true;
	fdet = true; % DEBUG
	flog = false;

	while ~fdone
		trial = trials(itrial);

			% plot
		clf( fig );

		cdf.audit.plot_activity( ... % overview and details
			run, cfg, trial, [fredo, fdet, flog], ...
			sprintf( 'ACTIVITY (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );

		if ~fdet % info and commands
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

