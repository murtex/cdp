function read_psych( run, psychfile )
% read raw psychtoolbox data
%
% READ_PSYCH( run, psychfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% psychfile : psychtoolbox log filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( psychfile ) || ~ischar( psychfile )
		error( 'invalid argument: psychfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read raw psychtoolbox data (''%s'')...', psychfile );

		% read complete file content
	f = fopen( psychfile );
	
	fdata = textscan( f, ...
		'%n %n %s %s %s %n %n %s %s %n %n %n %n %n %n %*[^\n]', ... % 15 fields
		'Delimiter', ',', 'CommentStyle', '#' ); % comma-separated, #-comment

	fclose( f );

	if size( fdata, 1 ) ~= 1 || size( fdata, 2 ) ~= 15 % single block, 15 fields
		error( 'invalid value: fdata' );
	end

		% set general
	run.sex = fdata{3}{1};
	run.age = fdata{2}(1);

		% set trials
	ntrials = numel( fdata{1} );

	delete( run.trials ); % pre-allocation
	run.trials = cdf.hTrial.empty();
	run.trials(ntrials) = cdf.hTrial();

	for i = ntrials:-1:1
		trial = run.trials(i);

			% set experimental features
		trial.soa = fdata{11}(i);
		trial.vot = fdata{10}(i) / 1000;

			% set general
		trial.cue = fdata{13}(i);
		trial.dist = trial.cue + trial.soa;

		trial.cuelabel = fdata{8}{i};
		trial.distlabel = fdata{9}{i};

		trial.range(1) = trial.cue;
		if i < ntrials
			trial.range(2) = run.trials(i+1).range(1);
		else
			trial.range(2) = dsp.smp2sec( size( run.audiodata, 1 ), run.audiorate );
		end

			% pre-allocate responses
		trial.resplab = cdf.hResponse();
		trial.respdet = cdf.hResponse();

	end

		% logging
	logger.log( 'sex: %s', run.sex );
	logger.log( 'age: %d', run.age );
	logger.log( 'trials: %d', ntrials );

	logger.untab();
end

