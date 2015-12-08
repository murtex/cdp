function disp_update( src )
% toggle update flag
%
% DISP_UPDATE( src )
%
% INPUT
% src : event source handle (internal)

		% safeguard
	if nargin < 1
		error( 'invalid argument: src' );
	end

		% switch (unused) clipping property
	switch get( src, 'Clipping' )
		case 'on'
			set( src, 'Clipping', 'off' );
		case 'off'
			set( src, 'Clipping', 'on' );
	end

end

