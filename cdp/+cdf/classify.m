function cumlabels = classify( run, classes, forest )
% classify sublabels
%
% cumlabels = CLASSIFY( run, classes, forest )
%
% INPUT
% run : run (scalar object)
% classes : class sublabels (cell row char)
% forest : trees (row struct)
%
% OUTPUT
% cumlabels : cumulative labels (matrix numeric)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid arguments: run' );
	end

	if nargin < 2 || ~isrow( classes ) || numel( classes ) < 2
		error( 'invalida argument: classes' );
	end

	if nargin < 3 || ~isrow( forest) % no type check!
		error( 'invalid argument: forest' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'classify data...' );

		% proceed trials
	n = numel( run.trials );

	ntrees = numel( forest );
	nclasses = numel( classes );

	cumlabels = NaN( ntrees, n ); % pre-allocation

	logger.progress();
	for i = 1:n

			% reset label
		trial = run.trials(i);

		trial.detected.label = '';

		if isempty( trial.detected.featfile )
			logger.progress( i, n );
			continue;
		end

			% read and classify subsequences
		load( trial.detected.featfile, 'subfeat' );

		sublabels = brf.classify( forest, subfeat );

			% vote for majority
		majlabels = NaN( 1, ntrees ); % pre-allocation
		classoccs = zeros( 1, nclasses );

		for j = 1:ntrees % tree majorities
			for k = 1:nclasses
				classoccs(k) = sum( sublabels(j, :) == k );
			end
			majlabel = find( classoccs == max( classoccs ) );
			if numel( majlabel ) > 1
				majlabel = randsample( majlabel, 1 ); % random majority
			end
			majlabels(j) = majlabel;
		end

		for j = 1:ntrees % cumulative majorities
			for k = 1:nclasses
				classoccs(k) = sum( majlabels(1:j) == k );
			end
			cumlabel = find( classoccs == max( classoccs ) );
			if numel( cumlabel ) > 1
				cumlabel = randsample( cumlabel, 1 ); % random majority
			end
			cumlabels(j, i) = cumlabel;
		end

			% set detected label
		trial.detected.label = classes{cumlabels(ntrees, i)};

		logger.progress( i, n );
	end

	logger.untab();
end

