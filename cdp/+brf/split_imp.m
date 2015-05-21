function imps = split_imp( occs, vis )
% get split impurities
%
% imps = SPLIT_IMP( occs, vis )
%
% INPUT
% occs : class occupations (matrix numeric)
% vis : split feature value indices (vector numeric)
%
% OUTPUT
% imps : split impurities (column numeric)

		% safeguard
	%if nargin < 1 || ~ismatrix( occs ) || ~isnumeric( occs )
		%error( 'invalid argument: occs' );
	%end

	%if nargin < 2 || ~isvector( vis ) || ~isnumeric( vis )
		%error( 'invalid argument: vis' );
	%end

		% proceed value indices
	nclasses = size( occs, 1 );
	nsamples = size( occs, 2 );
	nvis = numel( vis );

	imps = NaN( nvis, 1 ); % pre-allocation

	for i = 1:nvis

			% set child impurities
		nlsamples = vis(i) - 1;
		nrsamples = nsamples - nlsamples;

		limp = 1;
		rimp = 1;
		for j = 1:nclasses
			limp = limp - (occs(j, nlsamples) / nlsamples)^2;
			rimp = rimp - ((occs(j, end)-occs(j, nlsamples)) / nrsamples)^2;
		end

			% set split impurity
		imps(i) = (limp*nlsamples + rimp*nrsamples) / nsamples;

	end
	
end

