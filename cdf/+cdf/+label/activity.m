function label_activity( run, cfg )
% activity labeling tool
%
% LABEL_ACTIVITY( run, cfg )
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
	logger.tab( 'activity labeling tool...' );

	style = xis.hStyle.instance(); % prepare interactive figure

	fig = style.figure( 'Visible', 'on' );
	figcol = get( fig, 'Color' );

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

	function f = is_labeled( trials )
		f = true( size( trials ) );
		for i = 1:numel( trials )
			if isempty( trials(i).resplab.label ) || any( isnan( trials(i).resplab.range ) )
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

		% event dispatcher
	function disp_commands( src, event, type )

			% default callback
		[flags, itrial] = cdf.audit.disp_commands( src, event, type, ...
			run, cfg, trial, [false, fdone, flog], ...
			itrial, ntrials );

		fdone = flags(2);
		flog = flags(3);

		if flags(1) % processed
			return;
		end

			% mode callback
		switch type

				% key presses
			case 'keypress'
				nmods = size( event.Modifier, 2 );

				switch event.Key

					case 'space' % trial browsing
						if nmods == 0
							itrial = next_unlabeled( trials, itrial );
							cdf.audit.disp_update( fig );
						end

					case 'return' % playback
						if nmods == 1 && strcmp( event.Modifier, 'shift' ) && fresp
							soundsc( respts, run.audiorate );
						end

					case 'k' % class setting
						if nmods == 0
							trial.resplab.label = 'ka';
							cdf.audit.disp_update( fig );
						end
					case 't'
						if nmods == 0
							trial.resplab.label = 'ta';
							cdf.audit.disp_update( fig );
						end

					case 'backspace' % clearing
						if nmods == 1 && strcmp( event.Modifier, 'control' ) % clear trial
							resplab.label = '';
							resplab.range = [NaN, NaN];
							cdf.audit.disp_update( fig );
						elseif nmods == 3 && any( strcmp( event.Modifier, 'shift' ) ) ... % clear run (valids only)
								&& any( strcmp( event.Modifier, 'control' ) )  && any( strcmp( event.Modifier, 'alt' ) )
							for i = 1:ntrials
								trials(i).resplab.label = '';
								trials(i).resplab.range = [NaN, NaN];
							end
							itrial = 1;
							cdf.audit.disp_update( fig );
						end

				end

				% button presses
			case 'buttondown'
				while ~strcmp( get( src, 'Type' ), 'axes' ) % get parent axis
					src = get( src, 'Parent' );
				end

				cp = trial.range(1) + get( src, 'CurrentPoint' ) / 1000; % activity setting
				switch get( fig, 'SelectionType' )
					case 'normal'
						if cp(1) >= trial.range(1) && cp(2) <= trial.range(2)
							ovrr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0];
							ovrts = run.audiodata(ovrr(1):ovrr(2), 1);
							resplab.range(1) = snap( ovrts, trial.range(1), cp(1), cfg.activity_zcsnap(1) );
							cdf.audit.disp_update( fig );
						end
					case 'alt'
						if cp(1) >= trial.range(1) && cp(2) <= trial.range(2)
							ovrr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0];
							ovrts = run.audiodata(ovrr(1):ovrr(2), 1);
							resplab.range(2) = snap( ovrts, trial.range(1), cp(1), cfg.activity_zcsnap(2) );
							cdf.audit.disp_update( fig );
						end
				end

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

	fdone = false; % init flags
	flog = false;

	while ~fdone

			% prepare data
		trial = trials(itrial);
		resplab = trial.resplab;

		respr = dsp.sec2smp( resplab.range, run.audiorate ) + [1, 0]; % ranges
		fresp = ~any( isnan( respr ) );

		respts = []; % signals
		if fresp
			respts = run.audiodata(respr(1):respr(2), 1);
		end

			% plot
		clf( fig );

		set( fig, 'Color', figcol );
		if ~is_labeled( trial )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		cdf.audit.plot_activity( ... % overview and details
			run, cfg, trial, [flog], ...
			sprintf( 'LABEL_ACTIVITY (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );

		cdf.audit.plot_info( trial, false ); % info and commands
		cdf.audit.plot_commands( false );
		cdf.label.plot_commands( 'activity' );

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

