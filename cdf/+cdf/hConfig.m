classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = NaN; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold [sigmas] (scalar numeric)

			% labeling
		lab_activity_det1 = [NaN, NaN]; % (relative) activity detail #1 (start) [start, stop] (row numeric)
		lab_activity_det2 = [NaN, NaN]; % (relative) activity detail #2 (stop) [start, stop] (row numeric)
		lab_activity_zcsnap = [false, false]; % zero-crossings alignment [det1, det2] (logical scalar)

		lab_landmarks_det1 = [NaN, NaN]; % (relative) landmarks detail #1 (burst onset) [start, stop] (row numeric)
		lab_landmarks_det2 = [NaN, NaN]; % (relative) landmarks detail #2 (voice onset) [start, stop] (row numeric)
		lab_landmarks_det3 = [NaN, NaN]; % (relative) landmarks detail #3 (voice voice release) [start, stop] (row numeric)
		lab_landmarks_zcsnap = [false, false, false]; % zero-crossings alignment [det1, det2, det3] (row logical)

		lab_formants_f0_freqband = [NaN, NaN, NaN]; % f0 frequency band [lower, upper, count] (row numeric)
		lab_formants_f0_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (row cell)
		lab_formants_f0_gamma = NaN; % spectrogram gamma (scalar numeric)
		lab_formants_fx_freqband = [NaN, NaN, NaN]; % f1..f3 frequency band [lower, upper, count] (row numeric)
		lab_formants_fx_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (function handle)
		lab_formants_fx_gamma = NaN; % spectrogram gamma (scalar numeric)

			% auditing
		aud_activity_det1 = [NaN, NaN]; % (relative) activity detail #1 (start) [start, stop] (row numeric)
		aud_activity_det2 = [NaN, NaN]; % (relative) activity detail #2 (stop) [start, stop] (row numeric)

		aud_landmarks_det1 = [NaN, NaN]; % (relative) landmarks detail #1 (burst onset) [start, stop] (row numeric)
		aud_landmarks_det2 = [NaN, NaN]; % (relative) landmarks detail #2 (voice onset) [start, stop] (row numeric)
		aud_landmarks_det3 = [NaN, NaN]; % (relative) landmarks detail #3 (voice release) [start, stop] (row numeric)

		aud_formants_f0_freqband = [NaN, NaN, NaN]; % f0 frequency band [lower, upper, count] (row numeric)
		aud_formants_f0_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (row cell)
		aud_formants_f0_gamma = NaN; % spectrogram gamma (scalar numeric)
		aud_formants_fx_freqband = [NaN, NaN, NaN]; % f1..f3 frequency band [lower, upper, count] (row numeric)
		aud_formants_fx_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (function handle)
		aud_formants_fx_gamma = NaN; % spectrogram gamma (scalar numeric)

	end

end

