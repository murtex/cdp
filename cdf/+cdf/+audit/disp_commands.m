function [flags, itrial] = disp_commands( src, event, type, run, cfg, trial, flags, itrial, ntrials )
% dispatch commands
%
% [flags, itrial] = DISP_COMMANDS( src, event, type, run, cfg, trial, flags, itrial, ntrials )
%
% INPUT
% src : event source handle (internal)
% event : event (internal)
% type : event type [keypress | close] (row char)
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% trial : cue-distractor trial (scalar object)
% flags : flags [proc, done, log] (vector logical)
% itrial : trial number (scalar numeric)
% ntrials : number of trials (scalar numeric)
%
% OUTPUT
% flags : flags [done, log] (vector logical)
% itrial : trial number (scalar numeric)

		% safeguard
	if nargin < 1
		error( 'invalid argument: src' );
	end

	if nargin < 2
		error( 'invalid argument: event' );
	end

	if nargin < 3 || ~isrow( type ) || ~ischar( type )
		error( 'invalid argument: type' );
	end

	if nargin < 4 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 5 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 6 || ~isscalar( trial ) || ~isa( trial, 'cdf.hTrial' )
		error( 'invalid argument: trial' );
	end

	if nargin < 7 || ~isvector( flags ) || numel( flags ) ~= 3 || ~islogical( flags )
		error( 'invalid argument: flags' );
	end

	if nargin < 8 || ~isscalar( itrial ) || ~isnumeric( itrial )
		error( 'invalid argument: itrial' );
	end

	if nargin < 9 || ~isscalar( ntrials ) || ~isnumeric( ntrials )
		error( 'invalid argument: ntrials' );
	end

		% dispatch events
	switch type

			% key presses
		case 'keypress'
			nmods = size( event.Modifier, 2 );

			switch event.Key

				case 'pagedown' % trial browsing
					if nmods == 0 || (nmods == 1 && ...
							(any( strcmp( event.Modifier, 'shift' ) ) || any( strcmp( event.Modifier, 'control' ) )))
						flags(1) = true; % processed

						step = 1; % step size
						if strcmp( event.Modifier, 'shift' )
							step = 10;
						elseif strcmp( event.Modifier, 'control' )
							step = 100;
						end

						iptrial = min( itrial + step, ntrials ); % update trial number
						if iptrial ~= itrial
							itrial = iptrial;
							cdf.audit.disp_update( src );
						end
					end
				case 'pageup'
					if nmods == 0 || (nmods == 1 && ...
							(any( strcmp( event.Modifier, 'shift' ) ) || any( strcmp( event.Modifier, 'control' ) )))
						flags(1) = true; % processed

						step = 1; % step size
						if strcmp( event.Modifier, 'shift' )
							step = 10;
						elseif strcmp( event.Modifier, 'control' )
							step = 100;
						end

						iptrial = max( itrial - step, 1 ); % update trial number
						if iptrial ~= itrial
							itrial = iptrial;
							cdf.audit.disp_update( src );
						end
					end
				case 'home'
					if nmods == 0
						flags(1) = true; % processed

						if itrial ~= 1 % update trial number
							itrial = 1;
							cdf.audit.disp_update( src );
						end
					end
				case 'end'
					if nmods == 0
						flags(1) = true; % processed

						if itrial ~= ntrials % update trial number
							itrial = ntrials;
							cdf.audit.disp_update( src );
						end
					end

				case 'return' % audio playback
					if nmods == 0
						flags(1) = true; % processed

						ovrr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % play overview
						ovrts = run.audiodata(ovrr(1):ovrr(2), 1);
						soundsc( ovrts, run.audiorate );
					end

				case 's' % axis scaling
					if nmods == 0
						flags(1) = true; % processed

						flags(3) = ~flags(3); % toggle log scale
						cdf.audit.disp_update( src );
					end

				case 'escape' % figure closing
					if nmods == 0
						flags(1) = true; % processed

						flags(2) = true; % done
						cdf.audit.disp_update( src );
					end

			end

			% figure closing
		case 'close'
			flags(1) = true; % processed

			flags(2) = true; % done
			delete( src );

	end

end

