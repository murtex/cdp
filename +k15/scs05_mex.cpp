/**
 * scs05_mex.cpp
 * 20150512
 *
 * get activity start by statistics
 *
 * COMPILE: mex 'scs05_mex.cpp'
 *
 * INPUT
 * ser : time series (vector numeric)
 * vic : forward vicinity to check (scalar numeric)
 * sigma : standard deviation threshold (scalar numeric)
 *
 * OUTPUT
 * asi : activity start index (scalar numeric)
 */

	/* includes */
#include <cmath>

#include "mex.h"

	/* matlab gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* extract inputs */
	double const * ser = mxGetPr( rhs[0] );
	size_t const serlen = mxGetNumberOfElements( rhs[0] );

	double const vic = mxGetPr( rhs[1] )[0];
	double const sigma = mxGetPr( rhs[2] )[0];

		/* prepare output */
	lhs[0] = mxCreateNumericMatrix( 1, 1, mxDOUBLE_CLASS, mxREAL );
	double & asi = mxGetPr( lhs[0] )[0];

		/* estimate mean and standard deviation */
	double sermu = 0;
	double sersigma = 0;

	for ( int i = 0; i < serlen; ++i )
		sermu += ser[i];
	sermu /= serlen;

	for ( int i = 0; i < serlen; ++i )
		sersigma += (ser[i]-sermu)*(ser[i]-sermu);
	sersigma /= serlen;
	sersigma = sqrt( sersigma );

		/* proceed series */
	asi = NAN;

	for ( int i = 0; i < serlen; ++i ) {

			/* get mean mahalanobis distance of forward vicinit */
		double mmd = 0;

		int vicstop = i + vic;
		if ( vicstop > serlen )
			vicstop = serlen;

		for ( int j = i; j < vicstop; ++j )
			mmd += fabs( ser[j]-sermu );

		mmd /= sersigma * vic;

			/* check against sigma threshold */
		if ( mmd >= sigma ) {
			asi = i+1;
			break;
		}

	}

}

