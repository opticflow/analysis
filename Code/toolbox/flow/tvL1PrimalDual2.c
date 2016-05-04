#include <math.h>
#include <string.h>
#include "mex.h"
#include "flowlib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs, temp variable, and output. */
    double *I1, *I2, *DxIn, *DyIn, *DtIn, *PIn, *DxOut, *DyOut, *DtOut, *POut; 
    // I1, I2, Dx, Dy, Dt inputs. Ix, Iy, It outputs.
    double lambda;
    /* Sizes */
    mwSignedIndex nY, nX, nP;
    mwSize nDimP;
    mwSize *dimsP;
    int iDimP, nWarp, nIter, nByte;
    nDimP = 3; // Must be value.
    
    /* Check for proper number of arguments. */
    if ( nrhs != 9 ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2:rhs",
                "This function requires 9 input arguments.");
    }
    if ( nlhs != 4) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2:lhs",
                "This function requires 4 output argument.");
    }
    
    
    I1      = mxGetPr(prhs[0]);
    I2      = mxGetPr(prhs[1]);
    DxIn    = mxGetPr(prhs[2]);
    DyIn    = mxGetPr(prhs[3]);
    DtIn    = mxGetPr(prhs[4]);
    PIn     = mxGetPr(prhs[5]);
    lambda  = (double) mxGetScalar(prhs[6]);
    nWarp   = (int) mxGetScalar(prhs[7]);
    nIter   = (int) mxGetScalar(prhs[8]);
    
    nY  = (mwSignedIndex) mxGetM(prhs[0]);
    nX  = (mwSignedIndex) mxGetN(prhs[0]);
    
    nByte = nY * nX * sizeof(double);
    
    // Ensure that all inputs have the same dimensions.
    if ( (mxGetM(prhs[1]) != nY) || (mxGetN(prhs[1]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "I1 and I2 must have the same dimensions.");
    }
    if ( (mxGetM(prhs[2]) != nY) || (mxGetN(prhs[2]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "I1 and Dx must have the same dimensions.");    
    }
    if ( (mxGetM(prhs[3]) != nY) || (mxGetN(prhs[3]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "I1 and Dy must have the same dimensions.");    
    }
    if ( (mxGetM(prhs[4]) != nY) || (mxGetN(prhs[4]) != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "I1 and Dt must have the same dimensions.");
    }
    if ( mxGetNumberOfDimensions(prhs[5]) != nDimP ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "P must have the 3 dimensions.");
    }
    dimsP = mxCalloc(nDimP, sizeof(mwSize));
    for (iDimP = 0; iDimP < nDimP; ++iDimP) {
        dimsP[iDimP] = mxGetDimensions(prhs[5])[iDimP];
    }
    
    if ( (dimsP[1] != nY) || (dimsP[2] != nX) ) {
        mexErrMsgIdAndTxt("MATLAB:tvL1PrimalDual2", 
                "P must be nP x nY x nX.");
    }    
    
    // Create the return value.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[2] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[3] = mxCreateNumericArray(nDimP, dimsP, mxDOUBLE_CLASS, mxREAL);
    
    DxOut   = mxGetPr(plhs[0]);
    DyOut   = mxGetPr(plhs[1]);
    DtOut   = mxGetPr(plhs[2]);
    POut    = mxGetPr(plhs[3]);
    nP      = dimsP[0];
    
    memcpy(DxOut, DxIn, nByte);
    memcpy(DyOut, DyIn, nByte);
    memcpy(DtOut, DtIn, nByte);
    memcpy(POut, PIn, nP * nByte);

    // Inplace replacement of variables, initialize the variables correct.
    tvL1PrimalDual2(DxOut, DyOut, DtOut, POut, I1, I2, nX, nY, nP, lambda, 
                    nWarp, nIter);
    
    mxFree(dimsP);
}
