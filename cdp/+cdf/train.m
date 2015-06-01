function [classes, forest] = train( runs, ntrees, seed, labeled )
% train random forest
%
% [classes, forest] = TRAIN( runs, ntrees, seed )
%
% INPUT
% runs : runs (row object)
% ntrees : number of trees (scalar object)
% seed : randomization seed (scalar numeric)
% DEBUG: labeled : classify labeled features (scalar logical)
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

	if nargin < 4 || ~isscalar( labeled ) || ~islogical( labeled )
		error( 'invalid argument: labeled' );
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
				if labeled
					featfile = runs(i).trials(j).labeled.featfile;
				else
					featfile = runs(i).trials(j).detected.featfile;
				end

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

	subs = []; % pre-allocation
	sublabels = [];

	logger.progress();
	for i = 1:nruns

			% read subsequences
		rsubs = zeros( sum( nsubs(:, i) ), nfeatures ); % pre-allocation
		rsublabels = zeros( 1, size( rsubs, 1 ) );

		ci = 1;

		m = numel( runs(i).trials );
		for j = 1:m
			label = runs(i).trials(j).labeled.label;

			if labeled
				featfile = runs(i).trials(j).labeled.featfile;
			else
				featfile = runs(i).trials(j).detected.featfile;
			end

			if ~isempty( label ) && ~isempty( featfile )
				load( featfile, 'subfeat' );
				n = size( subfeat, 1 );

				rsubs(ci:ci+n-1, :) = subfeat;
				rsublabels(ci:ci+n-1) = classid( label );

				ci = ci + n;
			end
		end

			% sample even labeled subsequences
		nmax = min( nsubs(:, i) );

		for j = 1:nclasses
			ci = find( rsublabels == j );

			n = numel( ci );
			if n > nmax
				si = randsample( ci, n-nmax );

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
		logger.log( 'class #%d samples: %d (%.1f%%)', i, n, 100 * n / sum( nsubs(i, :) ) );
	end

	logger.untab();

		% train random forest
	rng( seed ); % seed randomness

	%dbgi = randsample( size( subs, 1 ), 20 );
	%forest = brf.train( subs(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subs, sublabels, nclasses, ntrees, false );

	logger.untab();
end

