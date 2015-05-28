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

		% sample training set
	logger.tab( 'sample training set...' );

	rng( 1 ); % fixed randomness

	nmaxsubs = min( nsubs(:) );

	subs = zeros( nclasses, nruns*nmaxsubs, nfeatures ); % pre-allocation

	logger.progress();
	for i = 1:nruns
		for j = 1:nclasses

				% prepare sample pool
			pool = zeros( 0, nfeatures ); % pre-allocation

			m = numel( runs(i).trials );
			for k = 1:m

					% current class only
				label = runs(i).trials(k).labeled.label;
				featfile = runs(i).trials(k).detected.featfile;

				if ~isempty( label ) && classid( label ) == j && ~isempty( featfile )

						% read subsequences
					load( featfile, 'subfeat' );
					pool(end+1:end+size( subfeat, 1 ), :) = subfeat;

				end
			end

				% sample from pool
			si = randsample( 1:size( pool, 1 ), nmaxsubs );
			subs(j, (i-1)*nmaxsubs+1:i*nmaxsubs, :) = pool(si, :);

		end

		logger.progress( i, nruns );
	end

	subs = reshape( subs, nclasses*nruns*nmaxsubs, nfeatures ); % plain feature matrix
	sublabels = repmat( 1:nclasses, 1, nruns*nmaxsubs ); % labels

	for i = 1:nclasses
		logger.log( 'class #%d samples: %d (%.1f%%)', ...
			i, nruns*nmaxsubs, 100 * nruns*nmaxsubs / sum( nsubs(i, :) ) );
	end

	logger.untab();

		% train random forest
	rng( seed ); % random seed

	%dbgi = randsample( size( subs, 1 ), 20 );
	%forest = brf.train( subs(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subs, sublabels, nclasses, ntrees, false );

	logger.untab();
end

