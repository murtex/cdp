classdef hConfig < matlab.mixin.Copyable
% framework configuration

		% properties
	properties (Access = public)

			% sync
		sync_mrklen = 1; % sync marker length (scalar numeric)
		sync_thresh = 3; % sync detection threshold (scalar numeric)
		sync_range = [-125, 25]; % sync detection range (row numeric)

			% extraction
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

			% classification
		feat_intcount = 10; % number of intervals (scalar numeric)
		feat_intlen = 5; % minimum interval length (scalar numeric)

		feat_band1 = [500, 1000]; % frequency band #1 (pair numeric)
		feat_band2 = [1000, 2000]; % frequency band #2 (pair numeric)
		feat_band3 = [2000, 3000]; % frequency band #3 (pair numeric)
		feat_band4 = [3000, 4000]; % frequency band #4 (pair numeric)
		feat_band5 = [4000, 5000]; % frequency band #5 (pair numeric)
		feat_band6 = [5000, 6000]; % frequency band #6 (pair numeric)
		feat_band7 = [6000, 7000]; % frequency band #7 (pair numeric)
		feat_band8 = [7000, 8000]; % frequency band #8 (pair numeric)

	end

end % classdef

