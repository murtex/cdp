classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % search range [start, stop] (row numeric)
		sync_smooth = NaN; % smoothing (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold (scalar numeric)

			% voice activity detection
		vad_freqband = [150, 8000]; % frequency band [lower, upper] (row numeric)
		vad_nfreqs = 200; % frequency resolution (scalar numeric)

		vad_minlen = 0.075; % minimum activity length [klein: 0.082] (scalar numeric)

		vad_maxdist = 1.5; % maximum distractor exposure [klein: 1.5042] (scalar numeric)
		vad_maxgap = 0.1; % maximum shadowing gap (scalar numeric)

		vad_maxdet = 2.2; % maximum detection length [klein: 2.038] (scalar numeric)

	end

end

