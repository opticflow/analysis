#include <math.h>
#include <string.h>
#include "mex.h"
#include "flowlib.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Matrices for inputs, temp variable, and output. */
    double *Img1, *Img2, *Dx, *Dy; // Dx, Dy return values and Img1 and Img2
    /* Sizes */
    mwSignedIndex nY, nX;
    /* Arguments */
    int nLevel, nWarp, nIter, nDuals, errNo, nFields, iFields;
    /* Parameters */
    double sFactor, lambda;
    /* More sizes */
    mwSize nElems;
    mxArray *field;
    const char *fieldName;
    /* Set default values for all parameters. */
    nLevel  = 1000;
    sFactor = 0.9;
    nWarp   = 1;
    nIter   = 50;
    lambda  = 50.0;
    nDuals  = 6;

    /* Check for proper number of arguments. */
    if ( nrhs != 3 ) {
        mexErrMsgIdAndTxt("MATLAB:estimateFlow:rhs",
                "This function requires 3 input arguments.");
    }
    if ( nlhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:imresize:lhs",
                "This function requires 2 output argument.");
    }
    
    Img1 = mxGetPr(prhs[0]);
    Img2 = mxGetPr(prhs[1]);
    
    nY  = (mwSignedIndex) mxGetM(prhs[0]);
    nX  = (mwSignedIndex) mxGetN(prhs[0]);
    
    // Ensure that both Img1 and Img2 are 2D.
    if ( mxGetNumberOfDimensions(prhs[0]) != 2 ||
         mxGetNumberOfDimensions(prhs[1]) != 2) {
        mexErrMsgIdAndTxt("MATLAB:estimateFlow2", 
                "Img1/2 must be 2D matrices!");
    }
    // Ensure that Img1 and Img2 have the same dimensions.
    if ( nY != (mwSignedIndex) mxGetM(prhs[1]) ||
         nX != (mwSignedIndex) mxGetN(prhs[0]) ) {
        mexErrMsgIdAndTxt("MATLAB:estimateFlow2", 
                "Img1/2 must have the same size.");
    }
    // Ensure that the 3rd input is a structure.
    if (!mxIsStruct(prhs[2])) {
        mexErrMsgIdAndTxt("MATLAB:estimateFlow2", 
                "Third input must be a structure.");
    }
    nFields = mxGetNumberOfFields(prhs[2]);
    nElems = (mwSize) mxGetNumberOfElements(prhs[2]);    
    
    // Assume that there is only one element for each field.
    if (nElems != 1) {
        mexErrMsgIdAndTxt("MATLAB:estimateFlow2", 
                "Passed in multiple values for a field.");
    }
    // Ensure that fields are present and have the correct type.
    for (iFields = 0; iFields < nFields; ++iFields) {
        
        field = mxGetFieldByNumber(prhs[2], 0, iFields);
                
	    if (field == NULL) {            
            mexPrintf("%s%d\t%s%d\n", "Field number ", iFields+1, " and structure index ", 1);
            mexErrMsgIdAndTxt("MATLAB:estimateFlow", "Field is empty!");
	    }
        
        if( !mxIsChar(field) && !mxIsNumeric(field) ) {
            mexPrintf("%s%d\t%s%d\n", "Field number ", iFields+1, " and structure index ", 1);
            mexErrMsgIdAndTxt("MATLAB:estimateFlow", "Field must be either a string or a numeric value!");
        }
        
    }   
    
    // Pull the field values.
    for (iFields = 0; iFields < nFields; ++iFields) {
        
        fieldName   = mxGetFieldNameByNumber(prhs[2], iFields);
        
        field       = mxGetFieldByNumber(prhs[2], 0, iFields);
        
        //mexPrintf("Found field %s.\n", fieldName);
        if (strcmp("nLevel", fieldName) == 0) {
            nLevel = (int) mxGetScalar(field);
        } else if (strcmp("sFactor", fieldName) == 0) {
            sFactor = (double) mxGetScalar(field);
        } else if (strcmp("nWarp", fieldName) == 0) {
            nWarp = (int) mxGetScalar(field);
        } else if (strcmp("nIter", fieldName) == 0) {
            nIter = (int) mxGetScalar(field);
        } else if (strcmp("lambda", fieldName) == 0) {
            lambda = (double) mxGetScalar(field);
        } else {
            mexPrintf("Warning: Unknown field name %s.\n", fieldName);
        }
 
    }
    
    //mexPrintf("Info: Running estimateFlow with the parameters.\n");
    //mexPrintf("nY = %d, nX = %d, nLevel = %d, sFactor = %2.2f, nWarp = %d, nIter = %d, lambda = %2.2f.\n",
    //        nY, nX, nLevel, sFactor, nWarp, nIter, lambda);
    
    // Create space for the return values Dx, Dy.
    plhs[0] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix(nY, nX, mxDOUBLE_CLASS, mxREAL);
    Dx      = mxGetPr(plhs[0]);
    Dy      = mxGetPr(plhs[1]);
    
    //                    1   2   3     4     5   6   7       8        9      10     11
    errNo = estimateFlow2(Dx, Dy, Img1, Img2, nX, nY, nLevel, sFactor, nWarp, nIter, lambda);
        
    if (errNo != 0) {
        mexPrintf("The error code is %d\n", errNo);
        mexErrMsgIdAndTxt("MATLAB:estimateFlow2", "Too small input size of the imags.");
    }
}
