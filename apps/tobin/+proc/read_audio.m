function read_audio( run, audiodir )
% read raw audio data
%
% READ_AUDIO( run, audiodir )
%
% INPUT
% run : cue-distractor run (scalar object)
% audiodir : wav audio directory (row char)

		% safeguard
	if nargin < 1 || ~isscalar( run ) || ~isa( run, 'cdf.hRun' )
		error( 'invalid argument: run' );
	end

	if nargin < 2 || ~isrow( audiodir ) || ~ischar( audiodir )
		error( 'invalid argument: audiodir' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'read raw audio data (''%s'')...', audiodir );

		% join single audio files
	flist = dir( fullfile( audiodir, '*.wav' ) );

	run.audiodata = []; % pre-allocation
	run.audiorate = NaN;

	for i = 1:numel( flist )

			% read audio data
		audiofile = fullfile( audiodir, flist(i).name );

		if exist( 'audioread' )
			[audiodata, audiorate] = audioread( audiofile );
		else
			[audiodata, audiorate] = wavread( audiofile );
		end

			% join audio data
		audiodata = cat( 2, audiodata, zeros( size( audiodata ) ) ); % make two-channel

		run.audiodata = cat( 1, run.audiodata, audiodata ); % concatenate
		run.audiorate = audiorate;

	end

		% logging
	logger.log( 'rate: %d', run.audiorate );
	logger.log( 'channels: %d', size( run.audiodata, 2 ) );
	logger.log( 'length: %.3fs', dsp.smp2sec( size( run.audiodata, 1 ), run.audiorate ) );

	logger.untab();
end

