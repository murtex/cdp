function trial_extract( run, cfg, trial, plotfile )
% plot trial extraction
%
% TRIAL_EXTRACT( run, cfg, trial, plotfile )
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
	logger.log( 'plot trial extraction ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set signals
	noiser = run.audiodata(trial.cue + (0:trial.soa-1), 1);
	respser = run.audiodata(trial.range(1):trial.range(2), 1);

		% get full bandwidth fft
	frame = dsp.msec2smp( cfg.sta_frame, run.audiorate );

	noift = sta.framing( noiser, frame, cfg.sta_wnd ); % noisy
	[noift, noifreqs] = sta.fft( noift, run.audiorate );
	[noift, noifreqs] = sta.banding( noift, noifreqs, cfg.sta_band );

	respft = sta.framing( respser, frame, cfg.sta_wnd ); % clean
	[respft, respfreqs] = sta.fft( respft, run.audiorate );
	[respft, respfreqs] = sta.banding( respft, respfreqs, cfg.sta_band );

		% set total powers
	resppow = sum( respft, 2 );

	noimax = max( noift, [], 1 ); % denoising
	n = size( respft, 1 );
	for i = 1:n
		respft(i, :) = respft(i, :) - noimax;
	end
	respft(respft < eps) = eps;

	respclpow = sum( respft, 2 );

		% smoothing
	resppow = sta.unframe( resppow, frame );
	resppow = resppow(1:size( respser, 1 ));

	respclpow = sta.unframe( respclpow, frame );
	respclpow = respclpow(1:size( respser, 1 ));

		% get activity
	[respact, lothresh, hithresh] = k15.activity( resppow, respclpow );

		% prepare plot
	zp = trial.cue;

	xs = dsp.smp2msec( (trial.range(1):trial.range(2))-zp, run.audiorate ); % axes
	xl = [min( xs ), max( xs )];

		% plot signal
	subplot( 4, 1, 1 );
	title( sprintf( 'subject: %d, trial: %d -- extraction', run.id, trial.id ) );
	ylabel( 'response' );

	xlim( xl );
	ylim( 1.1 * max( abs( respser ) ) * [-1, 1] );

	stairs( xs, respser, ...
		'Color', style.color( 'neutral', 0 ) );

		% plot powers
	subplot( 4, 1, 2:3 );
	ylabel( 'power' );

	xlim( xl );
	ylim( [pow2db( min( cat( 1, resppow, respclpow ) ) ), 0] );

	plot( xl, pow2db( lothresh ) * [1, 1], ... % thresholds
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );
	plot( xl, pow2db( hithresh ) * [1, 1], ...
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );

	h1 = stairs( xs, pow2db( resppow ), ... % powers
		'DisplayName', 'noisy', ...
		'Color', style.color( 'cold', +2 ) );
	h2 = stairs( xs, pow2db( respclpow ), ...
		'DisplayName', 'clean', ...
		'Color', style.color( 'warm', 0 ) );

	legend( [h2, h1] );

		% plot activity
	subplot( 4, 1, 4, 'YTick', [] );
	xlabel( 'milliseconds' );
	ylabel( 'activity' );

	xlim( xl );
	ylim( [0, 1.1] );

	stairs( xs, respact, ...
		'Color', style.color( 'warm', 0 ) );

	style.print( plotfile );
	delete( fig );
end

