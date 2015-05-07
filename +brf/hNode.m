classdef hNode < matlab.mixin.Copyable
% treen node

		% properties
	properties (Access = public)

		impurity = NaN;

		left = brf.hNode.empty();
		right = brf.hNode.empty();

	end

end % classdef

