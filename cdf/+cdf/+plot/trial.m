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

		% set trial range
	tr = [dsp.sec2smp( run.trials(id).cuepos, run.audiorate ) + 1, run.audiosize(1)];
	if id < numel( run.trials )
		tr(2) = dsp.sec2smp( run.trials(id+1).cuepos, run.audiorate );
	end

	if any( isnan( tr ) ) || any( tr < 1 ) || any( tr > run.audiosize(1) )
		error( 'invalid value: tr' );
	end

		% prepare audio data (time series)
	cdts = run.audiodata(tr(1):tr(2), 2);
	respts = run.audiodata(tr(1):tr(2), 1);

	tslen = numel( cdts );
	if tslen < 1
		error( 'invalid value: tslen' );
	end

		% plot
	fig = style.figure();

			% cue/distractor (acoustics)
	subplot( 2, 1, 1 );

	xlabel( 'milliseconds' );
	ylabel( 'cue/distractor' );

	xlim( [0, 1000 * dsp.smp2sec( tslen-1, run.audiorate )] );
	ylim( style.width( 1 ) * max( max( abs( cdts ) ), max( abs( respts ) ) ) * [-1, 1] );

	plot( 1000 * dsp.smp2sec( 0:tslen-1, run.audiorate ), cdts, ...
		'Color', style.color( 'neutral', 0 ) );

			% response (acoustics)
	subplot( 2, 1, 2 );

	xlabel( 'milliseconds' );
	ylabel( 'response' );

	xlim( [0, 1000 * dsp.smp2sec( tslen-1, run.audiorate )] );
	ylim( style.width( 1 ) * max( max( abs( cdts ) ), max( abs( respts ) ) ) * [-1, 1] );

	plot( 1000 * dsp.smp2sec( 0:tslen-1, run.audiorate ), respts, ...
		'Color', style.color( 'neutral', 0 ) );

		% response (spectrogram), TODO

		% print
	style.print( plotfile );

	logger.untab();
end

