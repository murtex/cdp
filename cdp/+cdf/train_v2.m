function [classes, forest] = train_v2( runs, ntrees, seed )
% train random forest
%
% [classes, forest] = TRAIN_V2( runs, ntrees, seed )
%
% INPUT
% runs : runs (row object)
% ntrees : number of trees (scalar object)
% seed : randomization seed (scalar numeric)
%
% OUTPUT
% classes : class labels (cell row char)
% forest : trees (row struct)

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

	logger = xis.hLogger.instance();
	logger.tab( 'train random forest...' );

		% gather training set statistics
	logger.tab( 'gather statistics...' );

	nruns = numel( runs );

	ntrials = 0;
	nlabeled = 0;
	nfeatured = 0;

	nclasses = 0;
	nfeatures = 0;

	classes = {}; % pre-allocation
	nsubs = zeros( 0, nruns );

	function cid = classid( label ) % label to class conversion
		cid = find( strcmp( label, classes ) );
	end

	logger.progress();
	for i = 1:nruns
		m = numel( runs(i).trials );
		ntrials = ntrials + m;

		for j = 1:m
			label = runs(i).trials(j).labeled.label;
			if ~isempty( label )
				nlabeled = nlabeled + 1;

					% add new class
				if ~any( strcmp( label, classes ) )
					nclasses = nclasses + 1;
					classes{end+1} = label;

					nsubs(end+1, :) = zeros( 1, nruns );
				end

					% count subsequences
				featfile = runs(i).trials(j).detected.featfile;
				if ~isempty( featfile )
					nfeatured = nfeatured + 1;

					mf = matfile( featfile );
					cid = classid( label );
					nsubs(cid, i) = nsubs(cid, i) + size( mf, 'subfeat', 1 );

					nfeatures = size( mf, 'subfeat', 2 );
				end

			end
		end

		logger.progress( i, nruns );
	end

	logger.log( 'subjects: %d', nruns );
	logger.log( 'trials: %d/%d/%d', nfeatured, nlabeled, ntrials );
	for i = 1:nclasses
		logger.log( 'class #%d samples: %d', i, sum( nsubs(i, :) ) );
	end
	logger.log( 'features: %d', nfeatures );

	logger.untab();

		% prepare subsequence dataset
	sublen = nfeatures;

		% build subsequence dataset
	logger.tab( 'build subsequence dataset...' );

	rng( 1 ); % fixed random for subsequence sampling

	nmaxsubs = min( nsubs(:) ); % pre-allocation
	subs = NaN( nclasses, nruns*nmaxsubs, sublen );

	logger.progress();
	for i = 1:nruns

			% proceed classes
		for j = 1:nclasses

				% build subsequence datapool
			subpool = NaN( 0, sublen ); % pre-allocation

			m = numel( runs(i).trials );
			for k = 1:m

					% skip unfeatured or unlabeled data
				featfile = runs(i).trials(k).detected.featfile;

				cid = classid( runs(i).trials(k).labeled.label );

				if isempty( featfile ) || isempty( cid )
					continue;
				end

					% read subsequences of current class
				if cid == j
					load( featfile, 'subfeat' );
					subpool(end+1:end+size( subfeat, 1 ), :) = subfeat;
				end

			end

				% sample subsequences from pool
			si = randi( size( subpool, 1 ), nmaxsubs, 1 );
			subs(j, (i-1)*nmaxsubs+1:i*nmaxsubs, :) = subpool(si, :);

		end

		logger.progress( i, nruns );
	end

	subs = reshape( subs, nclasses*nruns*nmaxsubs, sublen ); % feature matrix
	sublabels = repmat( 1:nclasses, 1, nruns*nmaxsubs ); % labels

	logger.log( 'subsequences: %d', size( subs, 1 ) );

	logger.untab();

		% grow subsequence forest
	rng( seed );

	%dbgi = randsample( size( subs, 1 ), 20 );
	%forest = brf.train( subs(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subs, sublabels, nclasses, ntrees, false );

	logger.untab();
end

