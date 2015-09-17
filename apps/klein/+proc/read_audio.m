function read_audio( run, audiofile, readdata )
% read audio data
%
% READ_AUDIO( run, audiofile, readdata )
%
% INPUT
% run : cue-distractor run (scalar object)
% audiofile : audio filename (row char)
% readdata : read data flag (scalar logical)
%
% TODO
% wavread is deprecated, use audioread!

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( audiofile ) || ~ischar( audiofile )
		error( 'invalid argument: audiofile' );
	end

	if nargin < 3 || ~isscalar( readdata ) || ~islogical( readdata )
		error( 'invalid argument: readdata' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read audio data (''%s'')...', audiofile );

	ws = warning(); % disable warnings
	warning( 'off', 'all' );

		% read audio info
	run.audiofile = audiofile;

	run.audiosize = wavread( audiofile, 'size' );
	[~, run.audiorate, ~] = wavread( audiofile, 0 );

		% read audio data
	if readdata
		run.audiodata = wavread( audiofile, 'double' );
	end

	warning( ws ); % (re-)enable warnings

		% logging
	logger.log( 'rate: %d/s', run.audiorate );
	logger.log( 'channels: %d', run.audiosize(2) );
	logger.log( 'length: %.3fs', dsp.smp2sec( run.audiosize(1)-1, run.audiorate ) );
	
	logger.untab();
end

