function trial( run, cfg, id, plotfile )
% plot cue-distractor trial
%
% TRIAL( run, cfg, id, plotfile )
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
	logger.tab( 'plot trial (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% prepare data
	trial = run.trials(id);
	resp_det = run.resps_det(id);
	resp_lab = run.resps_lab(id);

	tr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % trial range
	if any( isnan( tr ) )
		error( 'invalid value: tr' );
	end

	cdts = run.audiodata(tr(1):tr(2), 2); % signals
	respts = run.audiodata(tr(1):tr(2), 1);

	frlen = dsp.sec2smp( cfg.dbg_frlength, run.audiorate ); % short-time fft
	respfr = dsp.frame( respts, frlen, cfg.dbg_froverlap, cfg.dbg_frwindow );
	[respft, respfreqs] = dsp.fft( respfr, run.audiorate );

	respft = dsp.unframe( respft, frlen, cfg.dbg_froverlap );

	xl = 1000 * [0, diff( trial.range )]; % axes scaling
	xs = 1000 * dsp.smp2sec( 0:diff( tr ), run.audiorate );
	frxs = 1000 * dsp.smp2sec( 0:size( respft, 2 )-1, run.audiorate );
	yl = max( abs( cat( 1, cdts, respts ) ) ) * style.width( 1/2 ) * [-1, 1];

		% plot
	fig = style.figure();

	subplot( 4, 2, 1:2, 'XTickLabel', {} ); % cue/distractor signal
	ylabel( 'distractor' );
	xlim( xl );
	ylim( yl );
	plot( xs, cdts, ...
		'Color', style.color( 'cold', +1 ) );

	subplot( 4, 2, 3:4, 'XTickLabel', {} ); % response signal
	ylabel( 'response' );
	xlim( xl );
	ylim( yl );
	plot( xs, respts, ...
		'Color', style.color( 'cold', +1 ) );

	subplot( 4, 2, 5:8 ); % response spectrogram
	xlabel( 'trial time in milliseconds' );
	ylabel( 'frequency in hertz' );
	xlim( xl );
	ylim( [-8000, 0] );
	colormap( style.gradient( 64, [1, 1, 1], style.color( 'cold', -2 ) ) );
	imagesc( frxs, respfreqs, log( respft .* conj( respft ) ) );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

