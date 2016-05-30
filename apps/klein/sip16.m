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
        % prepare statistics
    audiorate = NaN;
    
    refbos = []; % landmarks
    refvos = [];
    refvrs = [];
    refvots = [];
    refvlens = [];
    
    bos = [];
    vos = [];
    vrs = [];
    vots = [];
    vlens = [];
    
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
        
            % ---------------------------------------------------------------
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
        refvlens(end+1, :) = refvrs(end, :) - refvos(end, :);

        bos(end+1, :) = [dettrials.bo]; % detected landmarks
        vos(end+1, :) = [dettrials.vo];
        vrs(end+1, :) = [dettrials.vr];
        vots(end+1, :) = vos(end, :) - bos(end, :);
        vlens(end+1, :) = vrs(end, :) - vos(end, :);
        
			% cleanup
		delete( run );

		logger.untab();
    end
    
        % -------------------------------------------------------------------
        % overall statistics
    logger.tab( 'overall statistics' );
    
    nrefbos = sum( ~isnan( refbos(:) ) ); % labeled landmarks
    nrefvos = sum( ~isnan( refvos(:) ) );
    nrefvrs = sum( ~isnan( refvrs(:) ) );
    nrefvots = sum( ~isnan( refvots(:) ) );
    
    logger.log( 'ref. burst-onsets: %d', nrefbos );
    logger.log( 'ref. voice-onsets: %d', nrefvos );
    logger.log( 'ref. voice-releases: %d', nrefvrs );
    logger.log( 'ref. voice-onset times: %d', nrefvots );
    
    nbos = sum( ~isnan( bos(:) ) ); % detected landmarks
    nvos = sum( ~isnan( vos(:) ) );
    nvrs = sum( ~isnan( vrs(:) ) );
    nvots = sum( ~isnan( vots(:) ) );
    
    logger.log( 'burst-onsets: %d', nbos );
    logger.log( 'voice-onsets: %d', nvos );
    logger.log( 'voice-releases: %d', nvrs );    
    logger.log( 'voice-onset times: %d', nvots );
    
    logger.untab();
    
        % -------------------------------------------------------------------
        % deletions statistics
    logger.tab( 'deletion statistics' );
    
    nbodels = sum( ~isnan( refbos(:) ) & isnan( bos(:) ) );
    nvodels = sum( ~isnan( refvos(:) ) & isnan( vos(:) ) );
    nvrdels = sum( ~isnan( refvrs(:) ) & isnan( vrs(:) ) );
    nvotdels = sum( ~isnan( refvots(:) ) & isnan( vots(:) ) );
    
    logger.log( 'burst-onset deletions (rate): %d (%.3f)', nbodels, nbodels/nrefbos );
    logger.log( 'voice-onset deletions (rate): %d (%.3f)', nvodels, nvodels/nrefvos );
    logger.log( 'voice-release deletions (rate): %d (%.3f)', nvrdels, nvrdels/nrefvrs );
    logger.log( 'voice-onset time deletions (rate): %d (%.3f)', nvotdels, nvotdels/nrefvots );
    
    logger.untab();    
    
        % -------------------------------------------------------------------
        % insertion statistics
    logger.tab( 'insertion statistics' );
    
    nboins = sum( isnan( refbos(:) ) & ~isnan( bos(:) ) );
    nvoins = sum( isnan( refvos(:) ) & ~isnan( vos(:) ) );
    nvrins = sum( isnan( refvrs(:) ) & ~isnan( vrs(:) ) );
    nvotins = sum( isnan( refvots(:) ) & ~isnan( vots(:) ) );
    
    logger.log( 'burst-onset insertions (rate): %d (%.3f)', nboins, nboins/nrefbos );
    logger.log( 'voice-onset insertions (rate): %d (%.3f)', nvoins, nvoins/nrefvos );
    logger.log( 'voice-release insertions (rate): %d (%.3f)', nvrins, nvrins/nrefvrs );
    logger.log( 'voice-onset time insertions (rate): %d (%.3f)', nvotins, nvotins/nrefvots );
    
    logger.untab();
    
        % -------------------------------------------------------------------
        % landmarks detection statistics
    plotfile = fullfile( plotdir, 'sip16_lm.png' );
	logger.log( 'plot landmark detection statistics ''%s''...', plotfile );
    
    MAXDELTA = 15; % prepare histogram data
    
    dbos = sta.smp2msec( bos(:) - refbos(:), audiorate );
    dvos = sta.smp2msec( vos(:) - refvos(:), audiorate );
    dvrs = sta.smp2msec( vrs(:) - refvrs(:), audiorate );
    dbos(isnan( dbos )) = [];
    dvos(isnan( dvos )) = [];
    dvrs(isnan( dvrs )) = [];
    
    fig = style.figure();
    
    ndbos = numel( dbos ); % plot burst-onsets
    dbos(abs( dbos ) > MAXDELTA ) = [];
    absdbos = abs( dbos );
    dbopos = linspace( min( dbos ), max( dbos ), style.bins( dbos ) );
    dbons = hist( dbos, dbopos );
	absdbopos = linspace( min( absdbos ), max( absdbos ), style.bins( absdbos ) );
	absdbons = hist( absdbos, absdbopos );

    subplot( 3, 2, 1 );
    title( 'burst-onset (+b) detection' );
    xlabel( 'delta in milliseconds' );
    ylabel( 'detection rate' );
    xlim( MAXDELTA * [-1, 1] );
    bar( dbopos, dbons / ndbos, ...
        'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    subplot( 3, 2, 2 );
    xlabel( 'abs( delta ) in milliseconds' );
    ylabel( 'cumulative rate' );
    xlim( MAXDELTA * [0, 1] );
	bar( absdbopos, cumsum( absdbons ) / ndbos, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    ndvos = numel( dvos ); % plot voice-onsets
    dvos(abs( dvos ) > MAXDELTA) = [];
    absdvos = abs( dvos );
    dvopos = linspace( min( dvos ), max( dvos ), style.bins( dvos ) );
    dvons = hist( dvos, dvopos );
	absdvopos = linspace( min( absdvos ), max( absdvos ), style.bins( absdvos ) );
	absdvons = hist( absdvos, absdvopos );

    subplot( 3, 2, 3 );
    title( 'voice-onset (+g) detection' );
    xlabel( 'delta in milliseconds' );
    ylabel( 'detection rate' );
    xlim( MAXDELTA * [-1, 1] );
    bar( dvopos, dvons / ndvos, ...
        'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    subplot( 3, 2, 4 );
    xlabel( 'abs( delta ) in milliseconds' );
    ylabel( 'cumulative rate' );
    xlim( MAXDELTA * [0, 1] );
	bar( absdvopos, cumsum( absdvons ) / ndvos, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    ndvrs = numel( dvrs ); % plot voice-releases
    dvrs(abs( dvrs ) > MAXDELTA) = [];
    absdvrs = abs( dvrs );
    dvrpos = linspace( min( dvrs ), max( dvrs ), style.bins( dvrs ) );
    dvrns = hist( dvrs, dvrpos );
	absdvrpos = linspace( min( absdvrs ), max( absdvrs ), style.bins( absdvrs ) );
	absdvrns = hist( absdvrs, absdvrpos );

    subplot( 3, 2, 5 );
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
    
        % -------------------------------------------------------------------
        % vot detection statistics
    plotfile = fullfile( plotdir, 'sip16_vot.png' );
	logger.log( 'plot voice-onset time detection statistics ''%s''...', plotfile );
    
    MAXRELDELTA = MAXDELTA / 300; % prepare histogram data
    
    dvots = sta.smp2msec( vots(:) - refvots(:), audiorate );
    drelvots = dvots ./ sta.smp2msec( refvlens(:), audiorate );
    dvots(isnan( dvots )) = [];
    drelvots(isnan( drelvots )) = [];
    
    fig = style.figure();
    
    ndvots = numel( dvots ); % plot voice-onset times
    dvots(abs( dvots ) > MAXDELTA) = [];
    absdvots = abs( dvots );
    dvotpos = linspace( min( dvots ), max( dvots ), style.bins( dvots ) );
    dvotns = hist( dvots, dvotpos );
	absdvotpos = linspace( min( absdvots ), max( absdvots ), style.bins( absdvots ) );
	absdvotns = hist( absdvots, absdvotpos );
    
    subplot( 2, 2, 1 );
    title( 'voice-onset time detection' );
    xlabel( 'delta in milliseconds' );
    ylabel( 'detection rate' );
    xlim( MAXDELTA * [-1, 1] );
    bar( dvotpos, dvotns / ndvots, ...
        'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    subplot( 2, 2, 2 );
    xlabel( 'abs( delta ) in milliseconds' );
    ylabel( 'cumulative rate' );
    xlim( MAXDELTA * [0, 1] );
	bar( absdvotpos, cumsum( absdvotns ) / ndvots, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    ndrelvots = numel( drelvots ); % plot relative voice-onset times
    drelvots(abs( drelvots ) > MAXRELDELTA) = [];
    absdrelvots = abs( drelvots );
    drelvotpos = linspace( min( drelvots ), max( drelvots ), style.bins( drelvots ) );
    drelvotns = hist( drelvots, drelvotpos );
	absdrelvotpos = linspace( min( absdrelvots ), max( absdrelvots ), style.bins( absdrelvots ) );
	absdrelvotns = hist( absdrelvots, absdrelvotpos );
    
    subplot( 2, 2, 3 );
    title( 'voice-onset time detection' );
    xlabel( 'delta in milliseconds' );
    ylabel( 'detection rate' );
    xlim( MAXRELDELTA * [-1, 1] );
    bar( drelvotpos, drelvotns / ndrelvots, ...
        'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    subplot( 2, 2, 4 );
    xlabel( 'abs( delta ) in milliseconds' );
    ylabel( 'cumulative rate' );
    xlim( MAXRELDELTA * [0, 1] );
	bar( absdrelvotpos, cumsum( absdrelvotns ) / ndrelvots, ...
		'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
    
    style.print( plotfile );
    delete( fig );
    
        % -------------------------------------------------------------------
        % vot accuracy statistics
    plotfile = fullfile( plotdir, 'sip16_acc.png' );
	logger.log( 'plot accuracy statistics ''%s''...', plotfile );
    
    fig = style.figure();
	
    absdbopos = linspace( min( absdbos ), max( absdbos ), numel( absdbos ) );
	absdbons = hist( absdbos, absdbopos );
    absdvopos = linspace( min( absdvos ), max( absdvos ), numel( absdvos ) );
	absdvons = hist( absdvos, absdvopos );
    absdvrpos = linspace( min( absdvrs ), max( absdvrs ), numel( absdvrs ) );
	absdvrns = hist( absdvrs, absdvrpos );
    absdvotpos = linspace( min( absdvots ), max( absdvots ), numel( absdvots ) );
	absdvotns = hist( absdvots, absdvotpos );
    absdrelvotpos = linspace( min( absdrelvots ), max( absdrelvots ), numel( absdrelvots ) );
	absdrelvotns = hist( absdrelvots, absdrelvotpos );
    
    xlabel( 'abs( delta ) in milliseconds' );
    ylabel( 'cumulative rate' );
	
    h1 = plot( absdbopos, cumsum( absdbons ) / ndbos, ...
		'Color', style.color( 'neutral', 0 ), 'LineStyle', '--', ...
        'DisplayName', 'burst-onsets' );
    h2 = plot( absdvopos, cumsum( absdvons ) / ndvos, ...
		'Color', style.color( 'neutral', 0 ), 'LineStyle', '-.', ...
        'DisplayName', 'voice-onsets' );
    h3 = plot( absdvrpos, cumsum( absdvrns ) / ndvrs, ...
		'Color', style.color( 'neutral', 0 ), 'LineStyle', ':', ...
        'DisplayName', 'voice-releases' );
    h4 = plot( absdvotpos, cumsum( absdvotns ) / ndvots, ...
		'Color', style.color( 'neutral', 0 ), 'LineWidth', 2, ...
        'DisplayName', 'voice-onset times' );
    
    legend( [h1, h2, h3, h4], 'Location', 'southeast' );
    
    style.print( plotfile );
    delete( fig );
            
		% cleanup
	logger.untab( 'done.' ); % stop logging

end

