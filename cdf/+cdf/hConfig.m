classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% syncing
		sync_range = [-0.075, 0.025]; % search range (row numeric)
		sync_smooth = 0.0005; % smoothing (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold (scalar numeric)

			% voice activity detection
		vad_frlength = 0.025; % short-time length (scalar numeric)
		vad_froverlap = 15/25; % short-time overlap (scalar numeric)
		vad_frwindow = @hann; % short-time window function (scalar object)

		vad_adjacency = 12; % long-term adjacency (scalar numeric)
		vad_hangover = 4; % activity hangover (scalar numeric)

			% debugging
		dbg_frlength = 0.025; % short-time length (scalar numeric)
		dbg_froverlap = 15/25; % short-time overlap (scalar numeric)
		dbg_frwindow = @hann; % short-time window function (scalar object)

	end

end

