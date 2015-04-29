function read_audio( run, audiofile, info_only )
% read audio data
%
% READ_AUDIO( run, audiofile )
%
% INPUT
% run : run (scalar object)
% audiofile : audio filename (row char)
% info_only : read audio info only (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( audiofile ) || ~ischar( audiofile ) || exist( audiofile, 'file' ) ~= 2
		error( 'invalid argument: audiofile' );
	end

	if nargin < 3 || ~isscalar( info_only ) || ~islogical( info_only )
		error( 'invalid argument: info_only' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read audio ''%s''...', audiofile );

		% read audio data/info
	run.audiofile = audiofile;

	if info_only
		[~, rate] = wavread( audiofile, 1 );
		len = wavread( audiofile, 'size' );

		run.audiodata = [];
		run.audiolen = len(1);
		run.audiorate = rate;	
	else
		[run.audiodata, run.audiorate] = wavread( audiofile, 'double' );
		run.audiolen = size( run.audiodata, 1 );
	end

	run.audiodata = single( run.audiodata ); % single precision

	logger.log( 'rate: %dHz', run.audiorate );
	logger.log( 'length: %.1fs', dsp.smp2sec( run.audiolen, run.audiorate ) );

	logger.untab();
end

