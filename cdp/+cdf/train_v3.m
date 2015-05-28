function [classes, forest] = train_v3( runs, ntrees, seed )
% train random forest
%
% [classes, forest] = TRAIN_V3( runs, ntrees, seed )
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

		% read training set
	logger.tab( 'read training set...' );

	subs = zeros( sum( nsubs(:) ), nfeatures ); % pre-allocation
	sublabels = zeros( 1, sum( nsubs(:) ) );

	ci = 1;
	logger.progress();
	for i = 1:nruns
		m = numel( runs(i).trials );
		for j = 1:m

				% read subsequences
			label = runs(i).trials(j).labeled.label;
			featfile = runs(i).trials(j).detected.featfile;

			if ~isempty( label ) && ~isempty( featfile )
				load( featfile, 'subfeat' );
				n = size( subfeat, 1 );

				subs(ci:ci+n-1, :) = subfeat;
				sublabels(ci:ci+n-1) = classid( label );

				ci = ci + n;
			end

		end

		logger.progress( i, nruns );
	end

	logger.log( 'samples: %d', ci-1 );

	logger.untab();

		% train random forest
	rng( seed ); % random seed

	%dbgi = randsample( size( subs, 1 ), 20 );
	%forest = brf.train( subs(dbgi, :), sublabels(dbgi), nclasses, ntrees, false );
	%error( 'DEBUG' );

	forest = brf.train( subs, sublabels, nclasses, ntrees, false );

	logger.untab();
end

