classdef (Sealed = true) hRun < handle
% cue-distractor run

		% properties
	properties (Access = public)

			% audio data
		audiofile = ''; % audio filename (row char)

		audiosize = NaN( 1, 2 ); % audio data size [samples, channels] (row numeric)
		audiorate = NaN; % audio sampling rate (scalar numeric)

		audiodata = []; % audio data (matrix numeric)

			% trials
		trials = cdf.hTrial.empty(); % cue-distractor trials (row object)

			% responses
		resps_det = cdf.hResponse.empty(); % detected responses (row object)
		resps_lab = cdf.hResponse.empty(); % labeled responses (row object)

	end

end % classdef

