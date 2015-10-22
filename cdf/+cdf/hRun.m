classdef (Sealed = true) hRun < handle
% cue-distractor run

		% properties
	properties (Access = public)

			% general
		sex = ''; % subject sex (row char)
		age = NaN; % subject age (scalar numeric)

			% audio data
		audiofile = ''; % audio filename (row char)

		audiodata = []; % audio data [samples, channels] (matrix numeric)
		audiorate = NaN; % audio sampling rate (scalar numeric)

			% trials
		trials = cdf.hTrial.empty(); % cue-distractor trials (row object)

	end

end % classdef

