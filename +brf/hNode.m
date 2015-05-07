classdef hNode < matlab.mixin.Copyable
% treen node

		% properties
	properties (Access = public)

		impurity = NaN; % gini impurity index (scalar numeric)

		feature = NaN; % split feature (scalar numeric)
		value = NaN; % split value (scalar numeric)

		left = brf.hNode.empty(); % left child node (scalar object)
		right = brf.hNode.empty(); % right child node (scalar object)

	end

end % classdef

