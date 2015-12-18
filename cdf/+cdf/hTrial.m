classdef (Sealed = true) hTrial < handle
% cue-distractor trial

		% properties
	properties (Access = public)

			% general
		range = [NaN, NaN]; % trial range [start, stop] (row numeric)

		cue = NaN; % cue position (scalar numeric)
		dist = NaN; % distractor position (scalar numeric)

		cuelabel = ''; % cue label (row char)
		distlabel = ''; % distractor label (row char)

			% conditions
		soa = NaN; % stimulus-onset asynchrony (scalar numeric)
		vot = NaN; % distractor voice-onset time (scalar numeric)

			% responses
		resplab = cdf.hResponse.empty(); % manually labeled (scalar object)
		respdet = cdf.hResponse.empty(); % automatically detected (scalar object)

	end

		% public methods
	methods (Access = public)

		function fval = is_valid( this )
		% check trial validity
		%
		% fval = IS_VALID( this )
		%
		% INPUT
		% this : cue-distractor trial(s) (matrix object)
		%
		% OUTPUT
		% fval : validity flag(s) (matrix logical)

				% safeguard
			if ~ismatrix( this )
				error( 'invalid argument: this' );
			end

				% check validities
			fval = true( size( this ) );

			for i = 1:numel( this )
				if any( isnan( this(i).range ) ) || this(i).range(1) >= this(i).range(2)
					fval(i) = false;
				end
			end

		end

	end % public methods

end % classdef

