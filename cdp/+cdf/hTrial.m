classdef hTrial < matlab.mixin.Copyable
% experimental trial

		% properties
	properties (Access = public)

		id = NaN; % trial identifier (scalar numeric)

		range = [NaN, NaN]; % trial range (row numeric)

		cuelabel = ''; % cue label (row char)
		distlabel = ''; % distractor label (row char)

		cue = NaN; % cue position (scalar numeric)
		soa = NaN; % stimulus-onset asynchrony (scalar numeric)

		distbo = NaN; % distractor burst-onset position (scalar numeric)
		distvo = NaN; % distractor voice-onset position (scalar numeric)

		detected = struct( ... % detected response
			'range', [NaN, NaN], ... % range (row numeric)
			'label', '', ... % label (row char)
			'bo', NaN, ... % burst-onset position (scalar numeric)
			'vo', NaN, ... % voice-onset position (scalar numeric)
			'vr', NaN, ... % voice-release position (scalar numeric)
			'featfile', '' ); % feature filename (row char)

		labeled = struct( ... % labeled response
			'range', [NaN, NaN], ... % range (row numeric)
			'label', '', ... % label (row char)
			'bo', NaN, ... % burst-onset position (scalar numeric)
			'vo', NaN, ... % voice-onset position (scalar numeric)
			'vr', NaN, ... % voice-release position (scalar numeric)
			'featfile', '' ); % feature filename (row char)

	end

end % classdef

