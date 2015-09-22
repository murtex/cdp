function read_labels( run, labelfile )
% read label data
%
% READ_LABELS( run, labelfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% labelfile : label filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( labelfile ) || ~ischar( labelfile )
		error( 'invalid argument: labelfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read label data (''%s'')...', labelfile );

		% read file content
	ntrials = numel( run.trials );

	[~, ~, fdata] = xlsread( labelfile );
	fdata(1, :) = []; % remove header

	if size( fdata, 1 ) ~= ntrials || size( fdata, 2 ) ~= 14
		logger.untab();
		error( 'invalid value: fdata' );
	end

		% setup responses
	nlabtrials = 0;

	for i = 1:ntrials
		trial = run.trials(i);
		resp = trial.resplab;

			% skip unlabeled/unreasonable data
		resplabel = fdata{i, 7};
		if strcmp( resplabel, 'NA' )
			continue;
		end

		if fdata{i, 8} > 10 || fdata{i, 9} > 1 || fdata{i, 10} > 10 || ...
				fdata{i, 8} < 0 || fdata{i, 9} < 0 || fdata{i, 10} < 0
			% reaction time, voice-onset time, vowel length in seconds
			continue;
		end

		nlabtrials = nlabtrials + 1;

			% activity
		resp.range(1) = trial.cue + fdata{i, 8};
		resp.range(2) = resp.range(1) + fdata{i, 9} + fdata{i, 10};

			% landmarks
		resp.bo = resp.range(1);
		resp.vo = resp.range(1) + fdata{i, 9};
		resp.vr = resp.range(2);

			% formants, TODO!

			% classification
		resp.label = resplabel;

	end

		% logging
	logger.log( 'trials: %d', nlabtrials );

	logger.untab();
end

