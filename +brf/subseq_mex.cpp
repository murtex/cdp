/**
 * subseq_mex.cpp
 * 20150515
 *
 * generate subsequences of features
 * 
 * INPUT
 * featser : prime features time series (matrix numeric)
 * intlen : minimum interval length (scalar numeric)
 * intcount : number of intervals (scalar numeric)
 *
 * OUTPUT
 * subser : series of subsequence features (numeric)
 */

	/* includes */
#include <cmath>
#include <algorithm>

#include "mex.h"

	/* defines */
#define NLOCFEATS 2
#define NSUBFEATS 2
#define NINTFEATS 3

	/* helpers */
int
randmm( int min, int max )
{
	return rand() % (max-min+1) + min;
}

	/* matlab gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* extract inputs */
	int const featserlen = mxGetM( rhs[0] );
	int const featserwidth = mxGetN( rhs[0] );

	double const * featser = mxGetPr( rhs[0] );

	int const intlen = (int) mxGetPr( rhs[1] )[0];
	int const intcount = (int) mxGetPr( rhs[2] )[0];
	
		/* prepare outputs */
	int const r = featserlen/intlen;
	int const subserlen = r - intcount;

	if ( subserlen < 1 ) {
		lhs[0] = mxCreateNumericMatrix( 0, 0, mxDOUBLE_CLASS, mxREAL );
		return;
	} else
		lhs[0] = mxCreateNumericMatrix( subserlen, NLOCFEATS + featserwidth*(NSUBFEATS + intcount*NINTFEATS),
				mxDOUBLE_CLASS, mxREAL );

	double * subser = mxGetPr( lhs[0] );

	std::fill_n( subser, mxGetNumberOfElements( lhs[0] ), NAN );

		/* proceed subsequences */
	for ( int i = 0; i < subserlen; ++i ) {

			/* subsample random range (constrained by interval settings) */
		int const rndintlen = randmm( intlen, featserlen/intcount );

		int const sublen = intcount*rndintlen;
		int const substart = randmm( 0, featserlen - intcount*rndintlen );

			/* set location features */
		subser[0*subserlen + i] = (double) substart / (featserlen-1);
		subser[1*subserlen + i] = (double) (substart+sublen-1) / (featserlen-1);

			/* prepare vandermonde buffer for slope regression */
		double * vand = (double *) mxMalloc( rndintlen * sizeof( double ) );
		for ( int j = 0; j < rndintlen; ++j )
			vand[j] = j - (double) rndintlen/2;

		double sx = 0;
		for ( int j = 0; j < rndintlen; ++j )
			sx += vand[j]*vand[j];

			/* proceed prime features */
		for ( int j = 0; j < featserwidth; ++j ) {

				/* set sequence features */
			double mean = 0;
			for ( int k = substart; k < substart+sublen; ++k )
				mean += featser[j*featserlen + k];
			mean /= sublen;

			double var = 0;
			for ( int k = substart; k < substart+sublen; ++k )
				var += (featser[j*featserlen + k]-mean)*(featser[j*featserlen + k]-mean);
			var /= sublen;

			int const joffs = NLOCFEATS + j*(NSUBFEATS + intcount*NINTFEATS);
			subser[(joffs + 0)*subserlen + i] = mean;
			subser[(joffs + 1)*subserlen + i] = var;

				/* proceed intervals */
			for ( int k = 0; k < intcount; ++k ) {

					/* set interval features */
				mean = 0;
				for ( int l = substart + k*rndintlen; l < substart + (k+1)*rndintlen; ++l )
					mean = featser[j*featserlen + l];
				mean /= rndintlen;

				var = 0;
				for ( int l = substart + k*rndintlen; l < substart + (k+1)*rndintlen; ++l )
					var = (featser[j*featserlen + l])*(featser[j*featserlen + l]);
				var /= rndintlen;

				double sxy = 0;
				for ( int l = substart + k*rndintlen; l < substart + (k+1)*rndintlen; ++l )
					sxy += vand[l - substart - k*rndintlen] * featser[j*featserlen + l];
				double const slope = sxy/sx;

				int const koffs = joffs + NSUBFEATS + k*NINTFEATS;
				subser[(koffs + 0)*subserlen + i] = mean;
				subser[(koffs + 1)*subserlen + i] = var;
				subser[(koffs + 2)*subserlen + i] = slope;

			}

		}

		mxFree( vand ); /* release vandermonde buffer */ 

	}

}

