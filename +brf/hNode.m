classdef hNode < matlab.mixin.Copyable
% tree node

		% properties
	properties (Access = public)

		label = NaN; % majority class label (scalar numeric)

		feature = NaN; % split feature (scalar numeric)
		value = NaN; % split value (scalar numeric)

		left = brf.hNode.empty(); % left child node (scalar object)
		right = brf.hNode.empty(); % right child node (scalar object)

	end

		% methods
	methods (Access = public)

		function s = rstruct( this )
		% convert to struture
		%
		% s = RSTRUCT( this )
		%
		% INPUT
		% this : tree node (scalar object)
		%
		% OUTPUT
		% s : tree node structure (scalar struct)
		
				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% convert recursively
			s = struct( this );

			if ~isempty( this.left )
				s.left = this.left.rstruct();
			end
			if ~isempty( this.right )
				s.right = this.right.rstruct();
			end

		end

	end

end % classdef

