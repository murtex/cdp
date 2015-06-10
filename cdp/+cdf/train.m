function [classes, forest, trained] = train( runs, ntrees, seed, ratio )
% train random forest
%
% [classes, forest, trained] = TRAIN( runs, ntrees, seed, ratio )
%
% INPUT
% runs : runs (row object)
% ntrees : number of trees (scalar object)
% seed : randomization seed (scalar numeric)
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

		% gather training set statistics
	logger.tab( 'gather training set statistics...' );

	nruns = numel( runs );

	ntrials = 0;
	nlabeled = 0;
	nfeatured = 0;

	nclasses = 0;
	nfeatures = 0;

	classes = {}; % pre-allocation
	nsubs = [];

	function cid = classid( label ) % label to class conversion
		cid = find( strcmp( label, classes ) );
	end

	logger.progress();
	for i = 1:nruns
		n = numel( runs(i).trials );
		ntrials = ntrials + n;

		for j = 1:n
			label = runs(i).trials(j).labeled.label;
			if ~isempty( label )
				nlabeled = nlabeled + 1;

					% add new class
				if ~any( strcmp( label, classes ) )
					nclasses = nclasses + 1;
					classes{end+1} = label;

					nsubs(end+1) = 0;
				end

					% count subsequences
				featfile = runs(i).trials(j).labeled.featfile;
				if ~isempty( featfile )
					nfeatured = nfeatured + 1;

					mf = matfile( featfile );
					cid = classid( label );
					nsubs(cid) = nsubs(cid) + size( mf, 'subfeat', 1 );

					nfeatures = size( mf, 'subfeat', 2 );
				end

			end
		end

		logger.progress( i, nruns );
	end

	logger.log( 'subjects: %d', nruns );
	logger.log( 'trials: %d/%d/%d', nfeatured, nlabeled, ntrials );
	for i = 1:nclasses
		logger.log( 'class #%d samples: %d', i, nsubs(i) );
	end
	logger.log( 'features: %d', nfeatures );

	logger.untab();

		% sample training set
	logger.tab( 'sample training set...' );

	rng( 1 ); % fixed randomness

	trained = {}; % pre-allocation
	subs = [];
	sublabels = [];

	logger.progress();
	for i = 1:nruns

			% sample trials by training ratio
		rtrained = []; % pre-allocation

		n = numel( runs(i).trials );
		for j = 1:n
			if ~isempty( runs(i).trials(j).labeled.label ) && ...
					~isempty( runs(i).trials(j).labeled.featfile )
				rtrained(end+1) = j; % count valid trial
			end
		end

		if numel( rtrained ) > 1
			rtrained = randsample( rtrained, ceil( ratio * numel( rtrained ) ) );
		end

		trained{runs(i).id} = runs(i).trials(rtrained).id; % set output

			% read subsequences
		rsubs = NaN( 0, nfeatures ); % pre-allocation
		rsublabels = [];

		for j = rtrained
			load( runs(i).trials(j).labeled.featfile, 'subfeat' );
			s = size( subfeat, 1 );

			rsubs(end+1:end+s, :) = subfeat;
			rsublabels(end+1:end+s) = classid( runs(i).trials(j).labeled.label );
		end

			% sample even labeled subsequences
		nmax = Inf;
		for j = 1:nclasses
			nmax = min( nmax, sum( rsublabels == j ) );
		end

		for j = 1:nclasses
			ci = find( rsublabels == j );

			n = numel( ci );
			if n > nmax
				si = randsample( ci, n-nmax ); % limit subsequences randomly

				rsubs(si, :) = [];
				rsublabels(si) = [];
			end
		end

		subs = cat( 1, subs, rsubs );
		sublabels = cat( 2, sublabels, rsublabels );

		logger.progress( i, nruns );
	end

	for i = 1:nclasses
		n = sum( sublabels == i );
		logger.log( 'class #%d samples: %d (%.1f%%)', i, n, 100 * n / nsubs(i) );
	end

	logger.untab();

		% train random forest
	rng( seed ); % seed randomness

	%dbgi = randsample( size( subs, 1 ), 100 );
	%forest = brf.train( subs(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subs, sublabels, nclasses, ntrees, false );

	logger.untab();
end

