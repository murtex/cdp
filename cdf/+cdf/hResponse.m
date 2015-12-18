classdef (Sealed = true) hResponse < handle
% cue-distractor response

		% properties
	properties (Access = public)

			% activity
		range = [NaN, NaN]; % activity range [start, stop] (row numeric)

			% landmarks
		bo = NaN; % burst onset (scalar numeric)
		vo = NaN; % voice onset (scalar numeric)
		vr = NaN; % voice release (scalar numeric)

			% formants
		f0 = [NaN, NaN]; % f0 onset [time, frequency] (row numeric)
		f1 = [NaN, NaN]; % f1 onset [time, frequency] (row numeric)
		f2 = [NaN, NaN]; % f2 onset [time, frequency] (row numeric)
		f3 = [NaN, NaN]; % f3 onset [time, frequency] (row numeric)

			% classification
		label = ''; % response label (row char)

	end

		% public methods
	methods (Access = public)

		function fval = is_valid( this, valmode )
		% check response validity
		%
		% fval = IS_VALID( this, valmode )
		%
		% INPUT
		% this : cue-distractor response(s) (matrix object)
		% valmode : validity mode [class | activity | landmarks | formants] (row char)
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

				% check validities
			fval = true( size( this ) );

			for i = 1:numel( this )
				switch valmode

					case 'class'
						if isempty( this(i).label )
							fval(i) = false;
						end

					case 'activity'
						if any( isnan( this(i).range ) ) || this(i).range(1) >= this(i).range(2)
							fval(i) = false;
						end

					case 'landmarks'
						if isnan( this(i).bo ) || isnan( this(i).vo ) || isnan( this(i).vr ) ...
								|| this(i).bo >= this(i).vo || this(i).vo >= this(i).vr
							fval(i) = false;
						end

					case 'formants'
						if any( isnan( this(i).f0 ) ) || any( isnan( this(i).f1 ) ) || any( isnan( this(i).f2 ) ) || any( isnan( this(i).f3 ) ) ...
								|| this(i).f0(2) >= this(i).f1(2) || this(i).f1(2) >= this(i).f2(2) || this(i).f2(2) >= this(i).f3(2)
							fval(i) = false;
						end

					otherwise
						error( 'invalid argument: valmode' );
				end
			end

		end

	end % public methods

end % classdef

