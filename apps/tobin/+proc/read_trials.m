function read_trials( run, trialdir )
% read raw trials data
%
% READ_TRIALS( run, trialdir )
%
% INPUT
% run : cue-distractor run (scalar object)
% trialdir : trial directory (raw wave audio directory) (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( trialdir ) || ~ischar( trialdir )
		error( 'invalid argument: trialdir' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read raw trial data (''%s'')...', trialdir );

		% proceed audio files
	flist = dir( fullfile( trialdir, '*.wav' ) );

	ntrials = numel( flist );

	delete( run.trials ); % pre-allocation
	run.trials = cdf.hTrial.empty();
	run.trials(ntrials) = cdf.hTrial();

	for i = 1:ntrials
		trial = run.trials(i);

			% read audio data
		audiofile = fullfile( trialdir, flist(i).name );

		if exist( 'audioread' )
			[audiodata, audiorate] = audioread( audiofile );
		else
			[audiodata, audiorate] = wavread( audiofile );
		end

			% set general
		if i == 1
			trial.range(1) = 0;
		else
			trial.range(1) = run.trials(i-1).range(2);
		end
		trial.range(2) = trial.range(1) + dsp.smp2sec( numel( audiodata ), audiorate );

		trial.cue = trial.range(1); % used for noise estimation
		trial.dist = trial.cue + 0.05;

		[~, trial.cuelabel, ~] = fileparts( audiofile ); % keep that information

			% prepare/set responses
		trial.resplab = cdf.hResponse();
		trial.respdet = cdf.hResponse();

		trial.resplab.range = trial.range;
		trial.resplab.label = trial.cuelabel;

	end

		% logging
	logger.log( 'sex: ''%s''', run.sex );
	logger.log( 'age: %d', run.age );
	logger.log( 'trials: %d', ntrials );

	logger.untab();
end


