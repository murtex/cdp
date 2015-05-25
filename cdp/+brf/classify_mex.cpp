/**
 * classify_mex.cpp
 * 20150525
 *
 * classify features
 * 
 * INPUT
 * forest : trees (row struct)
 * features : feature matrix (matrix numeric)
 *
 * OUTPUT
 * labels : prediction labels (matrix numeric)
 */

	/* includes */
#include <cmath>

#include "mex.h"

	/* matlab gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* extract inputs */
	int const ntrees = mxGetN( rhs[0] );

	int const field_labels = mxGetFieldNumber( rhs[0], "labels" );
	int const field_features = mxGetFieldNumber( rhs[0], "features" );
	int const field_values = mxGetFieldNumber( rhs[0], "values" );
	int const field_lefts = mxGetFieldNumber( rhs[0], "lefts" );
	int const field_rights = mxGetFieldNumber( rhs[0], "rights" );

	int const nsamples = mxGetM( rhs[1] );
	int const nfeatures = mxGetN( rhs[1] );
	double const * features = mxGetPr( rhs[1] );

		/* prepare outputs */
	lhs[0] = mxCreateNumericMatrix( ntrees, nsamples, mxDOUBLE_CLASS, mxREAL );
	double * labels = mxGetPr( lhs[0] );

		/* proceed samples */
	for ( int i = 0; i < nsamples; ++i ) {

			/* proceed trees */
		for ( int j = 0; j < ntrees; ++j ) {

				/* proceed down to leaf */
			int node = 0;

			double const * tlabels = mxGetPr( mxGetFieldByNumber( rhs[0], j, field_labels ) );
			double const * tfeatures = mxGetPr( mxGetFieldByNumber( rhs[0], j, field_features ) );
			double const * values = mxGetPr( mxGetFieldByNumber( rhs[0], j, field_values ) );
			double const * lefts = mxGetPr( mxGetFieldByNumber( rhs[0], j, field_lefts ) );
			double const * rights = mxGetPr( mxGetFieldByNumber( rhs[0], j, field_rights ) );
			
			while ( !isnan( lefts[node] ) || !isnan( rights[node] ) )
				if ( features[((int) (tfeatures[node]-1))*nsamples + i] < values[node] ) {
					if ( isnan( lefts[node] ) )
						break; /* found leaf */
					else
						node = lefts[node] - 1;
				}
				else {
					if ( isnan( rights[node] ) )
						break; /* found leaf */
					else
						node = rights[node] - 1;
				}

				/* vote for leaf label */
			labels[i*ntrees + j] = tlabels[node];

		}
	}

}

