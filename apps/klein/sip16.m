function sip16( indir, ids )
% landmark detection statistics (IEEE SIP 2016)
%
% sip16( indir, ids )
%
% INPUT
% indir : input directory (row char)
% ids : subject identifiers (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir )
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

		% include cue-distractor package
	addpath( '../../cdp/' );
    
		% prepare for output
	plotdir = fullfile( indir, 'plot' );
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

    style = xis.hStyle.instance();
    
	logger = xis.hLogger.instance( fullfile( indir, sprintf( '%d-%d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'test landmarks...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% -------------------------------------------------------------------
		% helper functions
    MAXDELTA = 15;
	BINFACTOR = 1;
    
	global nrefbos nrefvos nrefvrs nrefvots nreflens
	global nbos nvos nvrs nvots nlens
	global nbodels nvodels nvrdels nvotdels nlendels
	global nboins nvoins nvrins nvotins nlenins
	global dbos ndbos absdbos dbopos dbons absdbopos absdbons
	global dvos ndvos absdvos dvopos dvons absdvopos absdvons
	global dvrs ndvrs absdvrs dvrpos dvrns absdvrpos absdvrns
	global dvots ndvots absdvots dvotpos dvotns absdvotpos absdvotns
	global dlens ndlens absdlens dlenpos dlenns absdlenpos absdlenns

	function stats( refbos, refvos, refvrs, refvots, reflens, bos, vos, vrs, vots, lens )

			% overall
		nrefbos = sum( ~isnan( refbos ) ); % labeled landmarks
		nrefvos = sum( ~isnan( refvos ) );
		nrefvrs = sum( ~isnan( refvrs ) );
		nrefvots = sum( ~isnan( refvots ) );
		nreflens = sum( ~isnan( reflens ) );

		nbos = sum( ~isnan( bos ) ); % detected landmarks
		nvos = sum( ~isnan( vos ) );
		nvrs = sum( ~isnan( vrs ) );
		nvots = sum( ~isnan( vots ) );
		nlens = sum( ~isnan( lens ) );
    
			% deletetions
		nbodels = sum( ~isnan( refbos(:) ) & isnan( bos(:) ) );
		nvodels = sum( ~isnan( refvos(:) ) & isnan( vos(:) ) );
		nvrdels = sum( ~isnan( refvrs(:) ) & isnan( vrs(:) ) );
		nvotdels = sum( ~isnan( refvots(:) ) & isnan( vots(:) ) );
		nlendels = sum( ~isnan( reflens(:) ) & isnan( lens(:) ) );
    
			% insertions
		nboins = sum( isnan( refbos(:) ) & ~isnan( bos(:) ) );
		nvoins = sum( isnan( refvos(:) ) & ~isnan( vos(:) ) );
		nvrins = sum( isnan( refvrs(:) ) & ~isnan( vrs(:) ) );
		nvotins = sum( isnan( refvots(:) ) & ~isnan( vots(:) ) );
		nlenins = sum( isnan( reflens(:) ) & ~isnan( lens(:) ) );
    
			% detection
		dbos = sta.smp2msec( bos(:) - refbos(:), audiorate ); % deltas
		dvos = sta.smp2msec( vos(:) - refvos(:), audiorate );
		dvrs = sta.smp2msec( vrs(:) - refvrs(:), audiorate );
    	dvots = sta.smp2msec( vots(:) - refvots(:), audiorate );
    	dlens = sta.smp2msec( lens(:) - reflens(:), audiorate );
		dbos(isnan( dbos )) = [];
		dvos(isnan( dvos )) = [];
		dvrs(isnan( dvrs )) = [];
    	dvots(isnan( dvots )) = [];
    	dlens(isnan( dlens )) = [];
    
		ndbos = numel( dbos ); % burst-onset binning
		dbos(abs( dbos ) > MAXDELTA ) = [];
		absdbos = abs( dbos );
		dbopos = linspace( min( dbos ), max( dbos ), round( BINFACTOR * style.bins( dbos ) ) );
		dbons = hist( dbos, dbopos );
		absdbopos = linspace( min( absdbos ), max( absdbos ), numel( absdbos ) ); %style.bins( absdbos ) );
		absdbons = hist( absdbos, absdbopos );

		ndvos = numel( dvos ); % voice-onset binning
		dvos(abs( dvos ) > MAXDELTA) = [];
		absdvos = abs( dvos );
		dvopos = linspace( min( dvos ), max( dvos ), round( BINFACTOR * style.bins( dvos ) ) );
		dvons = hist( dvos, dvopos );
		absdvopos = linspace( min( absdvos ), max( absdvos ), numel( absdvos ) ); %style.bins( absdvos ) );
		absdvons = hist( absdvos, absdvopos );

		ndvrs = numel( dvrs ); % voice-release binning
		dvrs(abs( dvrs ) > MAXDELTA) = [];
		absdvrs = abs( dvrs );
		dvrpos = linspace( min( dvrs ), max( dvrs ), round( BINFACTOR * style.bins( dvrs ) ) );
		dvrns = hist( dvrs, dvrpos );
		absdvrpos = linspace( min( absdvrs ), max( absdvrs ), numel( absdvrs ) ); %style.bins( absdvrs ) );
		absdvrns = hist( absdvrs, absdvrpos );

		ndvots = numel( dvots ); % voice-onset time binning
		dvots(abs( dvots ) > MAXDELTA) = [];
		absdvots = abs( dvots );
		dvotpos = linspace( min( dvots ), max( dvots ), round( BINFACTOR * style.bins( dvots ) ) );
		dvotns = hist( dvots, dvotpos );
		absdvotpos = linspace( min( absdvots ), max( absdvots ), numel( absdvots ) ); %style.bins( absdvots ) );
		absdvotns = hist( absdvots, absdvotpos );
    
		ndlens = numel( dlens ); % vowel-length binning
		dlens(abs( dlens ) > MAXDELTA) = [];
		absdlens = abs( dlens );
		dlenpos = linspace( min( dlens ), max( dlens ), round( BINFACTOR * style.bins( dlens ) ) );
		dlenns = hist( dlens, dlenpos );
		absdlenpos = linspace( min( absdlens ), max( absdlens ), numel( absdlens ) ); %style.bins( absdlens ) );
		absdlenns = hist( absdlens, absdlenpos );
    
	end

	function logstats()

			% overall
    	logger.tab( 'overall statistics' );
		logger.log( 'ref. burst-onsets: %d', nrefbos );
		logger.log( 'ref. voice-onsets: %d', nrefvos );
		%logger.log( 'ref. voice-releases: %d', nrefvrs );
		logger.log( 'ref. voice-onset times: %d', nrefvots );
		%logger.log( 'ref. vowel-lengths: %d', nreflens );
		logger.log( 'burst-onsets: %d', nbos );
		logger.log( 'voice-onsets: %d', nvos );
		%logger.log( 'voice-releases: %d', nvrs );    
		logger.log( 'voice-onset times: %d', nvots );
		%logger.log( 'vowel-lengths: %d', nlens );
    	logger.untab();
    
			% deletions
		logger.tab( 'deletion statistics' );
		logger.log( 'burst-onset (rate): %d (%.3f)', nbodels, nbodels/nrefbos );
		logger.log( 'voice-onset (rate): %d (%.3f)', nvodels, nvodels/nrefvos );
		%logger.log( 'voice-release (rate): %d (%.3f)', nvrdels, nvrdels/nrefvrs );
		logger.log( 'voice-onset time (rate): %d (%.3f)', nvotdels, nvotdels/nrefvots );
		%logger.log( 'vowel-length (rate): %d (%.3f)', nlendels, nlendels/nreflens );
		logger.untab();    

			% insertions
		%logger.tab( 'insertion statistics' );
		%logger.log( 'burst-onset (rate): %d (%.3f)', nboins, nboins/nrefbos );
		%logger.log( 'voice-onset (rate): %d (%.3f)', nvoins, nvoins/nrefvos );
		%logger.log( 'voice-release (rate): %d (%.3f)', nvrins, nvrins/nrefvrs );
		%logger.log( 'voice-onset time (rate): %d (%.3f)', nvotins, nvotins/nrefvots );
		%logger.log( 'vowel-length (rate): %d (%.3f)', nlenins, nlenins/nreflens );
		%logger.untab();

			% accuracy
		logger.tab( 'accuracy statistics (+/-5ms)' );
		
		logger.log( 'burst-onset: %.3f', sum( absdbons(absdbopos <= 5) ) / ndbos );
		logger.log( 'voice-onset: %.3f', sum( absdvons(absdvopos <= 5) ) / ndvos );
		%logger.log( 'voice-release: %.3f', sum( absdvrns(absdvrpos <= 5) ) / ndvrs );
		logger.log( 'voice-onset time: %.3f', sum( absdvotns(absdvotpos <= 5) ) / ndvots );
		%logger.log( 'vowel-length: %.3f', sum( absdlenns(absdlenpos <= 5) ) / ndlens );
		
		logger.untab();

	end

	function pp = plottile( rows, cols )
		pp(1) = 0;
		pp(2) = 0;
		pp(3) = rows * 59;
		pp(4) = cols * 59;
	end

	function plotstats1( plotfile )
		logger.log( 'plot detection statistics ''%s''...', plotfile );

		fig = style.figure( 'PaperPosition', plottile( 6, 6 ) );
		
		subplot( 3, 2, 1 ); % burst-onset
		title( 'burst-onset (+b) detection' );
		ylabel( 'detection rate' );
		xlim( MAXDELTA * [-1, 1] );
		bar( dbopos, dbons / ndbos, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 3, 2, 2 );
		ylabel( 'cumulative rate' );
		xlim( MAXDELTA * [0, 1] );
		bar( absdbopos, cumsum( absdbons ) / ndbos, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 3, 2, 3 ); % voice-onset
		title( 'voice-onset (+g) detection' );
		ylabel( 'detection rate' );
		xlim( MAXDELTA * [-1, 1] );
		bar( dvopos, dvons / ndvos, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 3, 2, 4 );
		ylabel( 'cumulative rate' );
		xlim( MAXDELTA * [0, 1] );
		bar( absdvopos, cumsum( absdvons ) / ndvos, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 3, 2, 5 ); % voice-release
		title( 'voice-release (-g) detection' );
		xlabel( 'delta in milliseconds' );
		ylabel( 'detection rate' );
		xlim( MAXDELTA * [-1, 1] );
		bar( dvrpos, dvrns / ndvrs, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 3, 2, 6 );
		xlabel( 'abs( delta ) in milliseconds' );
		ylabel( 'cumulative rate' );
		xlim( MAXDELTA * [0, 1] );
		bar( absdvrpos, cumsum( absdvrns ) / ndvrs, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		style.print( plotfile );
		delete( fig );
	end

	function plotstats2( plotfile )
		logger.log( 'plot detection statistics ''%s''...', plotfile );

		fig = style.figure( 'PaperPosition', plottile( 6, 4 ) );
		
		subplot( 2, 2, 1 ); % voice-onset time
		title( 'voice-onset time detection' );
		ylabel( 'detection rate' );
		xlim( MAXDELTA * [-1, 1] );
		bar( dvotpos, dvotns / ndvots, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 2, 2, 2 );
		ylabel( 'cumulative rate' );
		xlim( MAXDELTA * [0, 1] );
		bar( absdvotpos, cumsum( absdvotns ) / ndvots, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
		subplot( 2, 2, 3 ); % vowel-length
		title( 'vowel-length detection' );
		xlabel( 'delta in milliseconds' );
		ylabel( 'detection rate' );
		xlim( MAXDELTA * [-1, 1] );
		bar( dlenpos, dlenns / ndlens, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
		subplot( 2, 2, 4 );
		xlabel( 'abs( delta ) in milliseconds' );
		ylabel( 'cumulative rate' );
		xlim( MAXDELTA * [0, 1] );
		bar( absdlenpos, cumsum( absdlenns ) / ndlens, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
		style.print( plotfile );
		delete( fig );
	end

	function plotstats3( plotfile )
		logger.log( 'plot accuracy statistics ''%s''...', plotfile );
		
		fig = style.figure( 'PaperPosition', plottile( 6, 8 ) );

		subplot( 2, 1, 1 ); % landmarks
		title( 'landmark accuracy (+/-5ms)' );
		ylabel( 'cumulative rate' );
		plot( absdbopos, cumsum( absdbons ) / ndbos, ...
			'Color', style.color( 'neutral', 0 ), 'LineStyle', '-', ...
			'DisplayName', sprintf( 'burst-onset (%.3f)', sum( absdbons(absdbopos <= 5) ) / ndbos ) );
		plot( absdvopos, cumsum( absdvons ) / ndvos, ...
			'Color', style.color( 'neutral', 0 ), 'LineStyle', '-.', ...
			'DisplayName', sprintf( 'voice-onset (%.3f)', sum( absdvons(absdvopos <= 5) ) / ndvos ) );
		plot( absdvrpos, cumsum( absdvrns ) / ndvrs, ...
			'Color', style.color( 'neutral', 0 ), 'LineStyle', ':', ...
			'DisplayName', sprintf( 'voice-release (%.3f)', sum( absdvrns(absdvrpos <= 5) ) / ndvrs ) );

		h = legend( 'Location', 'southeast' );
		set( h, 'Color', style.color( 'grey', 0.985 ) );
		
		subplot( 2, 1, 2 ); % intervals
		title( 'interval accuracy (+/-5ms)' );
		xlabel( 'abs( delta ) in milliseconds' );
		ylabel( 'cumulative rate' );
		plot( absdvotpos, cumsum( absdvotns ) / ndvots, ...
			'Color', style.color( 'neutral', 0 ), 'LineStyle', '-', ...
			'DisplayName', sprintf( 'voice-onset time (%.3f)', sum( absdvotns(absdvotpos <= 5) ) / ndvots ) );
		plot( absdlenpos, cumsum( absdlenns ) / ndlens, ...
			'Color', style.color( 'neutral', 0 ), 'LineStyle', ':', ...
			'DisplayName', sprintf( 'vowel-length (%.3f)', sum( absdlenns(absdlenpos <= 5) ) / ndlens ) );
		
		h = legend( 'Location', 'southeast' );
		set( h, 'Color', style.color( 'grey', 0.985 ) );
		
		style.print( plotfile );
		delete( fig );
	end

        % -------------------------------------------------------------------
        % statistics
    audiorate = NaN;
    
    refbos = []; % landmarks
    refvos = [];
    refvrs = [];
    refvots = [];
    reflens = [];
    
    bos = [];
    vos = [];
    vrs = [];
    vots = [];
    lens = [];
    
		% proceed subjects
	for i = ids
		logger.tab( 'subject: %d', i );

			% read cdf data
		infile = fullfile( indir, sprintf( 'run_%d.mat', i ) );

		if exist( infile, 'file' ) ~= 2 % skip non-existing
			logger.untab( 'skipping' );
			continue;
		end

		logger.log( 'read cdf ''%s''...', infile );
		load( infile, '-mat', 'run' );
        
            % gather statistics
        if isnan( audiorate ) % constant sampling rate
            audiorate = run.audiorate;
        elseif audiorate ~= run.audiorate
            error( 'invalid argument: audiorate' );
        end
        
        labtrials = [run.trials.labeled]; % labeled and detected trials
        dettrials = [run.trials.detected];

        refbos(end+1, :) = [labtrials.bo]; % labeled landmarks
        refvos(end+1, :) = [labtrials.vo];
        refvrs(end+1, :) = [labtrials.vr];
        refvots(end+1, :) = refvos(end, :) - refbos(end, :);
        reflens(end+1, :) = refvrs(end, :) - refvos(end, :);

        bos(end+1, :) = [dettrials.bo]; % detected landmarks
        vos(end+1, :) = [dettrials.vo];
        vrs(end+1, :) = [dettrials.vr];
        vots(end+1, :) = vos(end, :) - bos(end, :);
        lens(end+1, :) = vrs(end, :) - vos(end, :);

			% log and plot per-subject stats
		stats( refbos(end, :), refvos(end, :), refvrs(end, :), refvots(end, :), reflens(end, :), ...
			bos(end, :), vos(end, :), vrs(end, :), vots(end, :), lens(end, :) );
		%logstats();
		%plotstats1( fullfile( plotdir, sprintf( 'sip16_fig1_%02d.png', i ) ) );
		%plotstats2( fullfile( plotdir, sprintf( 'sip16_fig2_%02d.png', i ) ) );
		%plotstats3( fullfile( plotdir, sprintf( 'sip16_fig3_%02d.png', i ) ) );

			% cleanup
		delete( run );

		logger.untab();
    end

		% log and plot global stats
	stats( refbos(:), refvos(:), refvrs(:), refvots(:), reflens(:), ...
		bos(:), vos(:), vrs(:), vots(:), lens(:) );
	logstats();
	plotstats1( fullfile( plotdir, 'sip16_fig1_all.png' ) );
	plotstats2( fullfile( plotdir, 'sip16_fig2_all.png' ) );
	plotstats3( fullfile( plotdir, 'sip16_fig3_all.png' ) );
    
		% cleanup
	logger.untab( 'done.' ); % stop logging

end

