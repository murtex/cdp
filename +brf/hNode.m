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

		function s = mexify( this )
		% convert class to struture (for mex-file usage)
		%
		% s = MEXIFY( this )
		%
		% INPUT
		% this : tree node (object)
		%
		% OUTPUT
		% s : tree node structure (struct)

				% proceed array elements
			n = numel( this );

			for i = n:-1:1

					% convert recursively
				s(i) = struct( this(i) );

				if ~isempty( this(i).left )
					s(i).left = this(i).left.mexify();
				end
				if ~isempty( this(i).right )
					s(i).right = this(i).right.mexify();
				end

			end

			s = reshape( s, size( this ) );

		end

	end

end % classdef

