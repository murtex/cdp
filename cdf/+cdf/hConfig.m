classdef (Sealed = true) hConfig < handle
% framework configuration

		% properties
	properties (Access = public)

			% marker synchronization
		sync_range = [-0.050, 0.010]; % (relative) search range [start, stop] (row numeric)
		sync_smooth = 0.002; % sample smoothing [approx. marker length] (scalar numeric)
		sync_thresh = 3.0; % mahalanobis threshold [sigmas] (scalar numeric)

			% labeling/auditing
		activity_det1 = [-0.025, 0.050]; % (relative) activity detail #1 (start) range [start, stop] (row numeric)
		activity_det2 = [-0.050, 0.025]; % (relative) detail #2 (stop) range [start, stop] (row numeric)
		activity_zcsnap = [true, true]; % zero-crossings alignment [det1, det2] (logical scalar)

		landmarks_det1 = [-0.003, 0.006]; % (relative) landmarks detail #1 (burst onset) range [start, stop] (row numeric)
		landmarks_det2 = [-0.015, 0.030]; % (relative) detail #2 (voice onset) range [start, stop] (row numeric)
		landmarks_det3 = [-0.030, 0.015]; % (relative) detail #3 (voice release) range [start, stop] (row numeric)
		landmarks_zcsnap = [false, true, true]; % zero-crossings alignment [det1, det2, det3] (row logical)

		formants_f0_freqband = [0, 500, 100]; % f0 frequency band [lower, upper, count] (row numeric)
		formants_f0_window = {@hamming, 0.075, 95/100}; % short-time window [function, length, overlap] (row cell)
		formants_f0_gamma = 0.15; % spectrogram gamma (scalar numeric)
		formants_fx_freqband = [0, 5000, 100]; % f1..f3 frequency band [lower, upper, count] (row numeric)
		formants_fx_window = {@hamming, 0.005, 95/100}; % short-time window [function, length, overlap] (function handle)
		formants_fx_gamma = 0.15; % spectrogram gamma (scalar numeric)

			% label detection
		vad_freqband = [0, 5000, 100]; % voice activity frequency band [lower, upper, count] (row numeric)
		vad_window = {@hamming, 0.020, 50/100}; % short-time window [function, length, overlap] (row cell)

		sad_subband = [200, 2000]; % speech activity frequency subband [lower, upper] (row numeric)

	end

end

