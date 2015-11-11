classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = NaN; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold [sigmas] (scalar numeric)

			% manual labeling
		lab_activity_det1 = [NaN, NaN]; % (relative) activity detail #1 [start, stop] (row numeric)
		lab_activity_det2 = [NaN, NaN]; % (relative) activity detail #2 [start, stop] (row numeric)

	end

end

