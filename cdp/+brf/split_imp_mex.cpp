/**
 * split_imp_mex.cpp
 * 20150518
 *
 * get split impurities
 *
 * INPUT
 * occs : class occupations (matrix numeric)
 * vis : split feature value indices (vector numeric)
 *
 * OUTPUT
 * imps : split impurities (column numeric)
 */

	/* includes */
#include <cmath>
#include <algorithm>

#include "mex.h"

	/* matlab gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* extract inputs */
	int const nclasses = mxGetM( rhs[0] );
	int const nsamples = mxGetN( rhs[0] );
	double const * occs = mxGetPr( rhs[0] );

	int const nvis = mxGetNumberOfElements( rhs[1] );
	double const * vis = mxGetPr( rhs[1] );

		/* prepare outputs */
	lhs[0] = mxCreateNumericMatrix( nvis, 1, mxDOUBLE_CLASS, mxREAL );
	double * imps = mxGetPr( lhs[0] );

	std::fill_n( imps, nvis, NAN );

		/* proceed value indices */
	for ( int i = 0; i < nvis; ++i ) {

			/* set child impurities */
		int const nlsamples = vis[i] - 1;
		int const nrsamples = nsamples - nlsamples;

		double limp = 1;
		double rimp = 1;
		for ( int j = 0; j < nclasses; ++j ) {

			double const locc = occs[(nlsamples-1)*nclasses + j];
			double const rocc = occs[(nsamples-1)*nclasses + j] - locc;

			limp -= (locc/nlsamples)*(locc/nlsamples);
			rimp -= (rocc/nrsamples)*(rocc/nrsamples);
		}

			/* set split impurity */
		imps[i] = (limp*nlsamples + rimp*nrsamples) / nsamples;

	}
	
}

