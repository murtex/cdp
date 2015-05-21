/**
 * activity_mex.cpp
 * 20150515
 *
 * adaptive activity detection
 * 
 * INPUT
 * ser : noisy time series (vector numeric)
 * clser : clean time series (vector numeric)
 *
 * OUTPUT
 * actser : activity series (vector logical)
 * lothresh : lower activity threshold (scalar numeric)
 * hithresh : upper activity threshold (scalar numeric)
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
	double const * ser = mxGetPr( rhs[0] );
	int const serlen = mxGetNumberOfElements( rhs[0] );

	double const * clser = mxGetPr( rhs[1] );
	int const clserlen = mxGetNumberOfElements( rhs[1] );

		/* prepare outputs */
	lhs[0] = mxCreateLogicalMatrix( mxGetM( rhs[1] ), mxGetN( rhs[1] ) );
	mxLogical * actser = mxGetLogicals( lhs[0] );

	lhs[1] = mxCreateNumericMatrix( 1, 1, mxDOUBLE_CLASS, mxREAL );
	double & lothresh = mxGetPr( lhs[1] )[0];

	lhs[2] = mxCreateNumericMatrix( 1, 1, mxDOUBLE_CLASS, mxREAL );
	double & hithresh = mxGetPr( lhs[2] )[0];

		/* set adaptive thresholds */
	double sermin = 0;
	double sermax = 0;

	for ( int i = 0; i < serlen; ++i ) {
		if ( i == 0 ) {
			sermin = ser[i];
			sermax = ser[i];
		}
		else {
			if ( ser[i] < sermin )
				sermin = ser[i];
			if ( ser[i] > sermax )
				sermax = ser[i];
		}
	}

	lothresh = sermin * (1+2*log10( sermax/sermin )); /* based on noisy data */

	double avgexc = 0;
	int navgexc = 0;

	for ( int i = 0; i < clserlen; ++i )
		if ( clser[i] >= lothresh ) {
			avgexc += clser[i];
			navgexc++;
		}
	avgexc /= navgexc;

	hithresh = lothresh + 0.25*(avgexc - lothresh); /* based on clean data */

		/* set activity */
	int state = 1;
	int statelen = 0;

	for ( int i = 0; i < clserlen; ++i ) {
		switch ( state ) {

			case 1: /* no activity */
				if ( clser[i] >= lothresh ) {
					state = 2; /* start potential activity */
					statelen = 0;
				}
				break;

			case 2: /* potential activity */
				if ( clser[i] >= hithresh ) {
					std::fill_n( actser + i-statelen, statelen+1, true ); /* assured past/current activity */
					state = 3;
					statelen = 0;
				}
				else if ( clser[i] < lothresh ) {
					state = 1; /* denied activity */
					statelen = 0;
				}
				break;

			case 3: /* assured activity */
				if ( clser[i] < lothresh ) {
					state = 1; /* stop activity */
					statelen = 0;
				} else
					actser[i] = true;
				break;

		}

		statelen++;
	}
	
}

