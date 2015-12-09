function plot_commands( labmode )
% plot mode commands
%
% PLOT_COMMANDS( labmode )
%
% INPUT
% labmode : labeling mode [activity | landmarks | formants] (row char)

		% safeguard
	if nargin < 1 || ~isrow( labmode ) || ~ischar( labmode )
		error( 'invalid argument: labmode' );
	end

		% plot mode commands
	style = xis.hStyle.instance();

	s = { ...
		'MODE COMMANDS', ...
		'', ...
		'SPACE: next unlabeled trial', ...
		'', ...
		'CONTROL+BACKSPACE: clear trial labels', ...
		'SHIFT+CONTROL+ALT+BACKSPACE: clear run labels', ...
		'' };

	switch labmode
		case 'activity'
			s = cat( 2, s, { ...
				'K: set ''ka'' class', ...
				'T: set ''ta'' class', ...
				'', ...
				'LEFT: set activity start', ...
				'RIGHT: set activity stop', ...
				'', ...
				'SHIFT+RETURN: playback activity' } );

		case 'landmarks'
			s = cat( 2, s, { ...
				'L: set landmarks (3 clicks, RETURN cancels)', ...
				'', ...
				'B: set burst onset (1 click, RETURN cancels)', ...
				'V: set voice onset (1 click, RETURN cancels)', ...
				'R: set voice release (1 click, RETURN cancels)', ...
				'', ...
				'LEFT: detail landmark', ...
				'', ...
				'SHIFT+RETURN: playback from burst' } );

		case 'formants'
			s = cat( 2, s, { ...
				'LEFT: set F0 onset', ...
				'', ...
				'F: set formant onsets (3 clicks, RETURN cancels)', ...
				'1: set F1 onset (1 click, RETURN cancels)', ...
				'2: set F2 onset (1 click, RETURN cancels)', ...
				'3: set F3 onset (1 click, RETURN cancels)', ...
				'', ...
				'B: toggle blending' } );

		otherwise
			error( 'invalid argument: labmode' );
	end

	annotation( 'textbox', [2/3, 0, 1/3, 1/4], 'String', s, ...
		'BackgroundColor', style.color( 'grey', style.scale( -1/9 ) ) );

end
