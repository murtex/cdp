function stats( indir, outdir, ids )
% cdf statistics
%
% STATS( indir, outdir, ids )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir )
		error( 'invalid argument: indir' );
	end
	
	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

		% check/prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	stamp = datestr( now(), 'yymmdd-HHMMSS-FFF' );
	logfile = fullfile( outdir, sprintf( 'test_stats_%s.log', stamp ) );

	logger = xis.hLogger.instance( logfile );
	logger.tab( 'cdf statistics...' );

		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read input
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );
		if exist( cdffile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

			% gather statistics
		ntrials = numel( run.trials );

		trialjs = 1:ntrials; % pre-allocation
		vals = true( 1, ntrials );

		for j = 1:ntrials % valid trials
			if any( isnan( run.trials(j).range ) )
				vals(j) = false;
			end
		end
		nvaltrials = sum( vals );

		for j = 1:ntrials % valid responses
			if any( isnan( run.resps_lab(j).range ) )
				vals(j) = false;
			end
		end
		nvalresps = sum( vals );

		formantfl1 = false( 1, ntrials ); % missing formants
		for j = 1:ntrials
			if ~vals(j)
				continue;
			end
			if any( isnan( run.resps_lab(j).f0 ) ) || any( isnan( run.resps_lab(j).f1 ) ) || ...
					any( isnan( run.resps_lab(j).f2 ) ) || any( isnan( run.resps_lab(j).f3 ) ) 
				formantfl1(j) = true;
			end
		end

		formantfl2 = false( 1, ntrials ); % wrong formant order/dupplicates
		formantfl3 = false( 1, ntrials );

		for j = 1:ntrials
			if ~vals(j)
				continue;
			end

			resp = run.resps_lab(j);
			freqs = cat( 1, resp.f0(2), resp.f1(2), resp.f2(2), resp.f3(2) );

			if any( diff( freqs ) < 0 )
				formantfl2(j) = true;
			elseif any( diff( freqs ) == 0 )
				formantfl3(j) = true;
			end
		end

			% log statistics
		logger.log( 'trials: %d', ntrials );
		logger.log( 'valid trials: %d', nvaltrials );
		logger.log( 'valid responses: %d', nvalresps );

		logger.log( 'missing formants: %d', sum( formantfl1 ) );
		js1 = transpose( trialjs(formantfl1) )

		logger.log( 'wrong formant order: %d', sum( formantfl2 ) );
		js2 = transpose( trialjs(formantfl2) )

		logger.log( 'duplicate formants: %d', sum( formantfl3 ) );
		js3 = transpose( trialjs(formantfl3) )

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

