function plot_info( trial, fdet )
% plot label information
%
% PLOT_INFO( trial, fdet )
%
% INPUT
% trial : cue-distractor trial (scalar object)
% fdet : detected labels flag (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( trial ) || ~isa( trial, 'cdf.hTrial' )
		error( 'invalid argument: trial' );
	end

	if nargin < 2 || ~isscalar( fdet ) || ~islogical( fdet )
		error( 'invalid argument: fdet' );
	end

		% plot label information
	style = xis.hStyle.instance();

	s = { ...
		'MANUAL LABELS', ...
		'', ...
		sprintf( 'class: ''%s''', trial.resplab.label ), ...
		sprintf( 'activity: [%.1f, %.1f]', (trial.resplab.range - trial.range(1)) * 1000 ), ...
		'', ...
		sprintf( 'burst onset: %.1f', (trial.resplab.bo - trial.range(1)) * 1000 ), ...
		sprintf( 'voice onset: %.1f', (trial.resplab.vo - trial.range(1)) * 1000 ), ...
		sprintf( 'voice release: %.1f', (trial.resplab.vr - trial.range(1)) * 1000 ), ...
		'', ...
		sprintf( 'F0 onset: [%.1f, %.1f]', (trial.resplab.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
		sprintf( 'F1 onset: [%.1f, %.1f]', (trial.resplab.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
		sprintf( 'F2 onset: [%.1f, %.1f]', (trial.resplab.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
		sprintf( 'F3 onset: [%.1f, %.1f]', (trial.resplab.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

	annotation( 'textbox', [0/3, 0, 1/3, 1/4], 'String', s, ...
		'BackgroundColor', style.color( 'grey', style.scale( -1/9 ) ) );

	if fdet % detected labels
		s = { ...
			'DETECTED LABELS', ...
			'', ...
			sprintf( 'class: ''%s''', trial.respdet.label ), ...
			sprintf( 'activity: [%.1f, %.1f]', (trial.respdet.range - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'burst onset: %.1f', (trial.respdet.bo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice onset: %.1f', (trial.respdet.vo - trial.range(1)) * 1000 ), ...
			sprintf( 'voice release: %.1f', (trial.respdet.vr - trial.range(1)) * 1000 ), ...
			'', ...
			sprintf( 'F0 onset: [%.1f, %.1f]', (trial.respdet.f0 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F1 onset: [%.1f, %.1f]', (trial.respdet.f1 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F2 onset: [%.1f, %.1f]', (trial.respdet.f2 - [trial.range(1), 0]) .* [1000, 1] ), ...
			sprintf( 'F3 onset: [%.1f, %.1f]', (trial.respdet.f3 - [trial.range(1), 0]) .* [1000, 1] ) };

		annotation( 'textbox', [1/3, 0, 1/3, 1/4], 'String', s, ...
			'BackgroundColor', style.color( 'grey', style.scale( -1/9 ) ) );
	end

end

