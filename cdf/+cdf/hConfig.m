classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = NaN; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold [sigmas] (scalar numeric)

			% manual labeling
		lab_range_det1 = [-0.025, 0.05]; % range detail #1 [preceding, succeeding] (row numeric)
		lab_range_det2 = [-0.05, 0.025]; % range detail #2 [preceding, succeeding] (row numeric)

	end

end

