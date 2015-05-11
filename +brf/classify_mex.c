/**
 * classfiy_mex.c
 * 20150510
 *
 * classify features
 *
 * COMPILE: mex 'classify_mex.c'
 *
 * INPUT
 * roots : tree root nodes (row object)
 * features : feature matrix (matrix numeric)
 * 
 * OUTPUT
 * labels : prediction labels (matrix numeric)
 */

	/* includes */
#include "mex.h"

	/* input extraction */
double
get_val( mxArray const * matrix, int index, int field )
{
	double const * label = mxGetPr( mxGetFieldByNumber( matrix, index, field ) );

	if ( label == NULL )
		return 0;

	return label[0];
}

mxArray const *
get_node( mxArray const * matrix, int index, int field )
{
	mxArray const * node = mxGetFieldByNumber( matrix, index, field );

	if ( node == NULL || mxGetNumberOfElements( node ) == 0 )
		return NULL;

	return node;
}

	/* gateway */
void
mexFunction( int nlhs, mxArray ** lhs, int nrhs, mxArray const ** rhs )
{

		/* safeguard */
	if ( nrhs < 1 || 
			mxGetNumberOfDimensions( rhs[0] ) != 2 || mxGetM( rhs[0] ) != 1 )
		mexErrMsgTxt( "invalid argument: roots" );

	if ( nrhs < 2 || 
			mxGetNumberOfDimensions( rhs[1] ) != 2 )
		mexErrMsgTxt( "invalid argument: features" );

		/* extract inputs */
	int const nroots = mxGetN( rhs[0] );

	int field_label = mxGetFieldNumber( rhs[0], "label" );
	int field_feature = mxGetFieldNumber( rhs[0], "feature" );
	int field_value = mxGetFieldNumber( rhs[0], "value" );
	int field_left = mxGetFieldNumber( rhs[0], "left" );
	int field_right = mxGetFieldNumber( rhs[0], "right" );

	int const nsamples = mxGetM( rhs[1] );
	int const nfeatures = mxGetN( rhs[1] );
	double const * features = mxGetPr( rhs[1] );

		/* prepare outputs */
	lhs[0] = mxCreateNumericMatrix( nroots, nsamples, mxDOUBLE_CLASS, mxREAL );
	double * labels = mxGetPr( lhs[0] );

		/* proceed samples */
	mxArray const * node;
	double label;
	double feature;
	double value;
	mxArray const * left;
	mxArray const * right;

	int i;
	for ( i = 0; i < nsamples; ++i ) {

			/* proceed roots */
		int j;
		for ( j = 0; j < nroots; ++j ) {

				/* proceed tree down to leaf */
			node = rhs[0];
			label = get_val( node, j, field_label );
			feature = get_val( node, j, field_feature );
			value = get_val( node, j, field_value );
			left = get_node( node, j, field_left );
			right = get_node( node, j, field_right );

			while ( left != NULL || right != NULL ) {
				if ( features[((int) (feature-1))*nsamples + i] < value ) { /* check left node */
					if ( left == NULL )
						break; /* found leaf */
					else {
						node = left; /* continue recursively */
						label = get_val( node, 0, field_label );
						feature = get_val( node, 0, field_feature );
						value = get_val( node, 0, field_value );
						left = get_node( node, 0, field_left );
						right = get_node( node, 0, field_right );
					}
				}
				else { /* check right node */
					if ( right == NULL )
						break; /* found leaf */
					else {
						node = right; /* continue recursively */
						label = get_val( node, 0, field_label );
						feature = get_val( node, 0, field_feature );
						value = get_val( node, 0, field_value );
						left = get_node( node, 0, field_left );
						right = get_node( node, 0, field_right );
					}
				}
			}

				/* vote for leaf label */
			labels[i*nroots + j] = label;

		}
	}

}

