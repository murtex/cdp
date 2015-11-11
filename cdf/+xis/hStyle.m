classdef (Sealed = true) hStyle < handle
% uniform styling (singleton)
%
% SEE
% The Color Scheme Designer: http://paletton.com/#uid=30m0l1kt5kgiutFprq0B5eKPr7VkmKooaAEFhttfroje-LcmkeQfG7qsMcim5lrcSs182

		% properties
	properties (GetAccess = public, SetAccess = private)
	end

		% public methods
	methods (Access = public)

		function fig = figure( this, varargin )
		% create figure
		%
		% fig = FIGURE( this, ... )
		%
		% INPUT
		% this : style (scalar object)
		% ... : additional properties
		%
		% OUTPUT
		% fig : figure (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% create figure
			ws = warning(); % disable warnings
			warning( 'off', 'all' );

			fig = figure( ...
				'Visible', 'off', ...
				'Color', this.color( 'grey', this.scale( -1/3 ) ), ...
				'InvertHardCopy', 'off', ...
				'defaultTextInterpreter', 'none', ...
				'defaultTextFontSize', 7, 'defaultAxesFontSize', 7, ...
				'defaultAxesFontName', 'Courier', ...
				'defaultAxesNextPlot', 'add', ...
				'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
				'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
				varargin{:} );

				%'GraphicsSmoothing', 'off', ...
				%'defaultLegendColor', this.color( 'grey', this.scale( -1/6 ) ), ...
				%'defaultTextFontSmoothing', 'off', 'defaultAxesFontSmoothing', 'off', ...
				%'defaultAxesTitleFontSizeMultiplier', this.scale( 1/4 ), 'defaultAxesLabelFontSizeMultiplier', 1, ...

				%'defaultAxesGridColor', this.color( 'neutral', -2 ), ...

			warning( ws ); % (re-)enable warnings
	
		end

		function print( this, figfile )
		% print figure
		%
		% print( this, figfile )
		%
		% INPUT
		% this : style (scalar object)
		% figfile : plot filename (row char)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( figfile ) || ~ischar( figfile )
				error( 'invalid argument: figfile' );
			end

				% print figure
			print( figfile, '-dpng', '-r128' );

			%imwrite( hardcopy( gcf(), '-dzbuffer', '-r120' ), sprintf( '%s.png', figfile ), 'png' );

		end

		function rgb = color( this, name, shade )
		% get color
		%
		% rgb = COLOR( this, id, shade )
		%
		% INPUT
		% this : style (scalar object)
		% name : color name (row char)
		% shade : color shade (scalar numeric)
		%
		% OUTPUT
		% rgb : rgb-values (row numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( name ) || ~ischar( name )
				error( 'invalid argument: name' );
			end

			if nargin < 3 || ~isscalar( shade ) || ~isnumeric( shade )
				error( 'invalid argument: shade' );
			end

				% clamp color shade
			switch name
				case 'grey'
					shade(shade < 0) = 0;
					shade(shade > 1) = 1;
				otherwise
					shade(shade < -2) = -2;
					shade(shade > +2) = +2;
			end

				% base colors
			white = [1, 1, 1];

			function rgb = cold( shade )
				switch round( shade )
					case -2
						rgb = [3, 39, 63];
					case -1
						rgb = [19, 67, 98];
					case 0
						rgb = [41, 92, 124];
					case +1
						rgb = [73, 119, 149];
					case +2
						rgb = [131, 167, 191];
				end

				rgb = rgb / 255;
			end

			function rgb = warm( shade )
				switch round( shade )
					case -2
						rgb = [6, 50,  9];
					case -1
						rgb = [27, 81, 30];
					case 0
						rgb = [53, 98, 56];
					case +1
						rgb = [85, 138, 89];
					case +2
						rgb = [139, 180, 141];
				end

				rgb = rgb / 255;
			end

			function rgb = signal( shade )
				switch round( shade )
					case -2
						rgb = [63, 23,  0];
					case -1
						rgb = [117, 44,  0];
					case 0
						rgb = [161, 69, 15];
					case +1
						rgb = [207,104, 43];
					case +2
						rgb = [236,151,100];
				end

				rgb = rgb / 255;
			end

			function rgb = neutral( shade )
				rgb = mean( (cold( shade ) + warm( shade ) + signal( shade )) / 3 ) * [1, 1, 1];
			end

				% set shaded color
			rgb1 = neutral( 0 );
			rgb2 = neutral( 0 );

			switch name
				case 'cold'
					rgb1 = cold( floor( shade ) );
					rgb2 = cold( ceil( shade ) );
				case 'warm'
					rgb1 = warm( floor( shade ) );
					rgb2 = warm( ceil( shade ) );
				case 'signal'
					rgb1 = signal( floor( shade ) );
					rgb2 = signal( ceil( shade ) );
				case 'neutral'
					rgb1 = neutral( floor( shade ) );
					rgb2 = neutral( ceil( shade ) );
				case 'grey'
					rgb1 = shade * white;
					rgb2 = rgb1;
				otherwise
					error( 'invalid argument: name' );
			end

			rgb = (rgb1 + rgb2) / 2;

		end

		function cols = gradient( this, n, col1, col2 )
		% get two-color gradient
		%
		% cols = GRADIENT( this, n, col1, col2 )
		%
		% INPUT
		% this : style (scalar object)
		% n : number of shades (scalar numeric)
		% col1 : first color (row numeric)
		% col2 : seconds color (row numeric)
		%
		% OUTPUT
		% cols : gradient colors (matrix numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isscalar( n ) || ~isnumeric( n )
				error( 'invalid argument: n' );
			end

			if nargin < 3 || ~isrow( col1 ) || ~isnumeric( col1 )
				error( 'invalid argument: col1' );
			end

			if nargin < 4 || ~isrow( col2 ) || ~isnumeric( col2 ) || numel( col2 ) ~= numel( col1 )
				error( 'invalid argument: col2' );
			end

				% set gradient colors
			m = numel( col1 );

			cols = zeros( n, m ); % pre-allocation

			for i = 1:m
				cols(:, i) = linspace( col1(i), col2(i), n );
			end

		end

		function s = scale( this, rank )
		% get scale factor
		%
		% s = SCALE( this, rank )
		%
		% INPUT
		% this : style (scalar object)
		% rank : scale rank (scalar numeric)
		%
		% OUTPUT
		% scale : scale factor (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isscalar( rank ) || ~isnumeric( rank )
				error( 'invalid argument: rank' );
			end

				% set rankd scale
			s = 2^(rank * 1/2);

		end

		function k = bins( this, data )
		% optimal number of histogram bins
		%
		% k = bins( this, data )
		%
		% INPUT
		% this : style (scalar object)
		% data : data (vector numeric)
		%
		% OUTPUT
		% k : number of bins (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isvector( data ) || ~isnumeric( data )
				error( 'invalid argument: data' );
			end

				% try several rules (some would return less than a single bin)
			n = numel( data );

			ks = []; % pre-allocation

			g1 = skewness( data ); % doane's formula
			sigmag1 = sqrt( 6*(n-2) / ((n+1)*(n+3)) );
			ks(end+1) = round( 1 + log2( n ) + log2( 1 + abs( g1 )/sigmag1 ) );

			ks(end+1) = round( 3.5 * std( data ) / (n^(1/3)) ); % scott's normal reference rule

			ks(end+1) = round( 2 * iqr( data ) / (n^(1/3)) ); % freedman-diaconis rule

				% choose maximum number of bins
			k = max( ks );

		end

	end % public methods

		% static methods
	methods (Static = true)

		function that = instance()
		% class singleton
		%
		% that = INSTANCE()
		%
		% OUTPUT
		% that : style (scalar object)

				% ensure singleton validity
			persistent this;

			if isempty( this )
				this = xis.hStyle(); % create instance
			end

				% return singleton
			that = this;

		end

	end % static methods

		% private methods
	methods (Access = private)

		function this = hStyle()
		% class constructor
		%
		% this = HSTYLE()
		%
		% OUTPUT
		% this : style (scalar object)

			% nop

		end

	end % private methods

end % classdef

