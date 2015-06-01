function classify( run, classes, forest, labeled );
% classify labels
%
% CLASSIFY( run, classes, forest )
%
% INPUT
% run : run (scalar object)
% classes : class labels (cell row char)
% forest : trees (row struct)
% DEBUG: labeled : classify labeled features (scalar logical)

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

	if nargin < 4 || ~isscalar( labeled ) || ~islogical( labeled )
		error( 'invalid argument: labeled' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'classify data...' );

		% proceed trials
	n = numel( run.trials );

	ntrees = numel( forest );
	nclasses = numel( classes );

	tlabels = NaN( ntrees, 1 ); % pre-allocation
	classoccs = zeros( nclasses, 1 );

	logger.progress();
	for i = 1:n

			% reset label
		trial = run.trials(i);

		trial.detected.label = '';

		if labeled
			featfile = trial.labeled.featfile;
		else
			featfile = trial.detected.featfile;
		end

		if isempty( featfile )
			logger.progress( i, n );
			continue;
		end

			% read and classify subsequences
		load( featfile, 'subfeat' );

		labels = brf.classify( forest, subfeat );

			% set majority vote
		for j = 1:ntrees

			for k = 1:nclasses
				classoccs(k) = sum( labels(j, :) == k );
			end

			label = find( classoccs == max( classoccs ) );
			if numel( label ) > 1
				label = randsample( label, 1 ); % random majority
			end

			tlabels(j) = label; % subsequence majority

		end

		for j = 1:nclasses
			classoccs(j) = sum( tlabels == j );
		end

		label = find( classoccs == max( classoccs ) );
		if numel( label ) > 1
			label = randsample( label, 1 ); % random majority
		end

			% set detected label
		trial.detected.label = classes{label}; % forest majority

		logger.progress( i, n );
	end

	logger.untab();
end

