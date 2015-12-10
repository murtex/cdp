classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [NaN, NaN]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = NaN; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = NaN; % mahalanobis threshold [sigmas] (scalar numeric)

			% labeling/auditing
		activity_det1 = [NaN, NaN]; % (relative) activity detail #1 (start) range [start, stop] (row numeric)
		activity_det2 = [NaN, NaN]; % (relative) detail #2 (stop) range [start, stop] (row numeric)
		activity_zcsnap = [false, false]; % zero-crossings alignment [det1, det2] (logical scalar)

		landmarks_det1 = [NaN, NaN]; % (relative) landmarks detail #1 (burst onset) range [start, stop] (row numeric)
		landmarks_det2 = [NaN, NaN]; % (relative) detail #2 (voice onset) range [start, stop] (row numeric)
		landmarks_det3 = [NaN, NaN]; % (relative) detail #3 (voice release) range [start, stop] (row numeric)
		landmarks_zcsnap = [false, false, false]; % zero-crossings alignment [det1, det2, det3] (row logical)

		formants_f0_freqband = [NaN, NaN, NaN]; % f0 frequency band [lower, upper, count] (row numeric)
		formants_f0_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (row cell)
		formants_f0_gamma = NaN; % spectrogram gamma (scalar numeric)
		formants_fx_freqband = [NaN, NaN, NaN]; % f1..f3 frequency band [lower, upper, count] (row numeric)
		formants_fx_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (function handle)
		formants_fx_gamma = NaN; % spectrogram gamma (scalar numeric)

			% label detection
		vad_freqband = [NaN, NaN, NaN]; % voice activity frequency band [lower, upper, count] (row numeric)
		vad_window = {@rectwin, NaN, NaN}; % short-time window [function, length, overlap] (row cell)

	end

end

