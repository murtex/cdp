function read_trials( run, logfile )
% read trial data
%
% READ_TRIALS( run, logfile )
%
% INPUT
% run : run (scalar object)
% logfile : log logfile (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( logfile ) || ~ischar( logfile ) || exist( logfile, 'file' ) ~= 2
		error( 'invalid argument: logfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read trials ''%s''...', logfile );

		% read logfile content
	f = fopen( logfile );
	fdata = textscan( f, ...
		'%n %n %n %s %s %s %s %n %n %n %s %s %n %n %n %n %s %*[^\n]', ... % 17 fields
		'Delimiter', ',' ); % comma separated
	fclose( f );

	if size( fdata, 1 ) ~= 1 || size( fdata, 2 ) ~= 17 % single block, 17 fields
		logger.untab();
		error( 'invalid argument: logfile' );
	end

	n = numel( fdata{1} );
	logger.log( 'trials: %d', n );

		% content parsing
	function cl = cuelabel( symbol, hashlabel )
		switch symbol
			case '##'
				cl = hashlabel;
			otherwise
				switch hashlabel
					case 'ka'
						cl = 'ta';
					otherwise
						cl = 'ka';
				end
		end
	end

	function dl = distlabel( label )
		switch label
			case 'n'
				dl = 'none';
			case 't'
				dl = 'tone';
			otherwise
				dl = label;
		end
	end

		% setup run and trials
	run.id = fdata{1}(1);

	run.trials(n) = cdf.hTrial(); % pre-allocation

	for i = 1:n
		trial = run.trials(i);

		trial.id = fdata{8}(i);

			% labels
		trial.cuelabel = cuelabel( fdata{11}{i}, fdata{7}{i} );
		trial.distlabel = distlabel( fdata{12}{i} );

			% cue/distractor
		trial.cue = 1 + dsp.sec2smp( fdata{10}(i), run.audiorate );
		trial.soa = dsp.sec2smp( fdata{13}(i), run.audiorate );

		trial.distbo = 1 + trial.cue + trial.soa;

		% range, TODO: use next first cue as range end?
		trial.range(1) = trial.cue;
		if i < n
			nextcue = 1 + dsp.sec2smp( fdata{10}(i+1), run.audiorate );
			trial.range(2) = nextcue - 1; % TODO: trial overlap?
		else
			trial.range(2) = run.audiolen; % last trial ends with audio data, TODO: possibly gets invalidated by syncing
		end

		maxlen = dsp.sec2smp( 5, run.audiorate ); % limit length to 5s (between blocks)
		if diff( trial.range )+1 > maxlen
			trial.range(2) = trial.range(1) + maxlen-1;
		end

	end

	logger.untab();
end

