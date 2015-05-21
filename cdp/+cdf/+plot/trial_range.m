function trial_range( run, cfg, trial, range, rzp, plotfile )
% plot trial range
%
% TRIAL_RANGE( run, cfg, trial, range, plotfile )
%
% INPUT
% run : run (scalar object)
% cfg : configuration (scalar object)
% trial : trial (scalar object)
% range : plot range (pair numeric)
% rzp : range zero point (scalar numeric)
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

	if nargin < 4 || numel( range ) ~= 2 || ~isnumeric( range )
		error( 'invalid argument: range' );
	end

	if nargin < 5 || ~isscalar( rzp ) || ~isnumeric( rzp )
		error( 'invalid argument: rzp' );
	end

	if nargin < 6 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.log( 'plot trial range ''%s''...', plotfile );

	style = xis.hStyle.instance();
	fig = style.figure();

		% set signals
	distser = run.audiodata(range(1):range(2), 2);
	respser = run.audiodata(range(1):range(2), 1);

		% get full bandwidth fft
	frame = dsp.msec2smp( cfg.sta_frame, run.audiorate );

	respft = sta.framing( respser, frame, cfg.sta_wnd );
	[respft, freqs] = sta.fft( respft, run.audiorate );
	[respft, freqs] = sta.banding( respft, freqs, cfg.sta_band );

		% smoothing
	respft = sta.unframe( respft, frame );

		% prepare plot
	xs = dsp.smp2msec( (range(1):range(2))-rzp, run.audiorate ); % axes
	xl = [min( xs ), max( xs )];
	yl = 1.1 * max( abs( cat( 1, distser, respser ) ) ) * [-1, 1];

		% plot distractor
	subplot( 4, 1, 1 );
	title( sprintf( 'subject: %d, trial: %d -- range', run.id, trial.id ) );
	ylabel( 'distractor' );

	xlim( xl );
	ylim( yl );

	stem( dsp.smp2msec( trial.cue-rzp, run.audiorate ), yl(2), ... % landmarks
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );
	stem( dsp.smp2msec( trial.cue+trial.soa-rzp, run.audiorate ), yl(2), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );
	stem( dsp.smp2msec( trial.distvo-rzp, run.audiorate ), yl(2), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );

	h = stairs( xs, distser, ... % signal
		'DisplayName', sprintf( '''%s''/''%s''', trial.cuelabel, trial.distlabel ), ...
		'Color', style.color( 'neutral', 0 ) );

	l = legend( h );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot response
	subplot( 4, 1, 2 );
	ylabel( 'response' );

	xlim( xl );
	ylim( yl );

	if ~any( isnan( trial.labeled.range ) ) % ranges
		rectangle( 'Position', [...
				dsp.smp2msec( trial.labeled.range(1)-rzp, run.audiorate ), 0, ...
				dsp.smp2msec( diff( trial.labeled.range )+1, run.audiorate ), diff( yl )/2], ...
			'EdgeColor', style.color( 'cold', 0 ), 'FaceColor', style.color( 'cold', +2 ) );
	end
	if ~any( isnan( trial.detected.range ) )
		rectangle( 'Position', [...
				dsp.smp2msec( trial.detected.range(1)-rzp, run.audiorate ), yl(1), ...
				dsp.smp2msec( diff( trial.detected.range )+1, run.audiorate ), diff( yl )/2], ...
			'EdgeColor', style.color( 'warm', 0 ), 'FaceColor', style.color( 'warm', +2 ) );
	end

	stem( dsp.smp2msec( trial.labeled.bo-rzp, run.audiorate ), yl(2), ... % landmarks
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );
	stem( dsp.smp2msec( trial.labeled.vo-rzp, run.audiorate ), yl(2), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );
	stem( dsp.smp2msec( trial.labeled.vr-rzp, run.audiorate ), yl(2), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ), ...
		'Color', style.color( 'cold', 0 ) );
	stem( dsp.smp2msec( trial.detected.bo-rzp, run.audiorate ), yl(1), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'warm', -2 ), 'MarkerFaceColor', style.color( 'warm', +1 ), ...
		'Color', style.color( 'warm', 0 ) );
	stem( dsp.smp2msec( trial.detected.vo-rzp, run.audiorate ), yl(1), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'warm', -2 ), 'MarkerFaceColor', style.color( 'warm', +1 ), ...
		'Color', style.color( 'warm', 0 ) );
	stem( dsp.smp2msec( trial.detected.vr-rzp, run.audiorate ), yl(1), ...
		'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'warm', -2 ), 'MarkerFaceColor', style.color( 'warm', +1 ), ...
		'Color', style.color( 'warm', 0 ) );

	h = stairs( xs, respser, ... % signal
		'DisplayName', sprintf( '''%s''/''%s''', trial.labeled.label, trial.detected.label ), ...
		'Color', style.color( 'neutral', 0 ) );

	l = legend( h );
	set( l, 'Color', style.color( 'grey', 0.96 ) );

		% plot full bandwidth spectrogram
	subplot( 4, 1, 3:4 );
	xlabel( 'milliseconds' );
	ylabel( 'full bandwidth' );

	xlim( xl );
	ylim( [freqs(1), freqs(end)] );

	colormap( style.gradient( 64, [1, 1, 1], style.color( 'neutral', -0.5 ) ) ); % spectrogram
	imagesc( dsp.smp2msec( 0:size( respft, 1 )-1, run.audiorate ), freqs, log( respft' ) );

	plot( ... % landmarks
		dsp.smp2msec( [trial.labeled.bo, trial.labeled.vo, trial.labeled.vr]-rzp, run.audiorate ), ...
		min( freqs ) * [1, 1, 1], ...
		'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'cold', -2 ), 'MarkerFaceColor', style.color( 'cold', +1 ) );
	plot( ...
		dsp.smp2msec( [trial.detected.bo, trial.detected.vo, trial.detected.vr]-rzp, run.audiorate ), ...
		min( freqs ) * [1, 1, 1], ...
		'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 2*style.width( +1 ), ...
		'MarkerEdgeColor', style.color( 'warm', -2 ), 'MarkerFaceColor', style.color( 'warm', +1 ) );


	style.print( plotfile );
	delete( fig );
end

