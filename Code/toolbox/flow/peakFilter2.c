#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrix for input and temporary. */
    double *Z, *ZTmp;
    /* Sizes */
    mwSignedIndex nY, nX;
    /* Error number/code */
    int errNo;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 1 ) {
        mexErrMsgIdAndTxt("MATLAB:peakFilter2:rhs",
                "This function requires 1 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:peakFilter2:lhs",
                "This function requires 1 output argument.");
    }
    
    // Ensure that Z is a 2D matrix.
    if ( mxGetNumberOfDimensions(prhs[0]) != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:peakFilter2", "Z must be a 2D matrix.");
    }
    
    
    Z   = mxGetPr(prhs[0]);
    nY  = (mwSignedIndex) mxGetM(prhs[0]);
    nX  = (mwSignedIndex) mxGetN(prhs[0]);
        
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    ZTmp    = mxGetPr(plhs[0]);
    
    // Copy the input values to the output.
    memcpy(ZTmp, Z, nX * nY * sizeof(double));
    
    errNo = peakFilter2(ZTmp, nX, nY);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2", 
                "Unkown boundary type or incompatible input size.");
    }
}
