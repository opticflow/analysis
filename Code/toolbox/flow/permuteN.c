#include <math.h>
#include <string.h>
#include "mex.h"
#include "imagelib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs and output. */
    double *Z, *F, *P; // F return value, Z input value, P permutation.
    int *newOrder, *dim, *newDim;
    int nDim, nElem, iDim;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 2 ) {
        mexErrMsgIdAndTxt("MATLAB:permuteN:rhs",
                "This function requires 2 input arguments.");
    }
    if ( nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:permuteN:lhs",
                "This function requires 1 output argument.");
    }
    
    nDim        = mxGetNumberOfDimensions(prhs[0]);
    Z           = mxGetPr(prhs[0]);
    P           = mxGetPr(prhs[1]); // permutation
    dim         = mxCalloc(nDim, sizeof(int));
    newOrder    = mxCalloc(nDim, sizeof(int));
    newDim      = mxCalloc(nDim, sizeof(int));
    nElem       = 1;   
    
    for (iDim = 0; iDim < nDim; ++iDim) {
        dim[iDim]       = (int)mxGetDimensions(prhs[0])[iDim];
        nElem           *= dim[iDim];
        newOrder[iDim]  = ((int)P[iDim]) - 1;
        newDim[iDim]    = (int)mxGetDimensions(prhs[0])[newOrder[iDim]];
    }
    
    permuteN(Z, dim, newOrder, nDim);
    
    plhs[0] = mxCreateNumericArray(nDim, newDim, mxGetClassID(prhs[0]), 
                                   mxIsComplex(prhs[0]) ? mxCOMPLEX : mxREAL);
    F       = mxGetPr(plhs[0]);
    memcpy(F, Z, nElem*sizeof(double));
    
    mxFree(newDim);
    mxFree(newOrder);
    mxFree(dim);
}
