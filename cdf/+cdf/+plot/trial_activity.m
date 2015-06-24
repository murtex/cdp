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

	noir = dsp.sec2smp( [trial.range(1), trial.dist], run.audiorate ) + [1, 0]; % signal ranges
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

	[respvafr, respsdfr, respddfr, respsdthresh, respddthresh] = k15.vad( ... % activity
		respft, noift, cfg.vad_adjacency, cfg.vad_hangover );

	respva = round( dsp.unframe( respvafr, frlen, cfg.vad_froverlap ) ); % unframing

	xs = 1000 * dsp.smp2sec( 0:diff( respr ), run.audiorate ); % axes scaling
	xsufr = 1000 * dsp.smp2sec( 0:numel( respva )-1, run.audiorate );
	xsfr = 1000 * dsp.fr2sec( 0:size( respft, 2 )-1, frlen, cfg.vad_froverlap, run.audiorate );
	xl = [min( xs ), max( xs )];
	yl = max( abs( respts ) ) * style.width( 1/2 ) * [-1, 1];

		% plot
	fig = style.figure();

	subplot( 4, 2, 1, 'XTickLabel', {} ); % cue/distractor signal
	ylabel( 'cue/distractor' );
	xlim( xl );
	ylim( max( abs( cdts ) ) * style.width( 1/2 ) * [-1, 1] );
	plot( xs, cdts, ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 4, 2, 3, 'XTickLabel', {} ); % response signal
	ylabel( 'response' );
	xlim( xl );
	ylim( yl );
	plot( xsufr, respva * 0.5 * yl(2), ...
		'Color', style.color( 'warm', 0 ) );
	plot( xs, respts, ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 4, 2, [5, 7] ); % spectrogram
	xlabel( 'trial-time in milliseconds' );
	ylabel( 'frequency in hertz' );
	xlim( xl );
	ylim( [min( respfreqs ), max( respfreqs )] );
	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
	imagesc( xsfr, respfreqs, log( respft .* conj( respft ) ) );

	subplot( 4, 2, [2, 4], 'XTickLabel', {} ); % static distance
	ylabel( 'static spectral distance' );
	xlim( xl );
	plot( xl, respsdthresh * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respsdfr, ...
		'Color', style.color( 'cold', -1 ) );

	subplot( 4, 2, [6, 8] ); % dynamic distance
	xlabel( 'trial-time in milliseconds' );
	ylabel( 'dynamic spectral distance' );
	xlim( xl );
	plot( xl, respddthresh * [1, 1], ...
		'Color', style.color( 'warm', 0 ) );
	plot( xsfr, respddfr, ...
		'Color', style.color( 'cold', -1 ) );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

