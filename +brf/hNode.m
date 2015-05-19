classdef hNode < matlab.mixin.Copyable
% tree node

		% properties
	properties (Access = public)

		label = NaN; % node label (scalar numeric)
		impurity = NaN; % node impurity (scalar numeric)

		feature = NaN; % split feature (scalar numeric)
		value = NaN; % split value (scalar numeric)

		left = brf.hNode.empty(); % left child node (scalar object)
		right = brf.hNode.empty(); % right child node (scalar object)

	end

		% methods
	methods (Access = public)

			% conversion
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

			% statistics
		function [nodes, depth] = stats( this, nodes, depth )
		% tree statistics
		%
		% [nodes, depth] = STATS( this, nodes=0, depth=0 )
		%
		% INPUT
		% this : tree node (scalar object)
		% nodes : number of nodes (scalar numeric)
		% depth : maximum tree depth (scalar numeric)
		%
		% OUTPUT
		% nodes : number of nodes (scalar numeric)
		% depth : maximum tree depth (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2
				nodes = 0;
			end
			if ~isscalar( nodes ) || ~isnumeric( nodes )
				error( 'invalid argument: nodes' );
			end

			if nargin < 3
				depth = 0;
			end
			if ~isscalar( depth ) || ~isnumeric( depth )
				error( 'invalid argument: depth' );
			end

				% gather statistics recursively
			if ~isempty( this.left )
				[nodes, depth] = this.left.stats( nodes, depth );
			end
			if ~isempty( this.right )
				[nodes, depth] = this.right.stats( nodes, depth );
			end

			nodes = nodes + 1;

		end

	end

end % classdef

