function [classes, forest] = train( runs, ntrees, seed )
% train random forest
%
% [classes, forest] = TRAIN( runs, ntrees, seed )
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

		% get class labels
	nruns = numel( runs );

	classes = {}; % pre-allocation

	for i = 1:nruns
		m = numel( runs(i).trials );
		for j = 1:m
			label = runs(i).trials(j).labeled.label;
			if ~isempty( label ) && ~any( strcmp( label, classes ) )
				classes{end+1} = label;
			end
		end
	end

	nclasses = numel( classes );
	if nclasses < 2
		error( 'invalid number of classes' );
	end

	function cid = classid( class ) % string to index conversion
		cid = find( strcmp( class, classes ) );
	end

	logger.log( 'subjects: %d', nruns );
	logger.log( 'classes: %d', nclasses );

		% prepare subsequence dataset
	logger.tab( 'prepare subsequence dataset...' );

	nsubs = zeros( nclasses, nruns ); % pre-allocation
	sublen = 0;

	logger.progress();
	for i = 1:nruns

			% proceed trials
		m = numel( runs(i).trials );
		for j = 1:m

				% skip unfeatured or unlabeled data
			featfile = runs(i).trials(j).detected.featfile;

			cid = classid( runs(i).trials(j).labeled.label );

			if isempty( featfile ) || isempty( cid )
				continue;
			end

				% inspect subsequences
			mf = matfile( featfile, 'Writable', false );
			sfs = size( mf, 'subfeat' );

			if sublen == 0
				sublen = sfs(2);
			elseif sfs(2) ~= sublen
				error( 'invalid subsequence' );
			end
			nsubs(cid, i) = nsubs(cid, i) + sfs(1);

		end

		logger.progress( i, nruns );
	end

	for i = 1:nclasses
		logger.log( 'class #%d subsequences: %d (max: %d)', i, sum( nsubs(i, :) ), min( nsubs(i, :) ) );
	end

	logger.untab();

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
			si = randsample( 1:size( subpool, 1 ), nmaxsubs );
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

