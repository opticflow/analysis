#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *Z, *I, *F; // F return value, I y,x
    /* Sizes */
    mwSignedIndex nY, nX, nYi, nXi;
    /* Type for interpolation. */
    char *interpType;
    /* Error number/code */
    int errNo;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 3 ) {
        mexErrMsgIdAndTxt("MATLAB:imresize:rhs",
                "This function requires 5 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:imresize:lhs",
                "This function requires 1 output argument.");
    }
    
    // Ensure that Z is a 2D matrix.
    if ( mxGetNumberOfDimensions(prhs[0]) != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:imresize2:rhs", 
                "Z must be a 2D matrix.");
    }
    
    // Ensure that I is a column-vector, hence has 2 dimensions.
    if ( mxGetNumberOfDimensions(prhs[1]) != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:imresize", 
                "I must be a 2 entry column-vector.");
    }
    
    Z           = mxGetPr(prhs[0]);
    I           = mxGetPr(prhs[1]);
    interpType  = mxArrayToString(prhs[2]);
    nY          = (mwSignedIndex) mxGetM(prhs[0]);
    nX          = (mwSignedIndex) mxGetN(prhs[0]);
    nYi         = (int) I[0];
    nXi         = (int) I[1];
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nYi, nXi, mxDOUBLE_CLASS, mxREAL);
    F       = mxGetPr(plhs[0]);    
    
    errNo = imresize2(F, Z, nX, nY, nXi, nYi, interpType);
    
    mxFree(interpType);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:imresize:rhs", 
                "Unkown interpolation type or input size too small.");    
    }    
}
