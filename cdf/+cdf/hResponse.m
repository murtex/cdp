classdef (Sealed = true) hResponse < handle
% cue-distractor response

		% properties
	properties (Access = public)

			% activity
		range = [NaN, NaN]; % voice activity range (row numeric)

			% landmarks
		bo = NaN; % burst-onset (scalar numeric)

		f0 = [NaN, NaN]; % formant-onsets and frequencies (row numeric)
		f1 = [NaN, NaN];
		f2 = [NaN, NaN];
		f3 = [NaN, NaN];

		vr = NaN; % vowel-release (scalar numeric)

	end

end % classdef

