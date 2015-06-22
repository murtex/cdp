function trial_sync( run, cfg, id, sync0, synchint, sync, plotfile )
% plot trial sync
%
% TRIAL_SYNC( run, cfg, id, sync0, sync, plotfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% id : trial indentifier (scalar numeric)
% sync0 : sync start offset (scalar numeric)
% synchint : offset hint (scalar numeric)
% sync : sync marker offset (scalar numeric)
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

	if nargin < 4 || ~isscalar( sync0 ) || ~isnumeric( sync0 )
		error( 'invalid argument: sync0' );
	end

	if nargin < 5 || ~isscalar( synchint ) || ~isnumeric( synchint )
		error( 'invalid argument: synchint' );
	end

	if nargin < 6 || ~isscalar( sync ) || ~isnumeric( sync )
		error( 'invalid argument: sync' );
	end

	if nargin < 7 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot trial sync (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% prepare data
	trial = run.trials(id);

	usr = dsp.sec2smp( sync0 + trial.cue + 5*cfg.sync_range, run.audiorate ) + 1; % unhinted search range
	hsr = dsp.sec2smp( sync0 + synchint + trial.cue + 5*cfg.sync_range, run.audiorate ) + 1; % hinted search range

	if any( isnan( hsr ) ) || any( isnan( usr ) )
		error( 'invalid value: hsr | usr' );
	end

	cdr = min( [hsr(1), usr(1)] ):max( [hsr(2), usr(2)] ); % signal
	cdts = run.audiodata(cdr, 2);

	xs = 1000 * (dsp.smp2sec( cdr - 1, run.audiorate ) - sync0 - trial.cue); % axes scaling
	xl = [min( xs ), max( xs )];
	yl = max( abs( cdts ) ) * style.width( 1/2 ) * [-1, 1];

		% plot
	fig = style.figure();

	title( ...
		sprintf( 'sync start: %.1fms, sync hint: %.1fms, sync offset: %.1fms', ...
		1000 * sync0, 1000 * synchint, 1000 * sync ) );

	xlabel( 'time in milliseconds (expected: t=0)' );
	ylabel( 'distractor channel' );

	xlim( xl );
	ylim( yl );

	plot( 1000 * sync * [1, 1], yl, ... % sync ofset
		'Color', style.color( 'warm', 0 ) );

	plot( xs, cdts, ... % signal
		'Color', style.color( 'cold', +1 ) );

		% print
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

