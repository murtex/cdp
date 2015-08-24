classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% syncing
		sync_range = [-0.125, 0.025]; % search range (row numeric)
		sync_smooth = 0.002; % smoothing (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold (scalar numeric)

			% formant-onset detection
		fod_freqband = [0, 2000]; % frequency band (row numeric)
		fod_nfreqs = 200; % frequency resolution (scalar numeric)

		fod_gamma = 3.5; % spectral gamma (scalar numeric)

		fod_peakratio = 0.3; % peak ratio (scalar numeric)
		fod_peakgap = 0.01; % peak gap (scalar numeric)
		fod_peakleap = 50.0; % peak leap (scalar numeric)

			% voice activity detection
		vad_frlength = 0.006; % short-time length (scalar numeric)
		vad_froverlap = 0.5; % short-time overlap (scalar numeric)
		vad_frwindow = @hann; % short-time window function (scalar object)

		vad_freqband = [150, Inf]; % frequency band (row numeric)

		vad_adjacency = 6; % long-term adjacency (scalar numeric)
		vad_hangover = 6; % activity hangover (scalar numeric)

			% labeling
		lab_freqband = [0, 2000]; % frequency band (row numeric)
		lab_nfreqs = 200; % frequency resolution (scalar numeric)

	end

end

