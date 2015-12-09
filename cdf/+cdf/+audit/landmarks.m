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

	set( fig, 'WindowKeyPressFcn', {@disp_commands, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@disp_commands, 'close'} );

		% helper functions
	function f = is_valid( trials )
		f = false( size( trials ) );
		for i = 1:numel( trials )
			if (~isempty( trials(i).resplab.label ) && ~any( isnan( trials(i).resplab.range ) )) ...
					|| (~isempty( trials(i).respdet.label ) && ~any( isnan( trials(i).respdet.range ) ))
				f(i) = true;
			end
		end
	end

		% event dispatching
	function disp_commands( src, event, type )

			% default callback
		[flags, itrial] = cdf.audit.disp_commands( src, event, type, ...
			run, cfg, trial, [false, fdone, flog], ...
			itrial, ntrials );

		fdone = flags(2);
		flog = flags(3);

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

	fdone = false; % init flags
	flog = false;

	while ~fdone
		trial = trials(itrial);

			% plot
		clf( fig );

		cdf.audit.plot_landmarks( ... % overview and details
			run, cfg, trial, [flog], ...
			sprintf( 'AUDIT_LANDMARKS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );

		cdf.audit.plot_info( trial, true ); % info and commands
		cdf.audit.plot_commands( true );

			% wait for figure update
		waitfor( fig, 'Clipping' ); % wait for (unused) clipping property change

	end

		% exit
	if ishandle( fig )
		delete( fig );
	end

	logger.untab(); % stop logging

end

