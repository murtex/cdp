function classify( runs, forest, labeled )
% classify labels
%
% CLASSIFY( runs, forest, labeled )
%
% INPUT
% runs : runs (row object)
% forest : tree root nodes (row object)
% labeled : use labeled response features (scalar logical)

		% safeguard
	if nargin < 1 || ~isrow( runs ) || ~isa( runs(1), 'cdf.hRun' )
		error( 'invalid arguments: run' );
	end

	if nargin < 2 || ~isrow( forest) || ~isa( forest(1), 'brf.hNode' )
		error( 'invalid argument: forest' );
	end

	if nargin < 3 || ~isscalar( labeled ) || ~islogical( labeled )
		error( 'invalid argument: labeled' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'classify data...' );

		% read subsequence dataset
	logger.tab( 'read subsequence dataset...' );

	nruns = numel( runs );

	subs = []; % pre-allocation
	labels = [];

	logger.progress();
	for i = 1:nruns

			% proceed trials
		m = numel( runs(i).trials );
		for j = 1:m

				% skip unfeatured data
			if labeled
				featfile = runs(i).trials(j).labeled.featfile;
			else
				featfile = runs(i).trials(j).detected.featfile;
			end

			if isempty( featfile )
				continue;
			end

				% read subsequences
			load( featfile, 'subfeat' );

			subs(end+1:end+size( subfeat, 1), :) = subfeat;

		end

		logger.progress( i, nruns );
	end

	logger.untab();

		% classify subsequences
	brf.classify( forest, subs );

	logger.untab();
end

