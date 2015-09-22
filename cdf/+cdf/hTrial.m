classdef (Sealed = true) hTrial < handle
% cue-distractor trial

		% properties
	properties (Access = public)

			% general
		range = [NaN, NaN]; % trial range [start, stop] (row numeric)

		cue = NaN; % cue position (scalar numeric)
		dist = NaN; % distractor position (scalar numeric)

		cuelabel = ''; % cue label (row char)
		distlabel = ''; % distractor label (row char)

			% experimental features
		soa = NaN; % stimulus-onset asynchrony (scalar numeric)
		vot = NaN; % distractor voice-onset time (scalar numeric)

			% responses
		resplab = cdf.hResponse();
		respdet = cdf.hResponse();

	end

end % classdef

