function fredo = disp_update( src, fredo )
% toggle update flag
%
% fredo = DISP_UPDATE( src, fredo )
%
% INPUT
% src : event source handle (internal)
% fredo : redo flag (scalar logical)

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

