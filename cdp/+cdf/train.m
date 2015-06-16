function [classes, forest, trained] = train( runs, ntrees, seed, ratio )
% train random forest
%
% [classes, forest, trained] = TRAIN( runs, ntrees, seed, ratio )
%
% INPUT
% runs : runs (row object)
% ntrees : number of trees (scalar object)
% seed : training seed (scalar numeric)
% ratio : training ratio (scalar numeric)
%
% OUTPUT
% classes : class labels (cell row char)
% forest : trees (row struct)
% trained : trained trial identifiers (cell row numeric)

		% safeguard
	if nargin < 1 || ~isrow( runs ) || ~isa( runs(1), 'cdf.hRun' )
		error( 'invalid arguments: runs' );
	end

	if nargin < 2 || ~isscalar( ntrees ) || ~isnumeric( ntrees )
		error( 'invalid argument: ntrees' );
	end

	if nargin < 3 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: seed' );
	end

	if nargin < 4 || ~isscalar( ratio ) || ~isnumeric( ratio )
		error( 'invalid argument: ratio' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'train random forest...' );

		% set dataset statistics
	logger.tab( 'dataset statistics...' );

	nruns = numel( runs );

	nclasses = 0; % pre-allocation
	classes = {};

	nsamples = [];
	nsubsamples = [];
	nfeatures = 0;

	logger.progress();
	for i = 1:nruns
		run = runs(i);

			% proceed trials
		ntrials = numel( run.trials );

		for j = 1:ntrials
			trial = run.trials(j);

				% skip unlabeled/unfeatured
			label = trial.labeled.label;
			featfile = trial.labeled.featfile;

			if isempty( label ) || isempty( featfile )
				continue;
			end

				% prepare for new class label
			if ~any( strcmp( label, classes ) )
				nclasses = nclasses + 1;

				classes{nclasses} = label;
				nsamples(nclasses) = 0;
				nsubsamples(nclasses) = 0;
			end

				% count samples
			cid = find( strcmp( label, classes ) );

			load( featfile, 'subfeat' );
			
			nsamples(cid) = nsamples(cid) + 1;
			nsubsamples(cid) = nsubsamples(cid) + size( subfeat, 1 );
			nfeatures = size( subfeat, 2 );

		end

		logger.progress( i, nruns );
	end

			% log statistics
	logger.tab( 'classes: %d', numel( classes ) );
	for i = 1:nclasses
		logger.log( 'class #%d: %s', i, classes{i} );
	end
	logger.untab();

	logger.tab( 'samples: %d [%d]', sum( nsubsamples ), sum( nsamples ) );
	for i = 1:nclasses
		logger.log( 'class #%d: %d [%d]', i, nsubsamples(i), nsamples(i) );
	end
	logger.untab();

	logger.log( 'features: %d', nfeatures );

	logger.untab();

		% sample training set
	logger.tab( 'sample training set...' );

	rng( 1 ); % fixed randomness, TODO: configure!

	trained = {}; % pre-allocation

	ntsamples = zeros( 1, nclasses );

	subsamples = [];
	sublabels = [];

	logger.progress();
	for i = 1:nruns
		run = runs(i);

			% sample training ratio
		ntrials = numel( run.trials );

		rsamples = cell( nclasses, 1 ); % pre-allocation

		for j = 1:ntrials
			trial = run.trials(j);

				% skip unlabeled/unfeatured
			label = trial.labeled.label;
			featfile = trial.labeled.featfile;

			if isempty( label ) || isempty( featfile )
				continue;
			end

				% append valid trial
			cid = find( strcmp( label, classes ) );

			rsamples{cid} = cat( 2, rsamples{cid}, j );

		end

		ntrain = ceil( ratio * min( cellfun( @numel, rsamples ) ) ); % evenly labeled trials
		if isempty( ntrain ) || ntrain == 0
			logger.progress( i, nruns );
			continue;
		end

		for j = 1:nclasses % sample ratio
			if numel( rsamples{j} ) > 1
				rsamples{j} = randsample( rsamples{j}, ntrain );
			end
		end

		trained{run.id} = []; % set output
		for j = 1:nclasses
			trained{run.id} = cat( 2, trained{run.id}, [run.trials(rsamples{j}).id] );
		end
		
		for j = 1:nclasses % count samples
			ntsamples(j) = ntsamples(j) + numel( rsamples{j} );
		end

			% read subsequences
		rsubsamples = []; % pre-allocation
		rsublabels = [];

		trials = [rsamples{:}];
		for j = trials
			trial = run.trials(j);

			label = trial.labeled.label;
			featfile = trial.labeled.featfile;

			load( featfile, 'subfeat' );

			rsubsamples = cat( 1, rsubsamples, subfeat );
			rsublabels = cat( 2, rsublabels, repmat( find( strcmp( label, classes ) ), 1, size( subfeat, 1 ) ) );
		end

		subsamples = cat( 1, subsamples, rsubsamples );
		sublabels = cat( 2, sublabels, rsublabels );

		logger.progress( i, nruns );
	end

			% log training set
	logger.tab( 'samples: %d (%.1f%%) [%d (%.1f%%)]', ...
		numel( sublabels ), 100 * numel( sublabels ) / sum( nsubsamples ), ...
		sum( ntsamples ), 100 * sum( ntsamples ) / sum( nsamples ) );
	for i = 1:nclasses
		logger.log( 'class #%d: %d (%.1f%%) [%d (%.1f%%)]', i, ...
			sum( sublabels == i ), 100 * sum( sublabels == i ) / nsubsamples(i), ...
			ntsamples(i), 100 * ntsamples(i) / nsamples(i) );
	end
	logger.untab();

	logger.untab();

		% train random forest
	rng( seed ); % seed randomness

	%dbgi = randsample( size( subsamples, 1 ), 100 );
	%forest = brf.train( subsamples(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subsamples, sublabels, nclasses, ntrees, false );

	logger.untab();
end

