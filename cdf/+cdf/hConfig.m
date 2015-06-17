classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% syncing
		sync_range = [-0.15, 0.075]; % sync search range (row numeric)
		sync_smooth = 0.0005; % sync smoothing (scalar numeric)
		sync_thresh = 3; % sync mahalanobis threshold (scalar numeric)

	end

end

