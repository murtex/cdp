function trial_activity( run, cfg, id, plotfile )
% plot trial activity detection specifics
%
% TRIAL_ACTIVITY( run, cfg, id, plotfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% id : trial indentifier (scalar numeric)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isscalar( cfg ) || ~isa( cfg, 'cdf.hConfig' )
		error( 'invalid argument: cfg' );
	end

	if nargin < 3 || ~isscalar( id ) || ~isnumeric( id ) || id < 1 || id > numel( run.trials )
		error( 'invalid argument: id' );
	end

	if nargin < 4 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot trial activity (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% prepare data
	trial = run.trials(id);
	resp = run.resps_det(id);

	noir = dsp.sec2smp( [trial.cue, trial.dist], run.audiorate ) + [1, 0]; % signal ranges
	respr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0];

	if any( isnan( noir ) ) || any( isnan( respr ) )
		error( 'invalid value: noir | respr' );
	end

	noits = run.audiodata(noir(1):noir(2), 1); % signals
	cdts = run.audiodata(respr(1):respr(2), 2);
	respts = run.audiodata(respr(1):respr(2), 1);

	frlen = dsp.sec2smp( cfg.vad_frlength, run.audiorate ); % short-time ffts
	noifr = dsp.frame( noits, frlen, cfg.vad_froverlap, cfg.vad_frwindow );
	respfr = dsp.frame( respts, frlen, cfg.vad_froverlap, cfg.vad_frwindow );
	[noift, noifreqs] = dsp.fft( noifr, run.audiorate );
	[respft, respfreqs] = dsp.fft( respfr, run.audiorate );
	[noift, noifreqs] = dsp.band( noift, noifreqs, cfg.vad_freqband(1), cfg.vad_freqband(2), true ); % one-sided subband
	[respft, respfreqs] = dsp.band( respft, respfreqs, cfg.vad_freqband(1), cfg.vad_freqband(2), true );

	[respvafr, respfeatfr, respthreshs] = k15.vad( ... % activity
		respft, noift, cfg.vad_adjacency, cfg.vad_hangover );

	respva = round( dsp.unframe( respvafr, frlen, cfg.vad_froverlap ) ); % unframing

	xs = 1000 * dsp.smp2sec( 0:diff( respr ), run.audiorate ); % axes scaling
	xsufr = 1000 * dsp.smp2sec( 0:numel( respva )-1, run.audiorate );
	xsfr = 1000 * dsp.fr2sec( 0:size( respft, 2 )-1, frlen, cfg.vad_froverlap, run.audiorate );
	xl = [min( xs ), max( xs )];
	yl = max( abs( respts ) ) * style.scale( 1/2 ) * [-1, 1];

		% plot
	fig = style.figure();

	subplot( 20, 2, [1, 9], 'XTickLabel', {}, 'YTickLabel', {} ); % cue/distractor
	ylabel( 'cue/distractor' );
	xlim( xl );
	ylim( max( abs( cdts ) ) * style.scale( 1/2 ) * [-1, 1] );
	plot( xs, cdts, ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [11, 19], 'XTickLabel', {}, 'YTickLabel', {} ); % response
	ylabel( 'response' );
	xlim( xl );
	ylim( yl );
	stairs( xsufr, respva * style.scale( -1 ) * yl(2), ...
		'Color', style.color( 'warm', 0 ) );
	if ~any( isnan( resp.range ) )
		rectangle( 'Position', [ ...
			1000 * (resp.range(1) - trial.range(1)), style.scale( -1 ) * yl(1), ...
			1000 * diff( resp.range ), abs( style.scale( -1 ) * yl(1) )], ...
			'EdgeColor', style.color( 'warm', 0 ), 'FaceColor', style.color( 'warm', +2 ) );
	end
	plot( xs, respts, ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [21, 39] ); % spectrogram
	xlabel( 'trial-time in milliseconds' );
	ylabel( 'frequency in kilohertz' );
	xlim( xl );
	ylim( [min( respfreqs/1000 ), max( respfreqs/1000 )] );
	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
	imagesc( xsfr, respfreqs/1000, log( respft .* conj( respft ) + eps ) );

	subplot( 20, 2, [2, 8], 'XTickLabel', {}, 'YTickLabel', {} ); % static distance
	ylabel( 'static' );
	xlim( xl );
	plot( xl, respthreshs(1) * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respfeatfr(1, :), ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [10, 16], 'XTickLabel', {}, 'YTickLabel', {} ); % flatness
	ylabel( 'flatness' );
	xlim( xl );
	plot( xl, respthreshs(2) * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respfeatfr(2, :), ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [18, 24], 'XTickLabel', {}, 'YTickLabel', {} ); % dynamic distance 1
	ylabel( 'dynamic 1' );
	xlim( xl );
	plot( xl, respthreshs(3) * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respfeatfr(3, :), ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [26, 32], 'XTickLabel', {}, 'YTickLabel', {} ); % dynamic distance 2
	ylabel( 'dynamic 2' );
	xlim( xl );
	plot( xl, respthreshs(4) * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respfeatfr(4, :), ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 20, 2, [34, 40], 'YTickLabel', {} ); % weighted sum
	xlabel( 'trial-time in milliseconds' );
	ylabel( 'weighted' );
	xlim( xl );
	plot( xl, respthreshs(5) * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respfeatfr(5, :), ...
		'Color', style.color( 'cold', -1 ) );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

