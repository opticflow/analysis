#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *X, *Y, *Z, *Xi, *Yi, *F; // F return value.
    /* Sizes */
    mwSignedIndex nY, nX, nYi, nXi;
    /* Error code/number */
    int errNo;

    /* Check for proper number of arguments. */
    if ( nrhs != 5 ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2:rhs",
                "This function requires 5 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2:lhs",
                "This function requires 1 output argument.");
    }
    
    // Ensure that the input data Z is a 2D matrix.
    if (mxGetNumberOfDimensions(prhs[2]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:nearestInterp2:rhs",
                "Input data Z must be a 2D matrix.");
    }
    
    X   = mxGetPr(prhs[0]);
    Y   = mxGetPr(prhs[1]);
    Z   = mxGetPr(prhs[2]);
    Xi  = mxGetPr(prhs[3]);
    Yi  = mxGetPr(prhs[4]);
    nX  = (mwSignedIndex) mxGetM(prhs[0]);
    nY  = (mwSignedIndex) mxGetM(prhs[1]);
    nXi = (mwSignedIndex) mxGetM(prhs[3]);
    nYi = (mwSignedIndex) mxGetM(prhs[4]);
    
    // Ensure that X is a column-vector.
    if ( mxGetN(prhs[0]) != 1 ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "X must be a column-vector.");
    }
    // Ensure that Y is a column-vector.
    if ( mxGetN(prhs[1]) != 1 ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "Y must be a column-vector.");
    }
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nYi, nXi, mxDOUBLE_CLASS, mxREAL);
    F       = mxGetPr(plhs[0]);
    
    // Call the function in the corresponding function in imagelib.c
    errNo = nearestInterp2(F, X, Y, Z, Xi, Yi, nX, nY, nXi, nYi);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:nearestInterp2", "Unkown error.");
    }    
}
