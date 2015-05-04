classdef hConfig < matlab.mixin.Copyable
% framework configuration

		% properties
	properties (Access = public)

			% sync
		sync_mrklen = 1; % sync marker length (scalar numeric)
		sync_thresh = 3; % sync detection threshold (scalar numeric)
		sync_range = [-25, 5]; % sync detection range (row numeric)

			% response extraction
		sta_frame = [15, 5]; % short-time frame length and stride (row numeric)
		sta_wnd = @hann; % short-time window function (scalar object)
		sta_band = [150, 8000]; % short-time frequency band (row numeric)

			% landmarks
		glottis_band = [150, 500]; % glottis frequency band (row numeric)
		glottis_rordt = 25; % glottis rate-of-rise delta (scalar numeric)
		glottis_rorpeak = 6; % glottis ror peak power (scalar numeric)

		schwa_length = 20; % schwa vowel length (scalar numeric)
		schwa_power = -20; % relative schwa vowel power (scalar numeric)

		plosion_threshs = [20, 10]; % plosion index thresholds (row numeric)
		plosion_delta = 1; % plosion delta (scalar numeric)
		plosion_width = 10; % plosion width (scalar numeric)

			% feature extraction
		feat_intcount = 10; % number of intervals (scalar numeric)
		feat_intlen = 5; % minimum interval length (scalar numeric)

	end

end % classdef

