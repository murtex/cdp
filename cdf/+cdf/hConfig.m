classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% syncing
		sync_range = [-0.125, 0.025]; % search range (row numeric)
		sync_smooth = 0.002; % smoothing (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold (scalar numeric)

			% voice activity detection
		vad_frlength = 0.01; % short-time length (scalar numeric)
		vad_froverlap = 0.5; % short-time overlap (scalar numeric)
		vad_frwindow = @hann; % short-time window function (scalar object)

		vad_freqband = [eps, Inf]; % frequency band (row numeric)

		vad_adjacency = 12; % long-term adjacency (scalar numeric)
		vad_hangover = 6; % activity hangover (scalar numeric)

	end

end

