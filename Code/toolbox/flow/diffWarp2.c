#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *I1, *I2, *Dx, *Dy, *Ix, *Iy, *It; // I1, I2, Dx, Dy, inputs. Ix, Iy, It outputs.
    /* Sizes */
    mwSignedIndex nY, nX;
    /* Error number/code */
    int errNo;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 4 ) {
        mexErrMsgIdAndTxt("MATLAB:diffWarp2:rhs",
                "This function requires 4 input arguments.");
    }
    if ( nlhs != 3) {
        mexErrMsgIdAndTxt("MATLAB:diffWarp2:lhs",
                "This function requires 3 output argument.");
    }
    
    I1 = mxGetPr(prhs[0]);
    I2 = mxGetPr(prhs[1]);
    Dx = mxGetPr(prhs[2]);
    Dy = mxGetPr(prhs[3]);
    
    nY  = (mwSignedIndex) mxGetM(prhs[0]);
    nX  = (mwSignedIndex) mxGetN(prhs[0]);
    
    // Ensure that all inputs have the same dimensions.
    if ( (mxGetM(prhs[1]) != nY) || (mxGetN(prhs[1]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:warp2", 
                "I1 and I2 must have the same dimensions.");
    }
    if ( (mxGetM(prhs[2]) != nY) || (mxGetN(prhs[2]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:warp2", 
                "I1 and Dx must have the same dimensions.");    
    }
    if ( (mxGetM(prhs[3]) != nY) || (mxGetN(prhs[3]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:warp2", 
                "I1 and Dy must have the same dimensions.");    
    }  
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[2] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    Ix      = mxGetPr(plhs[0]);
    Iy      = mxGetPr(plhs[1]);
    It      = mxGetPr(plhs[2]);
    
    errNo = diffWarp2(Ix,Iy,It, I1,I2,Dx,Dy, nX,nY);
    
    if (errNo != 0) {
        mexErrMsgIdAndTxt("MATLAB:diffWarp2", 
                "I1,I2,Dx,Dy must be at least 3 x 3.");
    }    
}
