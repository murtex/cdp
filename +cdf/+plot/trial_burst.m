function trial_burst( run, cfg, trial, plotfile )
% plot trial burst landmark detection
%
% TRIAL_BURST( run, cfg, trial, plotfile )
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
	logger.log( 'plot trial burst ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set signal
	respser = run.audiodata(trial.detected.range(1):trial.detected.range(2), 1);

		% get plosion indices
	resppiser = respser;
	if ~isnan( trial.detected.vo )
		resppiser(trial.detected.vo-trial.detected.range(1)+1:end) = []; % restrict detection range
	end

	resppi = k15.plosion( ...
		k15.replaygain( resppiser, run.audiorate ), ...
		dsp.msec2smp( cfg.plosion_delta, run.audiorate ), dsp.msec2smp( cfg.plosion_width, run.audiorate ) );

	resppi = cat( 1, resppi, zeros( numel( respser )-numel( resppi ), 1 ) );

		% prepare plot
	zp = trial.detected.range(1);

	xs = dsp.smp2msec( (trial.detected.range(1):trial.detected.range(2))-zp, run.audiorate ); % axes
	xl = [min( xs ), max( xs )];

		% plot signal
	subplot( 3, 1, 1 );
	title( sprintf( 'subject: %d, trial: %d -- burst', run.id, trial.id ) );
	ylabel( 'response' );

	xlim( xl );
	ylim( 1.1 * max( abs( respser ) ) * [-1, 1] );

	stairs( xs, respser, ...
		'Color', style.color( 'neutral', 0 ) );

		% plot plosion indices
	subplot( 3, 1, 2:3 );
	xlabel( 'milliseconds' );
	ylabel( 'plosion index' );

	xlim( xl );

	plot( xl, cfg.plosion_threshs(1) * [1, 1], ... % thresholds
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );
	plot( xl, cfg.plosion_threshs(2) * [1, 1], ...
		'LineStyle', '--', 'Color', style.color( 'neutral', +2 ) );

	stairs( xs, resppi, ... % plosion
		'Color', style.color( 'warm', 0 ) );

	style.print( plotfile );
	delete( fig );
end

