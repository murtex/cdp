classdef (Sealed = true) hResponse < handle
% cue-distractor response

		% properties
	properties (Access = public)

			% activity
		range = [NaN, NaN]; % voice activity range (row numeric)

			% landmarks
		bo = NaN; % burst-onset (scalar numeric)
		vo = NaN; % voice-onset (scalar numeric)
		vr = NaN; % voice-release (scalar numeric)

			% formants
		f0 = [NaN, NaN]; % f0-onset and frequency (row numeric)
		f1 = [NaN, NaN]; % f1-onset and frequency (row numeric)
		f2 = [NaN, NaN]; % f2-onset and frequency (row numeric)
		f3 = [NaN, NaN]; % f3-onset and frequency (row numeric)

	end

end % classdef

