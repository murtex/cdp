classdef hRun < matlab.mixin.Copyable
% experimental run

		% properties
	properties (Access = public)

		id = NaN; % subject identifier (scalar numeric)

		audiofile = ''; % audio filename (row char)
		audiodata = []; % audio data (matrix numeric)
		audiolen = NaN; % audio length (scalar numeric)
		audiorate = NaN; % audio sampling rate (scalar numeric)

		trials = cdf.hTrial.empty(); % vector of trials (row object)

	end

		% protected methods
	methods (Access = protected)

		function that = copyElement( this )
		% deep copy
		%
		% that = COPYELEMENT( this )
		%
		% INPUT
		% this : run (object)
		% 
		% OUTPUT
		% that : run (object)

				% base call
			that = copyElement@matlab.mixin.Copyable( this );

				% deep copy
			that.trials = this.trials.copy();

		end

	end % protected methods

end % classdef

