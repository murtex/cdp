function read_audio( run, audiofile )
% read raw audio data
%
% READ_AUDIO( run, audiofile )
%
% INPUT
% run : cue-distractor run (scalar object)
% audiofile : wav audio filename (row char)
%
% SEE
% https://stackoverflow.com/questions/5591278/high-pass-filtering-in-matlab

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( audiofile ) || ~ischar( audiofile )
		error( 'invalid argument: audiofile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read raw audio data (''%s'')...', audiofile );

		% read audio file
	run.audiofile = audiofile;

	if exist( 'audioread' )
		[run.audiodata, run.audiorate] = audioread( audiofile );
	else
		[run.audiodata, run.audiorate] = wavread( audiofile );
	end

		% pre-process audio data
	run.audiodata(:, 1) = run.audiodata(:, 1) - mean( run.audiodata(:, 1) ); % remove dc
	run.audiodata(:, 2) = run.audiodata(:, 2) - mean( run.audiodata(:, 2) );

		% logging
	logger.log( 'rate: %d', run.audiorate );
	logger.log( 'channels: %d', size( run.audiodata, 2 ) );
	logger.log( 'length: %.3fs', dsp.smp2sec( size( run.audiodata, 1 ), run.audiorate ) );

	logger.untab();
end

