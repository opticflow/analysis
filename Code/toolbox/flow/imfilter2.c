#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *Z, *K, *F; // Z input values, K kernel values, F return values.
    /* Sizes */
    mwSignedIndex nY, nX, nKy, nKx;
    /* Type for interpolation. */
    char *boundaryType;
    /* Error number/code */
    int errNo;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 3 ) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2:rhs",
                "This function requires 3 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2:lhs",
                "This function requires 1 output argument.");
    }
    
    // Ensure that Z is a 2D matrix.
    if ( mxGetNumberOfDimensions(prhs[0]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2:rhs",
                "Input data must have 2 dimensions.");
    }
    
    // Ensure that the kernel K is a 2D matrix.
    if ( mxGetNumberOfDimensions(prhs[1]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2:rhs",
                "Kernel must have 2 dimensions.");
    }   
    
    Z               = mxGetPr(prhs[0]); // Get handle to input data.
    K               = mxGetPr(prhs[1]); // Get handle to kernel data.
    boundaryType    = mxArrayToString(prhs[2]);    
    nY              = (mwSignedIndex) mxGetM(prhs[0]);
    nX              = (mwSignedIndex) mxGetN(prhs[0]);
    nKy             = (mwSignedIndex) mxGetM(prhs[1]);
    nKx             = (mwSignedIndex) mxGetN(prhs[1]);
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    F       = mxGetPr(plhs[0]);
    
    errNo = imfilter2(F, Z, K, nX, nY, nKx, nKy, boundaryType);
    
    mxFree(boundaryType);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:imfilter2", "Unkown boundary type.");
    }    
}
