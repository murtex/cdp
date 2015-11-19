classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = NaN; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold [sigmas] (scalar numeric)

			% manual labeling
		lab_activity_det1 = [NaN, NaN]; % (relative) activity detail #1 (start) [start, stop] (row numeric)
		lab_activity_det2 = [NaN, NaN]; % (relative) activity detail #2 (stop) [start, stop] (row numeric)
		lab_activity_zcsnap = false; % zero-crossings alignment (logical scalar)

		lab_landmarks_det1 = [NaN, NaN]; % (relative) landmarks detail #1 (burst onset) [start, stop] (row numeric)
		lab_landmarks_det2 = [NaN, NaN]; % (relative) landmarks detail #2 (voice onset) [start, stop] (row numeric)
		lab_landmarks_det3 = [NaN, NaN]; % (relative) landmarks detail #3 (voice voice release) [start, stop] (row numeric)
		lab_landmarks_zcsnap = [false, false, false]; % zero-crossings alignment [det1, det2, det3] (row logical)

		lab_formants_freqband = [NaN, NaN]; % spectrogram frequency range [lower, uppper] (row numeric)
		lab_formants_nfreqs = NaN; % spectrogram frequency resolution (scalar numeric)
		lab_formants_gamma = NaN; % spectrogram gamma (scalar numeric)

			% auditing
		aud_landmarks_det1 = [NaN, NaN]; % (relative) landmarks detail #1 (burst onset) [start, stop] (row numeric)
		aud_landmarks_det2 = [NaN, NaN]; % (relative) landmarks detail #2 (voice onset) [start, stop] (row numeric)

	end

end

