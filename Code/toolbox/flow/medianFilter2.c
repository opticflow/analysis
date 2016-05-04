#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *Z, *I, *F; // F return value, Z input, Interval y,x.
    /* Sizes */
    mwSignedIndex nY, nX, nKy, nKx;
    /* Type for interpolation. */
    char *boundaryType;
    /* Error number/code */
    int errNo;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 3 ) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2:rhs",
                "This function requires 3 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2:lhs",
                "This function requires 1 output argument.");
    }
    
    // Ensure that Z is a 2D matrix.
    if ( mxGetNumberOfDimensions(prhs[0]) != 2  ) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2", 
                "Z must be a 2D matrix.");
    }
    
    // Ensure that I is a column-vector with 2 entries.
    if ( mxGetNumberOfDimensions(prhs[1]) != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2", 
                "I must be a 2 entry column-vector.");
    }
    
    Z               = mxGetPr(prhs[0]);
    I               = mxGetPr(prhs[1]);
    boundaryType    = mxArrayToString(prhs[2]);    
    nY              = (mwSignedIndex) mxGetM(prhs[0]);
    nX              = (mwSignedIndex) mxGetN(prhs[0]);
    
    // If the interval is a fraction, floor the value.
    nKy = (int) I[0];
    nKx = (int) I[1];
    
    // Ensure that the filter kernel is not larger than the image.
    if (nKy>nY || nKx>nX) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2:rhs", 
                "Filter size is larger than input.");
    }    
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    F       = mxGetPr(plhs[0]);
    
    errNo = medianFilter2(F, Z, nX, nY, nKx, nKy, boundaryType);
    
    mxFree(boundaryType);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:medianFilter2:rhs", 
                "Unkown boundary type.");
    }    
}
