#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrix for input, temporary, and output. */
    double *Z, *ZTmp, v; // v return value, *Z input values.
    /* Size */
    mwSignedIndex n;
    /* k-th smallest element */
    int k;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:imresize:rhs",
                "This function requires 2 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:imresize:lhs",
                "This function requires 1 output argument.");
    }
    
    k = (int) mxGetScalar(prhs[1]);
    n = (mwSignedIndex) mxGetM(prhs[0]);
    
    // Ensure that Z is a 1D column vector.
    if ( n < 1 || ((mwSignedIndex) mxGetN(prhs[0])) > 1 ) {
        mexErrMsgIdAndTxt("MATLAB:selectKth", "Z must be a 1D column-vector.");
    }
    // The index k must range have the range 1 <= k <= n.
    if ( k < 1 || k > n ) {
        mexErrMsgIdAndTxt("MATLAB:selectKth", "k must be >= 1 and <= n.");
    }
    
    Z = mxGetPr(prhs[0]);
    ZTmp = (double*) malloc(n * sizeof(double)); // Create copy because Z will be changed!
    memcpy(ZTmp, Z, n * sizeof(double));
    
    v = selectKth(ZTmp, n, k-1); // k-1 to match index range 0...n-1
        
    plhs[0] = mxCreateDoubleScalar(v);
    
    free(ZTmp);
}
