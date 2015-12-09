function landmarks( run, cfg )
% landmarks labeling tool
%
% LANDMARKS( run, cfg )
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

	set( fig, 'WindowKeyPressFcn', {@disp_commands, 'keypress'} );
	set( fig, 'CloseRequestFcn', {@disp_commands, 'close'} );

		% helpers
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

		if flags(1) % fproc
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
							fredo = cdf.audit.disp_update( fig, true );
						end

					case 'return' % playback
						if nmods == 1 && strcmp( event.Modifier, 'shift' )
							respr = dsp.sec2smp( [resplab.bo, resplab.range(2)], run.audiorate ) + [1, 0];
							if ~any( isnan( respr ) )
								soundsc( run.audiodata(respr(1):respr(2), 1), run.audiorate );
							end
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

							fredo = cdf.audit.disp_update( fig, false );
						end
					case 'b'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.bo = x(1);
							end

							fredo = cdf.audit.disp_update( fig, false );
						end
					case 'v'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.vo = x(1);
							end

							fredo = cdf.audit.disp_update( fig, false );
						end
					case 'r'
						if nmods == 0
							[x, ~] = ginput( 1 );
							x = trial.range(1) + x / 1000;

							if numel( x ) > 0 && x(1) >= resplab.range(1) && x(1) <= resplab.range(2)
								resplab.vr = x(1);
							end

							fredo = cdf.audit.disp_update( fig, false );
						end

					case 'backspace' % clearing
						if nmods == 1 && strcmp( event.Modifier, 'control' ) % clear trial
							resplab.bo = NaN;
							resplab.vo = NaN;
							resplab.vr = NaN;
							fredo = cdf.audit.disp_update( fig, false );
						elseif nmods == 3 && any( strcmp( event.Modifier, 'shift' ) ) ... % clear run (valids only)
								&& any( strcmp( event.Modifier, 'control' ) )  && any( strcmp( event.Modifier, 'alt' ) )
							for i = 1:ntrials
								trials(i).resplab.bo = NaN;
								trials(i).resplab.vo = NaN;
								trials(i).resplab.vr = NaN;
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

				cp = trial.range(1) + get( src, 'CurrentPoint' ) / 1000;
				switch get( fig, 'SelectionType' ) % landmarks adjustment
					case 'normal'
						switch src
							case hdet1
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.bo = snap( ovrts, resplab.range(1), cp(1), cfg.landmarks_zcsnap(1) );
									fredo = cdf.audit.disp_update( fig, false );
								end
							case hdet2
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.vo = snap( ovrts, resplab.range(1), cp(1), cfg.landmarks_zcsnap(2) );
									fredo = cdf.audit.disp_update( fig, false );
								end
							case hdet3
								if cp(1) >= resplab.range(1) && cp(2) <= resplab.range(2)
									resplab.vr = snap( ovrts, resplab.range(1), cp(1), cfg.landmarks_zcsnap(3) );
									fredo = cdf.audit.disp_update( fig, false );
								end
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
	fredo = true;
	fdet = false;
	flog = false;

	while ~fdone
		trial = trials(itrial);
		resplab = trial.resplab;

			% plot
		clf( fig );

		set( fig, 'Color', figcol );
		if ~is_labeled( trial )
			set( fig, 'Color', style.color( 'signal', +2 ) );
		end

		[ovrts, hdet1, hdet2, hdet3] = cdf.audit.plot_landmarks( ... % overview and details
			run, cfg, trial, [fredo, fdet, flog], ...
			sprintf( 'LANDMARKS (trial: #%d [%d/%d])', itrials(itrial), itrial, ntrials ), ...
			{@disp_commands, 'buttondown'} );

		if ~fdet % info and commands
			cdf.audit.plot_info( trial, false );
			cdf.audit.plot_commands( false );
			cdf.label.plot_commands( 'landmarks' );
		end

			% wait for figure update
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

