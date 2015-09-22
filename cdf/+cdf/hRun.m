classdef (Sealed = true) hRun < handle
% cue-distractor run

		% properties
	properties (Access = public)

			% general
		sex = ''; % subject sex (row char)
		age = NaN; % subject age (scalar numeric)

			% audio data
		audiofile = ''; % audio filename (row char)

		audiosize = NaN( 1, 2 ); % audio data size [samples, channels] (row numeric)
		audiorate = NaN; % audio sampling rate (scalar numeric)

		audiodata = []; % audio data (matrix numeric)

			% trials
		trials = cdf.hTrial.empty(); % cue-distractor trials (row object)

	end

end % classdef

