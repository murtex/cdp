classdef (Sealed = true) hResponse < handle
% cue-distractor response

		% properties
	properties (Access = public)

			% activity
		range = [NaN, NaN]; % activity range [start, stop] (row numeric)
		range_uc = [NaN, NaN]; % uncertainty (row numeric)

			% landmarks
		bo = NaN; % burst onset (scalar numeric)
		vo = NaN; % voice onset (scalar numeric)

		bo_uc = NaN; % burst onset uncertainty (scalar numeric)
		vo_uc = NaN; % voice onset uncertainty (scalar numeric)

			% formants
		f0 = [NaN, NaN]; % f0 onset [time, frequency] (row numeric)
		f1 = [NaN, NaN]; % f1 onset [time, frequency] (row numeric)
		f2 = [NaN, NaN]; % f2 onset [time, frequency] (row numeric)
		f3 = [NaN, NaN]; % f3 onset [time, frequency] (row numeric)

		f0_uc = [NaN, NaN]; % f0 onset uncertainty (row numeric)
		f1_uc = [NaN, NaN]; % f1 onset uncertainty (row numeric)
		f2_uc = [NaN, NaN]; % f2 onset uncertainty (row numeric)
		f3_uc = [NaN, NaN]; % f3 onset uncertainty (row numeric)

			% classification
		label = ''; % response label (row char)

	end

end % classdef

