function [ovrts, hdet1, hdet2, hdet3] = plot_landmarks( run, cfg, trial, flags, stitle, callback )
% plot landmarks
%
% [hdet1, hdet2, hdet3] = PLOT_LANDMARKS( run, cfg, trial, flags, stitle, callback )
%
% INPUT
% run : cue-distractor run (scalar object)
% cfg : framework configuration (scalar object)
% trial : cue-distractor trial (scalar object)
% flags : flags [redo, det, log] (vector logical)
% stitle : title string (row char)
% callback : button down event dispatcher [function, argument] (vector cell)
%
% OUTPUT
% ovrts : overview signal (column numeric)
% hdet1 : detail #1 (burst onset) axis handle (intern)
% hdet2 : detail #2 (voice onset) axis handle (intern)
% hdet3 : detail #3 (voice release) axis handle (intern)

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

	if nargin < 4 || ~isvector( flags ) || numel( flags ) ~= 3 || ~islogical( flags )
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

	function ts = scale( ts ) % log scale
		if flags(3)
			ts = mag2db( abs( ts ) + eps );
		end
	end

	function plot_marks( yl, flegend ) % landmarks
		h1 = plot( (resplab.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % manual
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'warm', +1 ), ...
			'DisplayName', 'manual' );
		plot( (resplab.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'warm', +1 ) );
		plot( (resplab.vr * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'warm', +1 ) );

		h2 = plot( (respdet.bo * [1, 1] - trial.range(1)) * 1000, yl, ... % detected
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'signal', +1 ), ...
			'DisplayName', 'detected' );
		plot( (respdet.vo * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'signal', +1 ) );
		plot( (respdet.vr * [1, 1] - trial.range(1)) * 1000, yl, ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'signal', +1 ) );

		if flegend % legend
			hl = legend( [h1, h2], 'Location', 'southeast' );
			set( hl, 'Color', style.color( 'grey', style.scale( -1/9 ) ) );
		end
	end

	function plot_signal( r, ts ) % signal
		stairs( ...
			(dsp.smp2sec( (r(1):r(2)+1) - 1, run.audiorate ) - trial.range(1)) * 1000, scale( [ts; ts(end)] ), ...
			'ButtonDownFcn', callback, ...
			'Color', style.color( 'cold', -1 ) );
	end

		% prepare data
	resplab = trial.resplab;
	respdet = trial.respdet;

	ovrr = dsp.sec2smp( [ ... % ranges
		min( resplab.range(1), respdet.range(1) ), ...
		max( resplab.range(2), respdet.range(2) )], run.audiorate ) + [1, 0];

	det1r = dsp.sec2smp( [...
		min( resplab.bo, respdet.bo ) + cfg.landmarks_det1(1), ...
		max( resplab.bo, respdet.bo ) + cfg.landmarks_det1(2)], run.audiorate ) + [1, 0];
	det1r(det1r < 1) = 1;
	det1r(det1r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

	det2r = dsp.sec2smp( [...
		min( resplab.vo, respdet.vo ) + cfg.landmarks_det2(1), ...
		max( resplab.vo, respdet.vo ) + cfg.landmarks_det2(2)], run.audiorate ) + [1, 0];
	det2r(det2r < 1) = 1;
	det2r(det2r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

	det3r = dsp.sec2smp( [...
		min( resplab.vr, respdet.vr ) + cfg.landmarks_det3(1), ...
		max( resplab.vr, respdet.vr ) + cfg.landmarks_det3(2)], run.audiorate ) + [1, 0];
	det3r(det3r < 1) = 1;
	det3r(det3r > size( run.audiodata, 1 )) = size( run.audiodata, 1 );

	ovrts = run.audiodata(ovrr(1):ovrr(2), 1); % signals

	det1ts = [];
	if ~any( isnan( det1r ) )
		det1ts = run.audiodata(det1r(1):det1r(2), 1);
	end

	det2ts = [];
	if ~any( isnan( det2r ) )
		det2ts = run.audiodata(det2r(1):det2r(2), 1);
	end

	det3ts = [];
	if ~any( isnan( det3r ) )
		det3ts = run.audiodata(det3r(1):det3r(2), 1);
	end

	if ~flags(3) % linear axes
		ovryl = max( abs( ovrts ) ) * [-1, 1] * style.scale( 1/2 );

		if ~isempty( det1ts ) || ~isempty( det2ts ) || ~isempty( det3ts )
			detyl = max( abs( cat( 1, det1ts, det2ts, det3ts ) ) ) * [-1, 1] * style.scale( 1/2 );
		end

	else % log axes
		ovryl = [min( scale( ovrts ) ), max( scale( ovrts ) )];
		ovryl(2) = ovryl(1) + diff( ovryl ) * (1 + (style.scale( 1/2 ) - 1) / 2);

		if ~isempty( det1ts ) || ~isempty( det2ts ) || ~isempty( det3ts )
			detyl = [min( scale( cat( 1, det1ts, det2ts, det3ts ) ) ), max( scale( cat( 1, det1ts, det2ts, det3ts ) ) )];
			detyl(2) = detyl(1) + diff( detyl ) * (1 + (style.scale( 1/2 ) - 1) / 2);
		end
	end

		% plot overview
	subplot( 4, 3, [1, 3], 'ButtonDownFcn', callback );

	title( stitle );
	xlabel( 'trial time in milliseconds' );
	ylabel( 'landmarks' );

	xlim( ([...
		min( resplab.range(1), respdet.range(1) ), ...
		max( resplab.range(2), respdet.range(2) )] - trial.range(1)) * 1000 );
	ylim( ovryl );

	plot_marks( ovryl, true );
	plot_signal( ovrr, ovrts );

		% plot detail #1 (burst onset)
	hdet1 = NaN;
	if ~isempty( det1ts )
		hdet1 = subplot( 4, 3, [4, 7], 'ButtonDownFcn', callback );

		xlabel( 'trial time in milliseconds' );
		ylabel( 'burst onset detail' );

		xlim( ([...
			min( resplab.bo, respdet.bo ) + cfg.landmarks_det1(1), ...
			max( resplab.bo, respdet.bo ) + cfg.landmarks_det1(2)] - trial.range(1)) * 1000 );
		ylim( detyl );

		plot_marks( detyl, false );
		plot_signal( det1r, det1ts );
	end

		% plot detail #2 (voice onset)
	hdet2 = NaN;
	if ~isempty( det2ts )
		hdet2 = subplot( 4, 3, [5, 8], 'ButtonDownFcn', callback );

		xlabel( 'trial time in milliseconds' );
		ylabel( 'voice onset detail' );

		xlim( ([...
			min( resplab.vo, respdet.vo ) + cfg.landmarks_det2(1), ...
			max( resplab.vo, respdet.vo ) + cfg.landmarks_det2(2)] - trial.range(1)) * 1000 );
		ylim( detyl );

		plot_marks( detyl, false );
		plot_signal( det2r, det2ts );
	end

		% plot detail #3 (voice release )
	hdet3 = NaN;
	if ~isempty( det3ts )
		hdet3 = subplot( 4, 3, [6, 9], 'ButtonDownFcn', callback );

		xlabel( 'trial time in milliseconds' );
		ylabel( 'voice release detail' );

		xlim( ([...
			min( resplab.vr, respdet.vr ) + cfg.landmarks_det3(1), ...
			max( resplab.vr, respdet.vr ) + cfg.landmarks_det3(2)] - trial.range(1)) * 1000 );
		ylim( detyl );

		plot_marks( detyl, false );
		plot_signal( det3r, det3ts );
	end

end

