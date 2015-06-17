function read_labels( run, labelfile )
% read label data
%
% READ_LABELS( run, labelfile )
%
% INPUT
% run : cue-distractor run (scalar object)
% labelfile : label filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( labelfile ) || ~ischar( labelfile )
		error( 'invalid argument: labelfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read label data (''%s'')...', labelfile );
	
	logger.untab();
end

