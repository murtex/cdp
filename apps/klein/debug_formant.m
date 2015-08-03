function debug_formant( indir, outdir, ids, ntrials, seed )
% debug formant-onsets
%
% DEBUG_FORMANT( indir, outdir, ids, ntrials, seed )
%
% INPUT
% indir : input directory (row char)
% outdir : plot directory (row char)
% ids : subject identifiers (row numeric)
% ntrials : number of trials (scalar numeric)
% seed : randomization seed (scalar numeric)

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

	if nargin < 4 || ~isscalar( ntrials ) || ~isnumeric( ntrials )
		error( 'invalid argument: ntrials' );
	end

	if nargin < 5 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: seed' );
	end

		% prepare directories
	if exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

		% initialize framework
	addpath( '../../cdf/' );

	logger = xis.hLogger.instance( fullfile( outdir, sprintf( 'debug_formant_%d-%d.log', min( ids ), max( ids ) ) ) );
	logger.tab( 'debug formant-onsets...' );

	style = xis.hStyle.instance();

	cfg = cdf.hConfig(); % formant config

	cfg.lab_freqband = [0, 2000];
	cfg.lab_nfreqs = 200;

		% proceed subject identifiers
	global_f0onsets = []; % pre-allocation
	global_f1freqs = [];

	for i = ids
		logger.tab( 'subject: %d', i );

			% read input data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', i ) );

		if exist( cdffile, 'file' ) ~= 2
			logger.untab( 'skipping...' );
			continue;
		end

		logger.log( 'read cdf data (''%s'')...', cdffile );
		load( cdffile, 'run' );

		read_audio( run, run.audiofile, false );

			% gather formant statistics
		resps = [run.resps_lab];

		bos = transpose( [resps.bo] );
		f0s = cat( 1, resps.f0 );
		f1s = cat( 1, resps.f1 );

		f0onsets = f0s(:, 1) - bos;
		f0freqs = f0s(:, 2);
		f1freqs = f1s(:, 2);

		nans = isnan( f0onsets ) | isnan( f0freqs ) | isnan( f1freqs ); % remove nans
		f0onsets(nans) = [];
		f0freqs(nans) = [];
		f1freqs(nans) = [];

		f0onsetmean = median( f0onsets ); % normalization
		f0onsets = (f0onsets - f0onsetmean) / f0onsetmean;
		f1freqmean = median( f1freqs );
		f1freqs = (f1freqs - f1freqmean) / f1freqmean;

		global_f0onsets = cat( 1, global_f0onsets, f0onsets ); % update globals
		global_f1freqs = cat( 1, global_f1freqs, f1freqs );

			% bin statistics
		nbinxs = style.bins( f0onsets );
		nbinys = style.bins( f1freqs );
		bins = transpose( hist3( [f0onsets, f1freqs], [nbinxs, nbinys] ) );

		bins = bins / max( bins(:) );
		binxs = linspace( min( f0onsets ), max( f0onsets ), size( bins, 2 ) );
		binys = linspace( min( f1freqs ), max( f1freqs ), size( bins, 1 ) );

			% plot statistics
		fig = style.figure();

		title( sprintf( 'formant-onsets (trials: %d/%d)', numel( f0onsets ), numel( resps ) ) );
		xlabel( 'f0-onset (relative deviation)' );
		ylabel( 'f1-frequency (relative deviation)' );
		xlim( [min( binxs ), max( binxs )] );
		ylim( [min( binys ), max( binys )] );

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', 0 ) ) );
		imagesc( binxs, binys, bins );

		hc = colorbar();
		ylabel( hc, 'rate' );

		style.print( fullfile( outdir, sprintf( 'run_%d_formant.png', i ) ) );

		delete( fig );

			% clean up
		delete( run );

		logger.untab();
	end

		% done
	logger.untab( 'done' );

end

