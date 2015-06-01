function read_labels( run, labelfile )
% read label data
%
% READ_LABELS( run, labelfile )
%
% INPUT
% run : run (scalar object)
% labelfile : label filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( labelfile ) || ~ischar( labelfile ) || exist( labelfile, 'file' ) ~= 2
		error( 'invalid argument: labelfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read labels ''%s''...', labelfile );

		% read labelfile content
	n = numel( run.trials );

	[~, ~, fdata] = xlsread( labelfile );
	fdata(1, :) = []; % remove header

	if size( fdata, 1 ) ~= n || size( fdata, 2 ) ~= 14 % n trials, 14 fields
		logger.untab();
		error( 'invalid argument: labelfile' );
	end

		% setup trials
	valids = 0;

	for i = 1:n

		rl = fdata{i, 7}; % skip unlabeled
		if strcmp( rl, 'NA' )
			continue;
		end

		if fdata{i, 8} > 10 || fdata{i, 9} > 1 || fdata{i, 10} > 10 % skip unreasonables (typos)
			% reaction time, voice-onset time, vowel length in seconds
			continue;
		end

			% response
		run.trials(i).labeled.label = rl;

		run.trials(i).labeled.bo = run.trials(i).cue + sta.sec2smp( fdata{i, 8}, run.audiorate );
		run.trials(i).labeled.vo = run.trials(i).labeled.bo + sta.sec2smp( fdata{i, 9}, run.audiorate );
		run.trials(i).labeled.vr = run.trials(i).labeled.vo + sta.sec2smp( fdata{i, 10}, run.audiorate );

		run.trials(i).labeled.range = [run.trials(i).labeled.bo, run.trials(i).labeled.vr];

		valids = valids + 1;
	end

	logger.log( 'trials: %d/%d', valids, n );

	logger.untab();
end

