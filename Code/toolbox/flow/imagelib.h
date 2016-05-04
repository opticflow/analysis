#ifndef imagelib_h
#define imagelib_h

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

#ifndef EXTERN_C

#ifdef __cplusplus
  #define EXTERN_C extern "C"
#else
  #define EXTERN_C extern
#endif

#endif

        
/** @brief Prints the double values of vector to the console.
 *
 *  Does not check for the proper length when traversing the vector.
 *
 *  @param X Vector values with dimensions: nX.
 *  @param nX The length of the vector.
 *  @return Void.
 */
EXTERN_C void printDoubleVector(
            double* X,  // 1
            int nX      // 2
            );

/** @brief Prints the double values of a matrix to the console.
 *
 *  Does not check for the proper length when traversing the array. The 
 *  values in the matrix are assumed to be stored in row-major order. Thus, 
 *  the linear index is calculated by iLinear = iY + iX*nY.
 *
 *  @param X Matrix values with dimensions: nY x nX.
 *  @param nX Number of columns.
 *  @param nX Number of rows.
 *  @return Void.
 */
EXTERN_C void printDoubleMatrix(
                double* X,  // 1
                int     nX, // 2
                int     nY  // 3
                );

/** @brief Prints the integer values of a matrix to the console.
 *
 *  Does not check for the proper length when traversing the array. The 
 *  values in the matrix are assumed to be store in row-major order.
 * 
 *  @param X Matrix values with dimensions: nY x nX.
 *  @param nX Number of columns.
 *  @param nY Number of rows.
 *  @return Void.
 */
EXTERN_C void printIntegerMatrix(
                int*    X,  // 1
                int     nX, // 2
                int     nY  // 3
                ); 


/** @brief Filters an image Z with the filter kernel K using the boundary 
 *         condition 'boundaryType'.
 *
 *  Indices are not checked by this method. All matrices are assumed to be 
 *  stored in row-major order. This method assumes that memory for the 
 *  output values has been reserved by the caller and also freed by the 
 *  caller. In addition, the size of the output values MATCH the size of 
 *  the input values. To fill in missing values for the filtering operation
 *  at the boundary we use the boundary condition 'boundaryType'.
 *
 *  @param F Returned, filtered values have the dimensions: nY x nX.
 *  @param Z Input values have the dimensions: nY x nX.
 *  @param K Kernel values have the dimensions: nKy x nKx.
 *  @param nX Columns in the input/output data Z/F.
 *  @param nY Rows in the input/output data Z/F.
 *  @param nKx Columns in the kernel K.
 *  @param nKy Rows in the kernel K.
 *  @param boundaryType is char* array with the supported types:
 *         - circular Circular wrapping of values in both dimensions.
 *         - replicate Replicates boundary values in both dimensions.
 *         - same Fill boundary with zeros in both dimensions.
 *  @return Integer 0 if there was no error, -1 if there was an error.
 */
EXTERN_C int imfilter2(
        double* F,              // 1
        double* Z,              // 2
        double* K,              // 3
        int     nX,             // 4
        int     nY,             // 5
        int     nKx,            // 6
        int     nKy,            // 7
        char*   boundaryType    // 8
        );

/** @brief Permutes the dimension of the multi-dimensional array by 
 *         changing the underlaying memory layout.
 *
 *  There is no indexing checking provided by this method. We assume that 
 *  the index (dim[0] x dim[1] ... x dim[nDim-1])-1 is the last index in Z.
 *  Also, we assume that newOrder values 0...nDim-1 that serve as indices 
 *  into dim.
 *  For instance, we can call the method
 *      int *dim = {3, 4, 2};
 *      int nDim = 3;
 *      int nData(1), iDim, iData;
 *      for (iDim = 0; iDim < nDim; ++iDim) nData *= dim[iDim];
 *      double *Z = (double*) malloc(nData * sizeof(double));
 *      for (iData = 0; iData < nData; ++iData) Z[iData] = iData;
 *      int *newDim = {1, 2, 0};
 *      permuteN(Z, dim, newOrder, nDim);
 *      for (iData = 0; iData < nData; ++iData) printf("%2.2f, ", Z[iData]);
 *
 *  @param Z Input/output value with dimensions: dim[0] x dim[1] x ...
 *  @param dim Dimensions of the array with dimensions: nDim.
 *  @param newOrder Is the index into dim to define the new dimensions. It 
 *                  has itself the dimensions: nDim.
 *  @param nDim Number of dimensions.
 *  @return Void.
 */
EXTERN_C void permuteN(
        double* Z,          // 1
        int*    dim,        // 2
        int*    newOrder,   // 3
        int     nDim        // 4
        );

/** @brief Selects the K-th largest element out of n elements in an array.
 *
 *  There is no index checking done by this method. If k>n-1 the last 
 *  element is returned.
 *  This algorithm is from Numerical recipies, Chapter 8. Sorting, p. 342.
 *  The algorithm works in place. The algorithm only does a partial sort 
 *  within an interval pushing all smaller elements to the left and all 
 *  larger elements to the right.
 *
 *  @param Z Values in an array of dimensions: n.
 *  @param n Number of values.
 *  @param k k-th largest element in Z.
 *  @return The k-th largest element in Z.
 */
EXTERN_C double selectKth(
                    double* Z,        // 1
                    unsigned long n,  // 2
                    unsigned long k   // 3
                    ); 

/** @brief Computation of the median for the values in an array.
 *  
 *  There is no index checking done by this method. 
 *  If the array is of odd size this method selects n/2 largest element and 
 *  returns that one.
 *  If the array is of even size this method selects the n/2 and (n-1)/2 
 *  largest elements and returns the average of these two.
 * 
 *  @param Z The data array with dimensions: n.
 *  @param n The number of elements in Z.
 *  @return A double value that is the median value.
 */
EXTERN_C double median(
            double* Z,      // 1
            unsigned long n // 2
            );

/** @brief Computes the mean values of values in the array Z.
 *
 *  There is no index checking done by this method.
 *  Computes the mean = sum(Z)/n.
 *  
 *  @param Z The data array with dimensions: n.
 *  @param n The number of elements in Z.
 *  @return The mean value.
 */
EXTERN_C double mean(
                double*         Z,  // 1
                unsigned long   n   // 2
                );

/** @brief Computes the mean of the absolute value of all values in the 
 *         array Z.
 *
 *  @param Z The data array with dimensions: n.
 *  @param n The number of elements in Z.
 *  @return The mean absolute value.
 */
EXTERN_C double meanAbs(
                    double*         Z,  // 1
                    unsigned long   n   // 2
                    );

/** @brief Median filtering of a 2D image.
 *
 *  No checking of indices is performed. This method assumes that F and Z 
 *  have the size nY x nX and have been allocated outside this method. 
 *  Furthermore, the method assumses that nKy <= nY and nKx <= nX. The
 *  returned matrix F has the same size as the input data Z. Specific 
 *  boundary conditions are applied to ensure the output is equal to the 
 *  input size.
 *
 *  @param F Returned, median filtered data with dimensions: nY x nX.
 *  @param Z Input data with dimensions: nY x nX.
 *  @param nX Number of columns for the input/output data.
 *  @param nY Number of rows for the input/output data.
 *  @param nKx Number of columns for kernel.
 *  @param nKy Number of rows for kernel.
 *  @param boundaryType is char* array with the supported types:
 *         - symmetric Symmetric mirroring of values in both dimensions.
 *         - circular Circular wrapping of values in both dimensions.
 *         - replicate Replicates boundary values in both dimensions.
 *         - same Fill boundary with zeros in both dimensions.
 *  @return Integer 0 if there was no error, -1 if there was an error.
 */
EXTERN_C int medianFilter2(double *F,           // 1 nY x nX
                           double *Z,           // 2 nY x nX
                           int nX,              // 3 Length nX
                           int nY,              // 4 Length nY
                           int nKx,             // 5 Kernel x 
                           int nKy,             // 6 Kernel y
                           char* boundaryType); // 7

/** @brief Uses a median filter with a threshold to filter the input.
 *
 *  Does not check for the proper length when traversing the array.
 *  Assumes row-major order for the values. The exact function is:
 *  SmoothValue = medianFilter(Z,nX,nY);
 *  meanValue = mean(SmoothValue);
 *  Z[i] := if (abs(Z[i]-SmoothValue[i]) > meanValue) then SmoothValue[i]
 *          else Z[i]
 *
 *  @param Z Matrix with input values and output values (inplace).
 *  @param nX Number of columns.
 *  @param nY Number of rows.
 *  @return If 0 no error occured, if -1 an error occured.
 */
EXTERN_C int peakFilter2(
                double* Z,  // 1
                int     nX, // 2
                int     nY  // 3
                );

/** @brief Resize the 2D input image using the specified interpolation.
 *
 *  Does not check for proper length when traversing array.
 *  Assumes row-major order for values. Assumes that the caller reserved 
 *  the memory for the returned value of size nYi x nXi. The cubic 
 *  interpolation requires at least an 3 x 3 input matrix Z.
 *
 *  @param F Returned, interpolated matrix with dimensions: nYi x nXi.
 *  @param Z Input matrix with dimensions: nY x nX.
 *  @param nX Number of columns for input.
 *  @param nY Number of rows for input.
 *  @param nXi Number of columns for output.
 *  @param nYi Number of rows for output.
 *  @param interpType is char* array with the supported types:
 *         - nearest Nearest neighborhood interpolation.
 *         - cubic Cubic interpolation.
 *  @return If 0 no error occured, if -1 an error occured.
 */
EXTERN_C int imresize2(double   *F,             // 1
                       double   *Z,             // 2
                       int      nX,             // 3
                       int      nY,             // 4
                       int      nXi,            // 5
                       int      nYi,            // 6
                       char*    interpType);    // 7


/** @brief Resize the 2D input image through nearest interpolation.
 *
 *  Does not check for proper length when traversing arrays.
 *  Assumes row-major order for values. Assumes that the caller reserved 
 *  the memory for the returned value of size nYi x nXi. 
 *  Uses nearest neighborhood interpolation in the horizontal and vertical 
 *  dimension to define the values for the output.
 * 
 *  @param Returned, interpolated matrix with dimensions: nYi x nXi.
 *  @param X Horizontal input interval with dimensions: nX x 1.
 *  @param Y Vertical input interval with dimensions: nY x 1.
 *  @param Z Input matrix with dimensions: nY x nX.
 *  @param Xi Horizontal output interval with dimensions: nXi x 1.
 *  @param Yi Vertical output interval with dimensions: nYi x 1.
 *  @param nX Number of columns for input.
 *  @param nY Number of rows for input.
 *  @param nXi Number of columns for output.
 *  @param nYi Number of rows for output.
 *  @return If 0 no error occured, if -1 an error occured.
 */
EXTERN_C int nearestInterp2(double  *F,     // 1
                            double  *X,     // 2
                            double  *Y,     // 3
                            double  *Z,     // 4
                            double  *Xi,    // 5
                            double  *Yi,    // 6
                            int     nX,     // 7
                            int     nY,     // 8
                            int     nXi,    // 9
                            int     nYi);   // 10

/** @brief Resizes the 2D input image through cubic interpolation.
 *  
 *  Does not check for proper length when traversing arrays.
 *  Assumes row-major order for values. Assumes that the caller reserved 
 *  the memory for the returned value of size nYi x nXi. 
 *  Uses cubic interpolation to define the output values.
 *
 *  @param Returned, interpolated matrix with dimensions: nYi x nXi.
 *  @param X Horizontal input interval with dimensions: nX x 1.
 *  @param Y Vertical input interval with dimensions: nY x 1.
 *  @param Z Input matrix with dimensions: nY x nX.
 *  @param Xi Horizontal output interval with dimensions: nXi x 1.
 *  @param Yi Vertical output interval with dimensions: nYi x 1.
 *  @param nX Number of columns for input.
 *  @param nY Number of rows for input.
 *  @param nXi Number of columns for output.
 *  @param nYi Number of rows for output.
 *  @return If 0 no error occured, if -1 an error occured.
 */
EXTERN_C int cubicInterp2(double    *F,     // 1
                          double    *X,     // 2
                          double    *Y,     // 3
                          double    *Z,     // 4
                          double    *Xi,    // 5
                          double    *Yi,    // 6
                          int       nX,     // 7
                          int       nY,     // 8
                          int       nXi,    // 9
                          int       nYi);   // 10

/** @brief Warps image I2 toward I1 and computes the partial derivatives 
 *         in x, y, and t.
 *
 *  Does not check the proper length of any of the matrices. Be warned!
 *  All matrices are assumed to be flattened in row-major order.
 *  For all return values, this method assumes that the appropriate memory 
 *  for these matrices has reserved before calling this function. Likewise
 *  the memory has to be freed outside this method.
 *  
 *  @param Ix Return value for the partial derivative in x: dI/dx. The 
 *         dimensions are: nY x nX.
 *  @param Iy Return value for the partial derivative in y: dI/dy. The
 *         dimensions are: nY x nX.
 *  @param It Return value for the partial derivative in t: dI/dt. The
 *         dimensions are: nY x nX.
 *  @param I1 First input image with the dimensions: nY x nX.
 *  @param I2 Second input image with the dimensions: nY x nX.
 *  @param Dx Differential in horizontal dimension to warp. The dimensions
 *         are: nY x nX.
 *  @param Dy Differential in vertical dimensions to warp. The dimensions
 *         are: nY x nX.
 *  @param nX Number of columns.
 *  @param nY Number of rows.
 *  @return If 0 then there was no error, if -1 there was an error.
 */
EXTERN_C int diffWarp2(
        double* Ix, // 1
        double* Iy, // 2
        double* It, // 3
        double* I1, // 4
        double* I2, // 5
        double* Dx, // 6
        double* Dy, // 7
        int     nX, // 8 
        int     nY  // 9
        );

#endif