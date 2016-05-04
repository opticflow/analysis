#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrix for input. */
    double *Z;
    /* Size */
    mwSignedIndex n;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 1 ) {
        mexErrMsgIdAndTxt("MATLAB:medainValue:rhs",
                "This function requires 1 input argument.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:medainValue:lhs",
                "This function requires 1 output argument.");
    }
    
    Z = mxGetPr(prhs[0]);
    n = (mwSignedIndex) mxGetM(prhs[0]);
        
    // Ensure that Z is a 2D matrix.
    if ( n < 1 || ((mwSignedIndex) mxGetN(prhs[0])) > 1 ) {
        mexErrMsgIdAndTxt("MATLAB:medainValue", "Z must be a 1D column-vector.");
    }
    
    plhs[0] = mxCreateDoubleScalar(median(Z, n));
}
