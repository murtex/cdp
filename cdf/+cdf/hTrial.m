classdef (Sealed = true) hTrial < handle
% cue-distractor trial

		% properties
	properties (Access = public)

			% general
		cuepos = NaN; % cue position (scalar numeric)
		distpos = NaN; % distractor position (scalar numeric)

		cuelabel = ''; % cue label (row char)
		distlabel = ''; % distractor label (row char)

			% experimental features
		distsoa = NaN; % stimulus-onset asynchrony (scalar numeric)
		distvot = NaN; % voice-onset time (scalar numeric)

	end

end % classdef

