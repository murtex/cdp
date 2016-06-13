function sip16( indir, ids, labels )
% landmark detection statistics (IEEE SIP 2016)
%
% sip16( indir, ids, labels={} )
%
% INPUT
% indir : input directory (row char)
% ids : subject identifiers (row numeric)
% labels : response labels (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir )
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
    end
    
    if nargin < 3
        labels = {};
    elseif ~iscellstr( labels )
        error( 'invalid argument: labels' );
    end
    
		% include cue-distractor package
	addpath( '../../cdp/' );
    
		% prepare for output
	statsdir = fullfile( indir, 'stats' );
    if numel( labels ) == 1
        statsdir = fullfile( statsdir, labels{1} );
    end
	if exist( statsdir, 'dir' ) ~= 7
		mkdir( statsdir );
    end

	subjdir = fullfile( statsdir, 'subjects' );
	if exist( subjdir, 'dir' ) ~= 7
		mkdir( subjdir );
	end

    style = xis.hStyle.instance();
    
	logger = xis.hLogger.instance( fullfile( statsdir, sprintf( '%d-%d.log', min( ids ), max( ids ) ) ) ); % start logging
	logger.tab( 'sip16 statistics...' );

		% configure framework
	cfg = cdf.hConfig(); % use defaults

		% -------------------------------------------------------------------
		% helper functions
    MAXDELTA = 15;
    MAXVOT = 180;
	MAXLEN = 650;
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
    global prefvots nprefvots prefvotpos prefvotns
    global pvots npvots pvotpos pvotns
    global preflens npreflens preflenpos preflenns
    global plens nplens plenpos plenns

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
        
            % vot distribution
        prefvots = sta.smp2msec( refvots, audiorate ); % absolute vot
        pvots = sta.smp2msec( vots, audiorate );
		prefvots(isnan( prefvots )) = [];
		pvots(isnan( pvots )) = [];
        
        nprefvots = numel( prefvots ); % binning
        prefvots(prefvots > MAXVOT) = [];
        npvots = numel( pvots );        
        pvots(pvots > MAXVOT) = [];

        bmin = min( prefvots );
        bmax = max( prefvots );
        nbins = round( BINFACTOR * max( style.bins( prefvots ), style.bins( pvots ) ) );

        prefvotpos = linspace( bmin, bmax, nbins );
		prefvotns = hist( prefvots, prefvotpos );
		pvotpos = linspace( bmin, bmax, nbins );
		pvotns = hist( pvots, pvotpos );
        
            % len distribution
        preflens = sta.smp2msec( reflens, audiorate ); % absolute length
        plens = sta.smp2msec( lens, audiorate );
		preflens(isnan( preflens )) = [];
		plens(isnan( plens )) = [];
        
        npreflens = numel( preflens ); % binning
        preflens(preflens > MAXLEN) = [];
        nplens = numel( plens );        
        plens(plens > MAXLEN) = [];

        bmin = min( preflens );
        bmax = max( preflens );
        nbins = round( BINFACTOR * max( style.bins( preflens ), style.bins( plens ) ) );

        preflenpos = linspace( bmin, bmax, nbins );
		preflenns = hist( preflens, preflenpos );
		plenpos = linspace( bmin, bmax, nbins );
		plenns = hist( plens, plenpos );
        
	end

	function logstats()

			% overall
    	logger.tab( 'overall statistics' );
		logger.log( 'ref. burst-onsets: %d', nrefbos );
		logger.log( 'ref. voice-onsets: %d', nrefvos );
		logger.log( 'ref. voice-releases: %d', nrefvrs );
		logger.log( 'ref. voice-onset times: %d', nrefvots );
		logger.log( 'ref. vowel-lengths: %d', nreflens );
		logger.log( 'burst-onsets: %d', nbos );
		logger.log( 'voice-onsets: %d', nvos );
		logger.log( 'voice-releases: %d', nvrs );    
		logger.log( 'voice-onset times: %d', nvots );
		logger.log( 'vowel-lengths: %d', nlens );
    	logger.untab();
    
			% deletions
		logger.tab( 'deletion statistics' );
		logger.log( 'burst-onset (rate): %d (%.3f)', nbodels, nbodels/nrefbos );
		logger.log( 'voice-onset (rate): %d (%.3f)', nvodels, nvodels/nrefvos );
		logger.log( 'voice-release (rate): %d (%.3f)', nvrdels, nvrdels/nrefvrs );
		logger.log( 'voice-onset time (rate): %d (%.3f)', nvotdels, nvotdels/nrefvots );
		logger.log( 'vowel-length (rate): %d (%.3f)', nlendels, nlendels/nreflens );
		logger.untab();    

			% insertions
		logger.tab( 'insertion statistics' );
		logger.log( 'burst-onset (rate): %d (%.3f)', nboins, nboins/nrefbos );
		logger.log( 'voice-onset (rate): %d (%.3f)', nvoins, nvoins/nrefvos );
		logger.log( 'voice-release (rate): %d (%.3f)', nvrins, nvrins/nrefvrs );
		logger.log( 'voice-onset time (rate): %d (%.3f)', nvotins, nvotins/nrefvots );
		logger.log( 'vowel-length (rate): %d (%.3f)', nlenins, nlenins/nreflens );
		logger.untab();

			% accuracy
		logger.tab( 'accuracy statistics (+/-5ms, +/-10ms, +/-15ms)' );
		
		logger.log( 'burst-onset: %.3f, %.3f, %.3f', ...
            sum( absdbons(absdbopos <= 5) ) / ndbos, sum( absdbons(absdbopos <= 10) ) / ndbos, sum( absdbons(absdbopos <= 15) ) / ndbos );
		logger.log( 'voice-onset: %.3f, %.3f, %.3f', ...
            sum( absdvons(absdvopos <= 5) ) / ndvos, sum( absdvons(absdvopos <= 10) ) / ndvos, sum( absdvons(absdvopos <= 15) ) / ndvos );
  		logger.log( 'voice-release: %.3f, %.3f, %.3f', ...
              sum( absdvrns(absdvrpos <= 5) ) / ndvrs, sum( absdvrns(absdvrpos <= 10) ) / ndvrs, sum( absdvrns(absdvrpos <= 15) ) / ndvrs );
		logger.log( 'voice-onset time: %.3f, %.3f, %.3f', ...
            sum( absdvotns(absdvotpos <= 5) ) / ndvots, sum( absdvotns(absdvotpos <= 10) ) / ndvots, sum( absdvotns(absdvotpos <= 15) ) / ndvots );
 		logger.log( 'vowel-length: %.3f, %.3f, %.3f', ...
			sum( absdlenns(absdlenpos <= 5) ) / ndlens, sum( absdlenns(absdlenpos <= 10) ) / ndlens, sum( absdlenns(absdlenpos <= 15) ) / ndlens );
		
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

		fig = style.figure( 'PaperPosition', plottile( 6, 4.5 ) );
		
		subplot( 3, 2, 1 ); % burst-onset
		title( 'burst-onset (+b) detection' );
		ylabel( '^rate' );
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
		ylabel( 'rate' );
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
		ylabel( 'rate' );
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

		fig = style.figure( 'PaperPosition', plottile( 6, 3 ) );
		
		subplot( 2, 2, 1 ); % voice-onset time
		title( 'voice-onset time detection' );
		ylabel( 'rate' );
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
		ylabel( 'rate' );
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
		
		fig = style.figure( 'PaperPosition', plottile( 6, 6 ) );

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

    function plotstats4( plotfile )
		logger.log( 'plot distribution statistics ''%s''...', plotfile );
		
		fig = style.figure( 'PaperPosition', plottile( 6, 6 ) );

		h1 = subplot( 2, 1, 1 ); % detection
		title( 'detection distribution' );
		ylabel( 'rate' );
        xlim( MAXVOT * [0, 1] );
		bar( pvotpos, pvotns / npvots, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
        
		h2 = subplot( 2, 1, 2 ); % labeling
		title( 'labeling distribution' );
        xlabel( 'voice-onset time in milliseconds' );
		ylabel( 'rate' );
        xlim( MAXVOT * [0, 1] );
		bar( prefvotpos, prefvotns / nprefvots, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
        yl1 = ylim( h1 ); % adjust axes limits
        yl2 = ylim( h2 );
        yl = [min( yl1(1), yl2(1) ), max( yl1(2), yl2(2) )];
        ylim( h1, yl );
        ylim( h2, yl );

		style.print( plotfile );
		delete( fig );
    end

    function plotstats5( plotfile )
		logger.log( 'plot distribution statistics ''%s''...', plotfile );
		
		fig = style.figure( 'PaperPosition', plottile( 6, 8 ) );

		h1 = subplot( 2, 1, 1 ); % detection
		title( 'detection distribution' );
		ylabel( 'rate' );
        xlim( MAXLEN * [0, 1] );
		bar( plenpos, plenns / nplens, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
        
		h2 = subplot( 2, 1, 2 ); % labeling
		title( 'labeling distribution' );
		xlabel( 'vowel-length in milliseconds' );
		ylabel( 'rate' );
        xlim( MAXLEN * [0, 1] );
		bar( preflenpos, preflenns / npreflens, ...
			'BarWidth', 1, 'FaceColor', style.color( 'neutral', 0 ), 'EdgeColor', 'none' );
		
        yl1 = ylim( h1 ); % adjust axes limits
        yl2 = ylim( h2 );
        yl = [min( yl1(1), yl2(1) ), max( yl1(2), yl2(2) )];
        ylim( h1, yl );
        ylim( h2, yl );

		style.print( plotfile );
		delete( fig );
    end

    function plottrial( plotfile, run, trial )
		logger.log( 'plot example trial ''%s''...', plotfile );
		
		fig = style.figure( 'PaperPosition', plottile( 6, 12 ) );
        
            % prepare data
        refrange = trial.labeled.range; % range
        refrange = refrange + sta.msec2smp( 25, run.audiorate ) * [-1, 2];
        refrange(1) = max( 1, refrange(1) );
        refrange(2) = min( run.audiolen, refrange(2) );
        
		respser = run.audiodata(refrange(1):refrange(2), 1); % signal
        
		frame = sta.msec2smp( cfg.sta_frame, run.audiorate ); % short-time fft
		respft = sta.framing( respser, frame, cfg.sta_wnd );
		[respft, respfreqs] = sta.fft( respft, run.audiorate );
		respft(:, 2:end) = 2*respft(:, 2:end);
		[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.glottis_band );
        
		respft(respft < eps) = eps; % maximum power
		resppow = max( respft, [], 2 );
        
		resppow = sta.unframe( resppow, frame ); % smoothing
		resppow = resppow(1:size( respser, 1 ));

		cfg.glottis_rorpeak = 4; % ror and peaks
		cfg.schwa_power = -18;
		rordt = sta.msec2smp( cfg.glottis_rordt, run.audiorate );
		respror = k15.ror( pow2db( resppow ), rordt );
		resppeak = k15.peak( respror, cfg.glottis_rorpeak );
		%respglottis = k15.peak_glottis( resppeak, pow2db( resppow ), respror, ...
			%sta.msec2smp( cfg.schwa_length, run.audiorate ), cfg.schwa_power );
		respglottis = k15.peakg( resppeak, pow2db( resppow ), respror, ...
			sta.msec2smp( cfg.schwa_length, run.audiorate ), cfg.schwa_power );
        
		resppi = k15.plosion( ... % plosion index
			k15.replaygain( respser, run.audiorate ), ...
			sta.msec2smp( cfg.plosion_delta, run.audiorate ), sta.msec2smp( cfg.plosion_width, run.audiorate ) );

			% helper functions
		function msec = smp2msec( smp )
			msec = sta.smp2msec( smp - refrange(1), run.audiorate );
		end
        
            % plot landmarks and waveform
        h = subplot( 4, 1, 1 );
        title( sprintf( '''%s'' (%s)', trial.labeled.label, strrep( strrep( run.sex, 'm', 'male' ), 'w', 'female' ) ) );
        ylabel( 'amplitude' );
        xlim( smp2msec( [refrange(1), refrange(2)] ) );
		yl = 1.2 * max( abs( respser ) ) * [-1, 1];
		ylim( yl );
        plot( smp2msec( trial.detected.bo * [1, 1] ), [0, yl(2)], ... % detected landmarks
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( trial.detected.vo * [1, 1] ), [0, yl(2)], ...
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( trial.detected.vr * [1, 1] ), [0, yl(2)], ...
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( trial.labeled.bo * [1, 1] ), [yl(1), 0], ... % labeled landmarks
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( trial.labeled.vo * [1, 1] ), [yl(1), 0], ...
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( trial.labeled.vr * [1, 1] ), [yl(1), 0], ...
            'Color', style.color( 'neutral', 0 ) );
        plot( smp2msec( refrange(1):refrange(2) ), respser, ... % waveform
            'Color', style.color( 'neutral', 0 ) );
        
            % plot plosion index
        subplot( 4, 1, 2 );
        ylabel( 'plosion index' );
        xlim( smp2msec( [refrange(1), refrange(2)] ) );
        plot( smp2msec( refrange(1):refrange(2) ), resppi, ...
            'Color', style.color( 'neutral', 0 ) );        

            % plot power
        subplot( 4, 1, 3 );
        ylabel( 'band power' );
        xlim( smp2msec( [refrange(1), refrange(2)] ) );
        plot( smp2msec( refrange(1):refrange(2) ), pow2db( resppow ), ...
            'Color', style.color( 'neutral', 0 ) );
        
            % plot peaks and ror
        subplot( 4, 1, 4 );
        xlabel( 'time in milliseconds' );
        ylabel( 'rate-of-rise' );
        xlim( smp2msec( [refrange(1), refrange(2)] ) );
        stem( smp2msec( respglottis + refrange(1) - 1 ), respror(respglottis), ... % glottal peaks
            'Color', style.color( 'neutral', 0 ), 'LineStyle', '--', ...
            'MarkerFaceColor', style.color( 'neutral', 0 ), 'MarkerSize', 1 );
        stem( smp2msec( resppeak + refrange(1) - 1 ), respror(resppeak), ... % ror peaks
            'Color', style.color( 'neutral', 0 ), 'LineStyle', '-', ...
            'MarkerFaceColor', style.color( 'neutral', 0 ), 'MarkerSize', 1 );
        plot( smp2msec( refrange(1):refrange(2) ), respror, ... % ror
            'Color', style.color( 'neutral', 0 ) );
        
		style.print( plotfile );
		delete( fig );
    end

        % -------------------------------------------------------------------
        % statistics
    audiorate = NaN;
    
    refbos = []; % landmarks and intervals
    refvos = [];
    refvrs = [];
    refvots = [];
    reflens = [];
    
    bos = [];
    vos = [];
    vrs = [];
    vots = [];
    lens = [];
    
    ndubious = 0;
    
		% proceed subjects
    si = [];
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

        if numel( labels ) > 0 % invalidation by response label
            for j = 1:numel( labtrials )
                if ~any( strcmp( run.trials(j).labeled.label, labels ) )
                    labtrials(j).bo = NaN;
                    labtrials(j).vo = NaN;
                    labtrials(j).vr = NaN;
                    dettrials(j).bo = NaN;
                    dettrials(j).vo = NaN;
                    dettrials(j).vr = NaN;
                end
            end
        end
        
		for j = 1:numel( labtrials ) % invalidate dubious labeled trials
			if sta.smp2msec( labtrials(j).vo - labtrials(j).bo, run.audiorate ) > 150
				labtrials(j).bo = NaN;
				labtrials(j).vo = NaN;
				labtrials(j).vr = NaN;
				dettrials(j).bo = NaN;
				dettrials(j).vo = NaN;
				dettrials(j).vr = NaN;
				ndubious = ndubious + 1;
			end
		end
        
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
		logstats();
		plotstats1( fullfile( subjdir, sprintf( 'sip16_fig1_%02d.eps', i ) ) );
		plotstats2( fullfile( subjdir, sprintf( 'sip16_fig2_%02d.eps', i ) ) );
		plotstats3( fullfile( subjdir, sprintf( 'sip16_fig3_%02d.eps', i ) ) );
		plotstats4( fullfile( subjdir, sprintf( 'sip16_fig4_%02d.eps', i ) ) );
		plotstats5( fullfile( subjdir, sprintf( 'sip16_fig5_%02d.eps', i ) ) );

			% cleanup
		delete( run );

            % contiunue
        si(end+1) = i;   
		logger.untab();
    end

		% log and plot global stats
	stats( refbos(:), refvos(:), refvrs(:), refvots(:), reflens(:), ...
		bos(:), vos(:), vrs(:), vots(:), lens(:) );
	logstats();
	logger.log( 'dubious trials: %d', ndubious );
	plotstats1( fullfile( statsdir, 'sip16_fig1_all.eps' ) );
	plotstats2( fullfile( statsdir, 'sip16_fig2_all.eps' ) );
	plotstats3( fullfile( statsdir, 'sip16_fig3_all.eps' ) );
	plotstats4( fullfile( statsdir, 'sip16_fig4_all.eps' ) );
	plotstats5( fullfile( statsdir, 'sip16_fig5_all.eps' ) );

        % plot best/worst trials
    nexamples = 10;
    
    ci = 1;
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
        
        read_audio( run, run.audiofile, false );
        
            % pick best/worst detections
        d1 = abs( bos(ci, :) - refbos(ci, :) );
        d2 = abs( vos(ci, :) - refvos(ci, :) );
        d3 = abs( vrs(ci, :) - refvrs(ci, :) );
        d4 = abs( vots(ci, :) - refvots(ci, :) );
        d5 = abs( lens(ci, :) - reflens(ci, :) );
        d = d1.^2 + d2.^2 + d3 + d4.^2 + d5;
        
        [d, tj] = sort( d, 'ascend' );
        tj(isnan( d )) = [];
        tj(nexamples+1:end) = [];
        
        cj = 1;
        for j = tj
            plotfile = fullfile( statsdir, sprintf( 'example%02d_%02d_%04d.eps', cj, i, j ) );
            plottrial( plotfile, run, run.trials(j) );
            cj = cj + 1;
        end
        
			% cleanup
		delete( run );
    
            % continue
        ci = ci + 1;
		logger.untab();        
    end

		% cleanup
	logger.untab( 'done.' ); % stop logging

end
