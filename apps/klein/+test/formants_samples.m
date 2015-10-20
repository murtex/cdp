function formants_samples( indir, outdir, ids, seed, nsamples, type )
% formants detection samples
%
% FORMANTS_SAMPLES( indir, outdir, ids, seed, nsamples, type )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% seed : random seed (scalar numeric)
% nsamples : number of trial samples (scalar numeric)
% type : sample type [TODO] (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	elseif exist( outdir, 'dir' ) ~= 7
		mkdir( outdir );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids )
		error( 'invalid argument: ids' );
	end

	if nargin < 4 || ~isscalar( seed ) || ~isnumeric( seed )
		error( 'invalid argument: seed' );
	end

	if nargin < 5 || ~isscalar( nsamples ) || ~isnumeric( nsamples )
		error( 'invalid argument: nsamples' );
	end

	if nargin < 6 || ~isrow( type ) || ~ischar( type )
		error( 'invalid argument: type' );
	end

end

