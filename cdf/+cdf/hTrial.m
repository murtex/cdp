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

		function fval = is_valid( this, valmode, flab, fdet )
		% check trial validity
		%
		% fval = IS_VALID( this, valmode )
		%
		% INPUT
		% this : cue-distractor trial(s) (matrix object)
		% valmode : validity mode [raw | class | activity | TODO] (row char)
		% flab : manual response relevance flag (scalar logical)
		% fdet : detected response relevance flag (scalar logical)
		%
		% OUTPUT
		% fval : validity flag(s) (matrix logical)

				% safeguard
			if ~ismatrix( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( valmode ) || ~ischar( valmode )
				error( 'invalid argument: valmode' );
			end

			if nargin < 3 || ~isscalar( flab ) || ~islogical( flab )
				error( 'invalid argument: flab' );
			end

			if nargin < 4 || ~isscalar( fdet ) || ~islogical( fdet )
				error( 'invalid argument: fdet' );
			end

				% check validities
			fval = true( size( this ) );

			for i = 1:numel( this )
				trial = this(i);
				resplab = trial.resplab;
				respdet = trial.respdet;

				switch valmode

						% raw trial
					case 'raw'
						if any( isnan( trial.range ) ) || trial.range(1) >= trial.range(2)
							fval(i) = false;
						end

						% response class
					case 'class'
						if flab
							if isempty( resplab.label )
								fval(i) = false;
							end
						end
						if fdet
							if isempty( respdet.label )
								fval(i) = false;
							end
						end

						% response activity
					case 'activity'
						if flab
							if any( isnan( resplab.range ) ) || resplab.range(1) >= resplab.range(2)
								fval(i) = false;
							end
						end
						if fdet
							if any( isnan( respdet.range ) ) || respdet.range(1) >= respdet.range(2)
								fval(i) = false;
							end
						end

						% error
					otherwise
						error( 'invalid argument: valmode' );
				end
			end

		end

	end % public methods

end % classdef

