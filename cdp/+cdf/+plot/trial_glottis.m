function trial_glottis( run, cfg, trial, plotfile )
% plot trial glottis landmark detection
%
% TRIAL_GLOTTIS( run, cfg, trial, plotfile )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% trial : trial (scalar object)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( trial ) || ~isa( trial, 'cdf.hTrial' )
		error( 'invalid argument: trial' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot trial glottis ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set signals
	noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
	respser = run.audiodata(trial.detected.range(1):trial.detected.range(2), 1);

		% get subband fft
	frame = sta.msec2smp( cfg.sta_frame, run.audiorate );

	noift = sta.framing( noiser, frame, cfg.sta_wnd );
	[noift, noifreqs] = sta.fft( noift, run.audiorate );
	[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.glottis_band );

	respft = sta.framing( respser, frame, cfg.sta_wnd );
	[respft, respfreqs] = sta.fft( respft, run.audiorate );
	[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.glottis_band );

		% set maximum powers
	resppow = max( respft, [], 2 );

	noimax = max( noift, [], 1 ); % denoising
	respclft = respft;
	n = size( respclft, 1 );
	for i = 1:n
		respclft(i, :) = respclft(i, :) - noimax;
	end
	respclft(respclft < eps) = eps;

	respclpow = max( respclft, [], 2 );

		% smoothing
	respft = sta.unframe( respft, frame );

	resppow = sta.unframe( resppow, frame );
	resppow = resppow(1:size( respser, 1 ));

	respclpow = sta.unframe( respclpow, frame );
	respclpow = respclpow(1:size( respser, 1 ));

		% get ror and peaks
	rordt = sta.msec2smp( cfg.glottis_rordt, run.audiorate );

	respror = k15.ror( pow2db( respclpow ), rordt );

	resppeak = k15.peak( respror, cfg.glottis_rorpeak );
	respglottis = k15.peak_glottis( resppeak, pow2db( respclpow ), respror, ...
		sta.msec2smp( cfg.schwa_length, run.audiorate ), cfg.schwa_power );

		% prepare plot
	zp = trial.detected.range(1);

	xs = sta.smp2msec( (trial.detected.range(1):trial.detected.range(2))-zp, run.audiorate ); % axes
	xl = [min( xs ), max( xs )];

		% plot subband spectrogram
	subplot( 4, 1, 1 );
	ylabel( 'subband' );

	xlim( xl );
	ylim( [respfreqs(1), respfreqs(end)] );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -0.5 ) ) );
	imagesc( sta.smp2msec( 0:size( respft, 1 )-1, run.audiorate ), respfreqs, log( respft' ) );

		% plot powers
	subplot( 4, 1, 2 );
	ylabel( 'power' );

	xlim( xl );
	ylim( [pow2db( min( cat( 1, resppow, respclpow ) ) ), 0] );

	plot( xl, (pow2db( max( respclpow ) ) + cfg.schwa_power) * [1, 1], ... % threshold
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );

	h1 = stairs( xs, pow2db( resppow ), ... % powers
		'DisplayName', 'noisy', ...
		'Color', style.color( 'cold', +2 ) );
	h2 = stairs( xs, pow2db( respclpow ), ...
		'DisplayName', 'clean', ...
		'Color', style.color( 'warm', 0 ) );

	if any( resppow < 10*eps ) || any( respclpow < 10*eps )
		l = legend( [h2, h1], 'Location', 'SouthWest' );
	else
		l = legend( [h2, h1], 'Location', 'NorthWest' );
	end
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot ror and peaks
	subplot( 4, 1, 3:4 );
	xlabel( 'milliseconds' );
	ylabel( 'ror' );

	xlim( xl );
	yl = 1.1 * 4 * cfg.glottis_rorpeak;
	yl = 1.1 * max( abs( respror ) );
	ylim( yl * [-1, 1] );

	plot( xl, cfg.glottis_rorpeak * [1, 1], ... % thresholds
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );
	plot( xl, cfg.glottis_rorpeak * [-1, -1], ...
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );

	if ~isempty( resppeak ) % peaks
		stem( sta.smp2msec( resppeak-1, run.audiorate ), 2*((respror(resppeak) > 0)-0.5) * yl, ...
			'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
			'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
			'Color', style.color( 'cold', 0 ) );
	end
	if ~isempty( respglottis )
		stem( sta.smp2msec( respglottis-1, run.audiorate ), repmat( [1, -1], 1, numel( respglottis )/2 ) * yl, ...
			'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
			'MarkerEdgeColor', style.color( 'warm', -2 ), 'MarkerFaceColor', style.color( 'warm', +1 ), ...
			'Color', style.color( 'warm', 0 ) );
	end

	stairs( xs, respror, ... % ror
		'Color', style.color( 'neutral', 0 ) );

	style.print( plotfile );
	delete( fig );
end

