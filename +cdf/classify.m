function classify( runs, classes, forest );
% classify labels
%
% CLASSIFY( runs, classes, forest )
%
% INPUT
% runs : runs (row object)
% classes : class labels (cell row char)
% forest : tree root nodes (row object)

		% safeguard
	if nargin < 1 || ~isrow( runs ) || ~isa( runs(1), 'cdf.hRun' )
		error( 'invalid arguments: run' );
	end

	if nargin < 2 || ~isrow( classes ) || numel( classes ) < 2
		error( 'invalida argument: classes' );
	end

	if nargin < 3 || ~isrow( forest) || ~isa( forest(1), 'brf.hNode' )
		error( 'invalid argument: forest' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'classify data...' );

		% convert forest for mex-file usage
	logger.tab( 'convert forest...' );

	wstate = warning( 'query', 'all' );
	warning( 'off', 'all' );
	mexforest = forest.mexify(); % conversion
	warning( wstate );

	logger.untab();

		% proceed runs
	nruns = numel( runs );

	hits = zeros( 1, nruns ); % pre-allocation
	misses = zeros( 1, nruns );

	for i = 1:nruns
		logger.tab( 'subject: %d', runs(i).id );

			% proceed trials
		m = numel( runs(i).trials );

		logger.progress();
		for j = 1:m

				% skip unfeatured data
			featfile = runs(i).trials(j).detected.featfile;
			if isempty( featfile )
				continue;
			end

				% read and classify subsequences
			load( featfile, 'subfeat' );

			labels = brf.classify( mexforest, subfeat );

			labels = mode( labels, 1 ); % majority vote

				% set detected label
			runs(i).trials(j).detected.label = classes{mode( labels )}; % TODO: equal frequencies?!

			if ~isempty( runs(i).trials(j).labeled.label )
				if strcmp( runs(i).trials(j).detected.label, runs(i).trials(j).labeled.label )
					hits(i) = hits(i) + 1;
				else
					misses(i) = misses(i) + 1;
				end
			end

			logger.progress( j, m );
		end

		logger.log( 'error: %.2f%%', 100 * misses(i) / (hits(i)+misses(i)) );

		logger.untab();
	end

	logger.log( 'error: %.2f%%', 100 * sum( misses ) / (sum( hits )+sum( misses )) );

	logger.untab();
end

