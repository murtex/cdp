function read_trials( run, trialfile )
% read raw trial data
%
% READ_TRIALS( run, trialfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% trialfile : trial filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( trialfile ) || ~ischar( trialfile )
		error( 'invalid argument: trialfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read raw trial data (''%s'')...', trialfile );
	
		% read file content
	f = fopen( trialfile );

	fdata = textscan( f, ...
		'%n %n %s %s %s %s %n %n %n %n %s %s %s %n %*[^\n]', ... % 14 fields
		'Delimiter', ',' ); % comma separated

	fclose( f );

	if size( fdata, 1 ) ~= 1 || size( fdata, 2 ) ~= 14 % single block, 14 fields
		error( 'invalid value: fdata' );
	end

	ntrials = numel( fdata{1} );

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

	function dl = distlabel( label, vot )
		switch vot
			case 'n'
				dl = 'none';
			case 't'
				dl = 'tone';
			otherwise
				dl = label;
		end
	end

	function dv = distvot( vot )
		switch vot
			case 'n'
				dv = NaN;
			case 't'
				dv = NaN;
			otherwise
				dv = str2double( vot );
		end
	end

		% set general
	run.sex = fdata{3}{1};
	run.age = fdata{2}(1);

		% setup trials
	delete( run.trials ); % pre-allocation
	run.trials = cdf.hTrial.empty();
	run.trials(ntrials) = cdf.hTrial();

	for i = ntrials:-1:1
		trial = run.trials(i);

			% set conditions
		trial.soa = fdata{14}(i);
		trial.vot = distvot( fdata{13}{i} );

			% set general
		trial.cue = max( fdata{9}(i), fdata{10}(i) ); % cue/distractor fields have swapped during experiments
		trial.dist = trial.cue + trial.soa;

		trial.cuelabel = cuelabel( fdata{11}{i}, fdata{6}{i} );
		trial.distlabel = distlabel( fdata{12}{i}, fdata{13}{i} );
		
		trial.range(1) = trial.cue;
		if i < ntrials
			trial.range(2) = run.trials(i+1).range(1);
		else
			trial.range(2) = dsp.smp2sec( size( run.audiodata, 1 ), run.audiorate );
		end

			% prepare (empty) responses
		trial.resplab = cdf.hResponse();
		trial.respdet = cdf.hResponse();

	end

		% logging
	logger.log( 'sex: ''%s''', run.sex );
	logger.log( 'age: %d', run.age );
	logger.log( 'trials: %d', ntrials );

	logger.untab();
end

