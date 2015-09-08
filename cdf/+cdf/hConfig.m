classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% syncing
		sync_range = [-0.125, 0.025]; % search range (row numeric)
		sync_smooth = 0.002; % smoothing (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold (scalar numeric)

			% voice activity detection
		vad_frlength = 0.006; % short-time length (scalar numeric)
		vad_froverlap = 0.5; % short-time overlap (scalar numeric)
		vad_frwindow = @hann; % short-time window function (scalar object)

		vad_freqband = [150, Inf]; % frequency band (row numeric)

		vad_adjacency = 6; % long-term adjacency (scalar numeric)
		vad_hangover = 6; % activity hangover (scalar numeric)

			% formant trajectory tracking
		ftt_freqband = [0, 1200]; % frequency band (row numeric)
		ftt_nfreqs = 400; % frequency resolution (scalar numeric)

		ftt_gamma = 7.5; % spectral gamma correction (scalar numeric)

		ftt_peakratio = 0.35; % peak ratio (scalar numeric)

		ftt_trajgap = 0.005; % trajectory gap (scalar numeric)
		ftt_trajleap = 50.0; % trajectory leap (scalar numeric)

			% labeling
		lab_freqband = [0, 2000]; % frequency band (row numeric)
		lab_nfreqs = 200; % frequency resolution (scalar numeric)

	end

end

