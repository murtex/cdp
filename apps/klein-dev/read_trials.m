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

		% setup trials
	run.trials(ntrials) = cdf.hTrial(); % pre-allocation
	run.resps_det(ntrials) = cdf.hResponse();
	run.resps_lab(ntrials) = cdf.hResponse();

	for i = ntrials:-1:1
		trial = run.trials(i);

			% general
		trial.cuepos = max( fdata{9}(i), fdata{10}(i) ); % cue/distractor fields have swapped during experiments
		trial.distpos = max( fdata{9}(i), fdata{10}(i) ) + fdata{14}(i);

		trial.cuelabel = cuelabel( fdata{11}{i}, fdata{6}{i} );
		trial.distlabel = distlabel( fdata{12}{i}, fdata{13}{i} );

			% experimental features
		trial.distsoa = fdata{14}(i);
		trial.distvot = distvot( fdata{13}{i} );

	end

	logger.untab();
end

