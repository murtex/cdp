classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [-0.125, 0.025]; % search range (row numeric)
		sync_smooth = 0.002; % smoothing (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold (scalar numeric)

			% voice activity detection
		vad_freqband = [150, 8000]; % frequency band [lower, upper] (row numeric)
		vad_nfreqs = 200; % frequency resolution

		vad_minlen = 0.075; % minimum activity length [klein: 0.082] (scalar numeric)

		vad_maxdist = 1.5; % maximum distractor exposure [klein: 1.5042] (scalar numeric)
		vad_maxgap = 0.1; % maximum echo gap (scalar numeric)

	end

end

