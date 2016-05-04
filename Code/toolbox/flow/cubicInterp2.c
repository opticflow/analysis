#include <math.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *X, *Y, *Z, *Xi, *Yi, *F; // F return value
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
    
    // Check X and Y.
    if (mxGetNumberOfDimensions(prhs[0]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "X must be a 2D matrix.");
    }
    if ( (mxGetM(prhs[0]) != mxGetM(prhs[1])) 
      || (mxGetN(prhs[0]) != mxGetN(prhs[1])) ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "X and Y must have the same dimensions.");
    }
    
    // Check Xi and Yi.
    if (mxGetNumberOfDimensions(prhs[3]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "Xi must be a 2D matrix.");
    }
    if ( (mxGetM(prhs[3]) != mxGetM(prhs[4])) 
      || (mxGetN(prhs[3]) != mxGetN(prhs[4])) ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "Xi and Yi must have the same dimensions.");
    }
    
    X   = mxGetPr(prhs[0]);
    Y   = mxGetPr(prhs[1]);
    Z   = mxGetPr(prhs[2]);
    Xi  = mxGetPr(prhs[3]);
    Yi  = mxGetPr(prhs[4]);
    
    nX  = (mwSignedIndex) mxGetN(prhs[2]);
    nY  = (mwSignedIndex) mxGetM(prhs[2]);
    nXi = (mwSignedIndex) mxGetN(prhs[3]);
    nYi = (mwSignedIndex) mxGetM(prhs[3]);
        
    // Check Z.
    if ( mxGetM(prhs[2]) != nY && mxGetN(prhs[2]) != nX) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "Z must match the dimensions of X and Y.");
    }
    
    /*
    // Z must be real.
    if ( mxIsComplex(prhs[2]) != mxREAL ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", "Z must be real.");
    }
    
    // Z mut be double.
    if ( mxGetClassID(prhs[2]) != mxDOUBLE_CLASS ) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", "Z must be double.");
    }
     */
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nYi, nXi, mxDOUBLE_CLASS, mxREAL);
    F       = mxGetPr(plhs[0]);
    
    errNo = cubicInterp2(F, X, Y, Z, Xi, Yi, nX, nY, nXi, nYi);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:cubicInterp2", 
                "Size of input data Z must be at least 3 x 3.");
    }
}