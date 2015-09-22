function read_trials( run, trialfile )
% read trial data
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
	logger.tab( 'read trial data (''%s'')...', trialfile );
	
		% read file content
	f = fopen( trialfile );
	fdata = textscan( f, ...
		'%n %n %s %s %s %s %n %n %n %n %s %s %s %n %*[^\n]', ... % 14 fields
		'Delimiter', ',' ); % comma separated
	fclose( f );

	if size( fdata, 1 ) ~= 1 || size( fdata, 2 ) ~= 14 % single block, 14 fields
		logger.untab();
		error( 'invalid value: fdata' );
	end

	ntrials = numel( fdata{1} );
	logger.log( 'trials: %d', ntrials );

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

		% setup general
	run.sex = fdata{3}{1};
	run.age = fdata{2}(1);

		% setup trials
	run.trials(ntrials) = cdf.hTrial(); % pre-allocation

	for i = ntrials:-1:1
		trial = run.trials(i);

			% responses
		trial.resplab = cdf.hResponse();
		trial.respdet = cdf.hResponse();

			% experimental features
		trial.soa = fdata{14}(i);
		trial.vot = distvot( fdata{13}{i} );

			% general
		trial.cue = max( fdata{9}(i), fdata{10}(i) ); % cue/distractor fields have swapped during experiments
		trial.dist = trial.cue + trial.soa;

		trial.range(1) = trial.cue;
		if i < ntrials
			trial.range(2) = run.trials(i+1).range(1);
		else
			trial.range(2) = dsp.smp2sec( run.audiosize(1), run.audiorate );
		end

		trial.cuelabel = cuelabel( fdata{11}{i}, fdata{6}{i} );
		trial.distlabel = distlabel( fdata{12}{i}, fdata{13}{i} );

	end

	logger.untab();
end

