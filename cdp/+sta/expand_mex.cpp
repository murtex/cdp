/**
 * expand_mex.cpp
 * 20150513
 *
 * expand and center frames
 * 
 * COMPILE: mex 'expand_mex.cpp'
 *
 * INPUT
 * ser : time series (numeric)
 * frame : frame length and stride (pair numeric)
 *
 * OUTPUT
 * ser : expanded time series (numeric)
 */

	/* includes */
#include <algorithm>
#include <cmath>
#include <cstring>

#include "mex.h"

	/* matlab gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* extract inputs */
	int const serlen = mxGetM( rhs[0] );
	int const serwidth = mxGetN( rhs[0] );
	int const sernum = mxGetNumberOfElements( rhs[0] );
	double const * ser = mxGetPr( rhs[0] );

	double const * frame = mxGetPr( rhs[1] );
	int const overlap = (int) (frame[0]-frame[1]);

		/* prepare outputs */
	int const seroutlen = serlen * (int) frame[1] + overlap;

	lhs[0] = mxCreateNumericMatrix( seroutlen, serwidth, mxDOUBLE_CLASS, mxREAL );
	double * serout = mxGetPr( lhs[0] );

		/* expand frames */
	for ( int i = 0; i < sernum; ++i ) {
		int const offs = i/serlen * overlap;
		int const nums = (i % serlen == serlen-1) ? (frame[0]) : (frame[1]);

		std::fill_n( serout + i * (int) frame[1] + offs, nums, ser[i] );
	}

		/* center frames */
    int const f2 = (int) floor( frame[0]/2 );
	int const len = serlen * (int) frame[1] * sizeof( double );

	for ( int i = 0; i < serwidth; ++i ) {
		int const from = i*seroutlen;
		int const to = from + f2;

		memmove( serout + to, serout + from, len );
		std::fill_n( serout + from + 1, f2 - 1, *(serout + from) );
	}

}

