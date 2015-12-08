function plot_activity( run, cfg, trial, flags, stitle, callback )
% plot activity
%
% PLOT_ACTIVITY( run, cfg, trial, flags, stitle, callback )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% trial : cue-distractor trial (scalar object)
% flags : flags [log] (vector logical)
% stitle : title string (row char)
% callback : button down event dispatcher [function, argument] (vector cell)

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

	if nargin < 4 || ~isvector( flags ) || numel( flags ) ~= 1 || ~islogical( flags )
		error( 'invalid argument: flags' );
	end

	if nargin < 5 || ~isrow( stitle ) || ~ischar( stitle )
		error( 'invalid argument: stitle' );
	end

	if nargin < 6 || ~isvector( callback ) || numel( callback ) ~= 2 || ~iscell( callback )
		error( 'invalid argument: callback' );
	end

		% helpers
	style = xis.hStyle.instance();

	function ts = scale( ts )
		if flags(1)
			ts = mag2db( abs( ts ) + eps );
		end
	end

	function plot_range( yl )
		h1 = plot( (resplab.range(1) * [1, 1] - trial.range(1)) * 1000, yl, ... % manual
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'warm', +1 ), ...
			'DisplayName', 'manual' );
		plot( (resplab.range(2) * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'warm', +1 ) );

		h2 = plot( (respdet.range(1) * [1, 1] - trial.range(1)) * 1000, yl, ... % detected
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'signal', +1 ), ...
			'DisplayName', 'detected' );
		plot( (respdet.range(2) * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'signal', +1 ) );

		hl = legend( [h1, h2], 'Location', 'southeast' ); % legend
		set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );
	end

	function plot_signal( r, ts )
		stairs( ...
			(dsp.smp2sec( (r(1):r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, scale( [ts; ts(end)] ), ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'cold', -1 ) );
	end

		% prepare data
	resplab = trial.resplab;
	respdet = trial.respdet;

	ovrr = dsp.sec2smp( trial.range, run.audiorate ) + [1, 0]; % ranges

	det1r = dsp.sec2smp( [...
		min( resplab.range(1), respdet.range(1) ) + cfg.activity_det1(1), ...
		max( resplab.range(1), respdet.range(1) ) + cfg.activity_det1(2)], run.audiorate ) + [1, 0];
	det1r(det1r < 1) = 1;
	det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

	det2r = dsp.sec2smp( [...
		min( resplab.range(2), respdet.range(2) ) + cfg.activity_det2(1), ...
		max( resplab.range(2), respdet.range(2) ) + cfg.activity_det2(2)], run.audiorate ) + [1, 0];
	det2r(det2r < 1) = 1;
	det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

	ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

	det1ts = [];
	if ~any( isnan( det1r ) )
		det1ts = run.audiodata(det1r(1):det1r(2), 1);
	end

	det2ts = [];
	if ~any( isnan( det2r ) )
		det2ts = run.audiodata(det2r(1):det2r(2), 1);
	end

	if ~flags(1) % linear axes
		ovryl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 ); % overview

		if ~isempty( det1ts ) || ~isempty( det2ts ) % details
			detyl = max( abs( cat( 1, det1ts, det2ts ) ) ) * [-1, 1] * style.scale( 1/2 );
		end

	else % log axes
		ovryl = [min( scale( ovrts ) ), max( scale( ovrts ) )]; % overview
		ovryl(2) = ovryl(1) + diff( ovryl ) * (1 + (style.scale( 1/2 ) - 1) / 2);

		if ~isempty( det1ts ) || ~isempty( det2ts ) % details
			detyl = [min( scale( cat( 1, det1ts, det2ts ) ) ), max( scale( cat( 1, det1ts, det2ts ) ) )];
			detyl(2) = detyl(1) + diff( detyl ) * (1 + (style.scale( 1/2 ) - 1) / 2);
		end
	end

		% plot overview
	subplot( 4, 2, [1, 2], 'ButtonDownFcn', callback );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'activity range' );

	xlim( (trial.range - trial.range(1)) * 1000 );
	ylim( ovryl );

	plot_range( ovryl );
	plot_signal( ovrr, ovrts );

		% plot detail #1 (activity start)
	hdet1 = NaN;
	if ~isempty( det1ts )
		subplot( 4, 2, [3, 5], 'ButtonDownFcn', callback );

		xlabel( 'trial time in milliseconds' );
		ylabel( 'range start detail' );

		xlim( ([...
			min( resplab.range(1), respdet.range(1) ) + cfg.activity_det1(1), ...
			max( resplab.range(1), respdet.range(1) ) + cfg.activity_det1(2)] - trial.range(1)) * 1000 );
		ylim( detyl );

		plot_range( detyl );
		plot_signal( det1r, det1ts );
	end

		% plot detail #2 (activity stop)
	hdet2 = NaN;
	if ~isempty( det2ts )
		subplot( 4, 2, [4, 6], 'ButtonDownFcn', callback );

		xlabel( 'trial time in milliseconds' );
		ylabel( 'range stop detail' );

		xlim( ([...
			min( resplab.range(2), respdet.range(2) ) + cfg.activity_det2(1), ...
			max( resplab.range(2), respdet.range(2) ) + cfg.activity_det2(2)] - trial.range(1)) * 1000 );
		ylim( detyl );

		plot_range( detyl );
		plot_signal( det2r, det2ts );
	end

end

