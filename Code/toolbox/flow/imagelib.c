#include "imagelib.h"
#include "mex.h"
#include <math.h>

/* Define the round function because math.h does not define one. */
double round(double number)
{
    return (number >= 0) ? (int)(number + 0.5) : (int)(number - 0.5);
}

/* Print values of a double vector. */
void printDoubleVector(double* X, int nX) {
    int iX;
    for (iX = 0; iX < nX; ++iX) {
        printf("%5.4f, ", X[iX]);
    }
    printf("\n");
}

/* Print the values of double matrix for debugging purpopses. */
void printDoubleMatrix(double* X, int nX, int nY) {
    int iX, iY;
    for (iY = 0; iY < nY; ++iY) {
        for (iX = 0; iX < nX; ++iX) {
            printf("%e, ", X[iY + iX*nY]);
        }
        printf("\n");
    }
}

/* Print the values of an integer matrix for debugging purposes. */
void printIntegerMatrix(int* X, int nX, int nY) {
    int iX, iY;
    for (iY = 0; iY < nY; ++iY) {
        for (iX = 0; iX < nX; ++iX) {
            printf("%d, ", X[iY + iX*nY]);
        }
        printf("\n");
    }
}

/* Imfilter function. */
int imfilter2(double* F,            // 1 Output. Dimensions: nY x nX.
              double* Z,            // 2 Input. Dimensions: nY x nX.
              double* K,            // 3 Kernel. Dimensions: nKy x nKx.
              int nX,               // 4 Columns of input/output.
              int nY,               // 5 Rows of input/output.
              int nKx,              // 6 Columns of kernel.
              int nKy,              // 7 Rows of kernel.
              char* boundaryType) { // 8 Boundary type.
    
    // For now, use a circular boundary condition.
    int iY, iX, iKy, iKx, iiY, iiX;
    int nHy, nHx;
    int nWy, nWx;
    double sum;
    nHy = (nKy-1)/2;
    nHx = (nKx-1)/2;
    
    // ********************************************************************
    // CIRCULAR
    // ********************************************************************
    if (strcmp("circular", boundaryType)==0) {
        nWy = nHy*nY;
        nWx = nHx*nX;
        for (iY = 0; iY < nY; ++iY) {
            for (iX = 0; iX < nX; ++iX) {
                sum = 0.0;
                for (iKy = 0; iKy < nKy; ++iKy) {
                    for (iKx = 0; iKx < nKx; ++iKx) {
                        //iiY = (iY + iKy - nHy + nHy*nY) % nY;
                        //iiX = (iX + iKx - nHx + nHx*nX) % nX;
                        iiY = (iY + iKy - nHy + nWy) % nY;
                        iiX = (iX + iKx - nHx + nWx) % nX;
                        sum += Z[iiY + iiX*nY]*K[iKy + iKx*nKy];
                    }
                }
                F[iY + iX*nY] = sum;
            }
        }
        
    // ********************************************************************
    // REPLICATE
    // ********************************************************************
    } else if (strcmp("replicate", boundaryType)==0) {
        for (iY = 0; iY < nY; ++iY) {
            for (iX = 0; iX < nX; ++iX) {
                sum = 0.0;
                for (iKy = 0; iKy < nKy; ++iKy) {
                    for (iKx = 0; iKx < nKx; ++iKx) {
                        iiY = iY + iKy - nHy;
                        iiX = iX + iKx - nHx;
                        if (iiY < 0) {
                            iiY = 0;
                        }
                        if (iiY > (nY-1)) {
                            iiY = nY-1;
                        }
                        if (iiX < 0) {
                            iiX = 0;
                        }
                        if (iiX > (nX-1)) {
                            iiX = nX-1;
                        }
                        sum += Z[iiY + iiX*nY]*K[iKy + iKx*nKy];
                    }
                }
                F[iY + iX*nY] = sum;
            }
        }
        
    // ********************************************************************
    // ZERO BOUNDARY CONDITION IS DEFAULT
    // ********************************************************************
    } else if (strcmp("same", boundaryType)==0) {
        for (iY = 0; iY < nY; ++iY) {
            for (iX = 0; iX < nX; ++iX) {
                sum = 0.0;
                for (iKy = 0; iKy < nKy; ++iKy) {
                    for (iKx = 0; iKx < nKx; ++iKx) {
                        iiY = iY + iKy - nHy;
                        iiX = iX + iKx - nHx;                        
                        if ((0 <= iiY) && (iiY < nY) 
                         && (0 <= iiX) && (iiX < nX)) {
                            sum += Z[iiY + iiX*nY]*K[iKy + iKx*nKy];
                        }
                    }
                }
                F[iY + iX*nY] = sum;
            }
        }
    } else {
        return -1;
    }
    return 0;
}


/* Converts sub-index into a linear index. */
int sub2linear(int* index, int* dim, int nDim) {
    int iDim;
    int linearIndex = index[nDim-1];
    for (iDim = nDim-2; iDim >= 0; --iDim) {
        linearIndex *= dim[iDim];
        linearIndex += index[iDim];
    }
    return linearIndex;
}

/* Converts sub-index into a linear index. */
void linear2sub(int* index, int linearIndex, int* dim, int nDim) {
    int iDim;
    index[0] = linearIndex % dim[0];
    for (iDim = 1; iDim < nDim; ++iDim) {
        linearIndex = (linearIndex - index[iDim-1])/dim[iDim-1];
        index[iDim] = linearIndex % dim[iDim];
    }
}

/* Converts a linear index into a sub-index taking the new order for 
 * dimensions into account. */
void linear2newSub(int* index, int linearIndex, int* dim, int* newOrder, int nDim) {
    int iDim, lastSubIndex;
    lastSubIndex = linearIndex % dim[0];    
    index[newOrder[0]] = lastSubIndex;
    for (iDim = 1; iDim < nDim; ++iDim) {
        linearIndex = (linearIndex - lastSubIndex)/dim[iDim-1];
        lastSubIndex = linearIndex % dim[iDim];
        index[newOrder[iDim]] = lastSubIndex;
    } 
}

/* Permutes the dimensions of the matrix Z and changes the underlaying 
 * memory layout of the matrix. */
void permuteN(double* Z, int* dim, int* newOrder, int nDim) {
    int nElem, iDim, jDim, iElem, iTmp;
    double *ZTmp;
    int *newDim, *subIndex, *invOrder;
    newDim = (int*) malloc(nDim * sizeof(int));
    invOrder = (int*) malloc(nDim * sizeof(int));
    subIndex = (int*) malloc(nDim * sizeof(int));
    nElem = 1;
    for (iDim = 0; iDim < nDim; ++iDim) {
        nElem *= dim[iDim];
        newDim[iDim] = dim[newOrder[iDim]];
        for (jDim = 0; jDim < nDim; ++jDim) {
            if (newOrder[jDim]==iDim) {
                invOrder[iDim] = jDim;
                break;
            }
        }
    }    
    ZTmp = (double*) malloc(nElem * sizeof(double));
    for (iElem = 0; iElem < nElem; ++iElem) {
        linear2newSub(subIndex, iElem, dim, invOrder, nDim);
        iTmp = sub2linear(subIndex, newDim, nDim);
        /*
        if (iTmp > nElem || iTmp < 0) {
            printf("Index %d is <%d or >%d.\n", iTmp, 0, nElem);
            break;
        }*/        
        ZTmp[iTmp] = Z[iElem];
    }
    memcpy(Z, ZTmp, nElem * sizeof(double));
    
    free(ZTmp);
    free(subIndex);
    free(invOrder);
    free(newDim);
}


/* Is used by the function that finds the k-th smallest element. */
void swap(double* V, unsigned long i, unsigned long j) {
    double temp;
    temp = V[i];
    V[i] = V[j];
    V[j] = temp;
}

/* Finds the k-th smallest element. */
double selectKth(double* Z, unsigned long n, unsigned long k) {
    unsigned long i, ir, j, l, mid, kp; // kp = k plus 1.
    double a;
    kp = k + 1;
    l = 1;
    ir = n;
    for (;;) {
        //printf("Z = \n\n");
        //printDoubleVector(Z, n);
                
        // if (ir <= l+1) {
        if (ir <= l+1) { //Active partition contains 1 or 2elements.
            // if (ir == l+1 && arr[ir] < arr[l]) {
            if (ir == l+1 && Z[ir-1] < Z[l-1]) { //Case of 2elements.
                // SWAP(arr[l],arr[ir])
                swap(Z, l-1, ir-1);
            }
            // return arr[k];
            return Z[k];
        } else {
            // Choose median of left, center, and right elements as 
            // partitioning element a. Also rearrange so that 
            // arr[l] ? arr[l+1], arr[ir] ? arr[l+1].
            // mid=(l+ir) >> 1;
            mid = (l+ir) >> 1;
            // SWAP(arr[mid],arr[l+1])
            swap(Z, mid-1, l);
            // if (arr[l] > arr[ir]) {
            if (Z[l-1] > Z[ir-1]) {
                // SWAP(arr[l],arr[ir])
                swap(Z, l-1, ir-1);
            }
            // if (arr[l+1] > arr[ir]) {
            if (Z[l] > Z[ir-1]) {
                // SWAP(arr[l+1],arr[ir])
                swap(Z, l, ir-1);
            }
            // if (arr[l] > arr[l+1]) {
            if (Z[l-1] > Z[l]) {
                // SWAP(arr[l],arr[l+1])
                swap(Z, l-1, l);
            }
            // i=l+1;
            i = l + 1; // Initialize pointers for partitioning.
            // j=ir;
            j = ir;
            // a=arr[l+1];
            a = Z[l]; // Partitioning element.
            for (;;) { //Beginning of innermost loop.
                // do i++; while (arr[i] < a);
                do i++; while (Z[i-1] < a); //Scan up to find element > a.
                // do j--; while (arr[j] > a);
                do j--; while (Z[j-1] > a); //Scan down to find element < a.
                // if (j < i) break;                
                if (j < i) break; //Pointers crossed. Partitioning complete.
                // SWAP(arr[i],arr[j])
                swap(Z, i-1, j-1);
            } //End of innermost loop.
            // arr[l+1]=arr[j];
            Z[l] = Z[j-1]; // Insert partitioning element.
            // arr[j]=a;
            Z[j-1] = a;
            // if (j >= k) ir=j-1;
            if (j >= kp) ir = j - 1; // Keep active the partition that contains the
            // if (j <= k) l=i;
            if (j <= kp) l = i; //kth element.
        }
    }
}

/* Uses selectKth to compute the median of the values in Z. */
double median(double* Z, unsigned long n) {
    double f;
    unsigned long k;
    k = n/2;
    f = selectKth(Z, n, k);
    if ( (n % 2) == 0) {
        f = 0.5*(f + selectKth(Z, n, k-1));
    }
    return f;
}

/* Computes the mean values of the values in Z. */
double mean(double* Z, unsigned long n) {
    double m;
    unsigned long i;
    m = 0.0;
    for (i = 0; i < n; ++i) { m += Z[i]; }
    m /= n;
    return m;
}

/* Computes the mean of the absolute values in Z. */
double meanAbs(double* Z, unsigned long n) {
    double m;
    unsigned long i;
    m = 0.0;
    for (i = 0; i < n; ++i) { m += fabs(Z[i]); }
    m /= n;
    return m;
}

/* Computes the meadian filtering */
int medianFilter2(double    *F,             // 1 Return values: nY x nX.
                  double    *Z,             // 2 Input values: nY x nX.
                  int       nX,             // 3 Number of columns in/out.
                  int       nY,             // 4 Number of rows in/out.
                  int       nKx,            // 5 Number of columns kernel.
                  int       nKy,            // 6 Number of rows kernel.
                  char*     boundaryType) { // 7 Type of boundary.                  
    int iY, iX, iKy, iKx, iiY, iiX, nHy, nHx, iExit;
    double *T; // Temporary values from the neighborhood nKx x nKy.
    nHy = (nKy-1)/2;
    nHx = (nKx-1)/2;
    T = (double*) malloc(sizeof(double) * nKx * nKy);
    iExit = 0;
    
    // ********************************************************************
    // SYMMETRIC
    // ********************************************************************
    if (strcmp("symmetric", boundaryType)==0) { 
        for (iX = 0; iX < nX; ++iX) {
            for (iY = 0; iY < nY; ++iY) {
                for (iKx = 0; iKx < nKx; ++iKx) {
                    for (iKy = 0; iKy < nKy; ++iKy) {
                        /*
                    iiY = iY + (iKy-1) - nHy;
                    iiX = iX + (iKx-1) - nHx;
                    if iiY<1,
                        iiY = -iiY + 1;
                    end
                    if iiY>nY,
                        iiY = nY - (iiY - nY) + 1;
                    end
                    if iiX<1,
                        iiX = -iiX + 1;
                    end
                    if iiX>nX,
                        iiX = nX - (iiX - nX) + 1;
                    end
                    V(iKy,iKx) = Z(iiY,iiX);
                    */
                        iiY = iY + iKy - nHy;
                        iiX = iX + iKx - nHx;
                        if (iiY < 0) {
                            iiY = -iiY - 1;
                        }
                        if (iiY > (nY-1)) {
                            iiY = nY - (iiY - nY) - 1;
                        }
                        if (iiX < 0) {
                            iiX = -iiX - 1;
                        }
                        if (iiX > (nX-1)) {
                            iiX = nX - (iiX - nX) - 1;
                        }
                        T[iKy + iKx*nKy] = Z[iiY + iiX*nY];
                    }
                }
                //printf("\nRow %d and column %d:\n", iY, iX);
                //printDoubleMatrix(T, nKx, nKy);
                //F[iY + iX*nY] = selectKth(T, nKx*nKy, (nKx*nKy)/2);
                F[iY + iX*nY] = median(T, nKx*nKy);
            }
        }
        
    // ********************************************************************
    // CIRCULAR
    // ********************************************************************
    } else if (strcmp("circular", boundaryType)==0) {
        for (iX = 0; iX < nX; ++iX) {
            for (iY = 0; iY < nY; ++iY) {
                for (iKx = 0; iKx < nKx; ++iKx) {
                    for (iKy = 0; iKy < nKy; ++iKy) {
                        iiY = (iY + iKy - nHy + nY) % nY;
                        iiX = (iX + iKx - nHx + nX) % nX;
                        T[iKy + iKx*nKy] = Z[iiY + iiX*nY];
                    }
                }
                //F[iY + iX*nY] = selectKth(T, nKx*nKy, (nKx*nKy)/2);
                F[iY + iX*nY] = median(T, nKx*nKy);
            }
        }
        
    // ********************************************************************
    // REPLICATE
    // ********************************************************************
    } else if (strcmp("replicate", boundaryType)==0) {
        for (iX = 0; iX < nX; ++iX) {
            for (iY = 0; iY < nY; ++iY) {
                for (iKx = 0; iKx < nKx; ++iKx) {
                    for (iKy = 0; iKy < nKy; ++iKy) {
                        iiY = iY + iKy - nHy;
                        iiX = iX + iKx - nHx;
                        if (iiY < 0) {
                            iiY = 0;
                        }
                        if (iiY > (nY-1)) {
                            iiY = nY-1;
                        }
                        if (iiX < 0) {
                            iiX = 0;
                        }
                        if (iiX > (nX-1)) {
                            iiX = nX-1;
                        }
                        T[iKy + iKx*nKy] = Z[iiY + iiX*nY];
                    }
                }
                //F[iY + iX*nY] = selectKth(T, nKx*nKy, (nKx*nKy)/2);
                F[iY + iX*nY] = median(T, nKx*nKy);
            }
        }
        
    // ********************************************************************
    // Zeros
    // ********************************************************************
    } else if (strcmp("zeros", boundaryType)==0) {
        for (iX = 0; iX < nX; ++iX) {
            for (iY = 0; iY < nY; ++iY) {
                for (iKx = 0; iKx < nKx; ++iKx) {
                    for (iKy = 0; iKy < nKy; ++iKy) {
                        iiY = iY + iKy - nHy;
                        iiX = iX + iKx - nHx;
                        if ((0 <= iiY) && (iiY < nY) 
                         && (0 <= iiX) && (iiX < nX)) {
                            T[iKy + iKx*nKy] = Z[iiY + iiX*nY];
                        } else {
                            T[iKy + iKx*nKy] = 0.0;
                        }
                    }
                }
                //F[iY + iX*nY] = selectKth(T, nKx*nKy, (nKx*nKy)/2);
                F[iY + iX*nY] = median(T, nKx*nKy);
            }
        }
    } else {
        iExit = -1;
    }
    free(T);
    return iExit;
}

/* Filters peaks out of the image. */
int peakFilter2(double* Z,      // Input/return values: nY x nX.
                 int    nX,     // Number of columns.
                 int    nY) {   // Number of rows.
/*
    Zsmooth     = medfilt2(Z,[3 3],'symmetric');
    Replace     = abs(Z-Zsmooth) > mean(abs(Zsmooth(:)));
    Z(Replace)  = Zsmooth(Replace);
 */
    int iPixel, nPixel, iExit;
    double meanAbsValue;
    double* ZSmooth;
    ZSmooth = (double*) malloc(sizeof(double) * nX * nY);    
    iExit = medianFilter2(ZSmooth, Z, nX, nY, 3, 3, "symmetric");        
    nPixel = nX * nY;
    meanAbsValue = meanAbs(ZSmooth, nPixel);
    for (iPixel = 0; iPixel < nPixel; ++iPixel) {
        if (fabs(Z[iPixel]-ZSmooth[iPixel]) > meanAbsValue) {
            Z[iPixel] = ZSmooth[iPixel];
        }
    }
    free(ZSmooth);
    return iExit;
}


/* This function is part of imresize. */
double boxKernel(double x) {
//F = (-0.5 <= X) & (X < 0.5);
    if (-0.5 <= x && x < 0.5) { return 1.0; }
    return 0.0;
}

/* This function is part of imresize. */
double cubicKernel(double x) {
    double absx, absx2, absx3;
//    Absx    = abs(X);
//    Absx2   = Absx.^2;
//    Absx3   = Absx.^3;
    absx    = fabs(x);
    absx2   = absx*absx;
    absx3   = absx2*absx;
//    F       = (1.5*Absx3 - 2.5*Absx2 + 1) .* (Absx <= 1) ...
//            + (-0.5*Absx3 + 2.5*Absx2 - 4*Absx + 2) .* ((1 < Absx) & (Absx <= 2));
    // Between 0 and 1.
    if (absx <= 1.0) {
        return (1.5*absx3 - 2.5*absx2 + 1.0);
    }
    // Between 1 and 2.
    if (absx <= 2.0) { 
        return (-0.5*absx3 + 2.5*absx2 - 4*absx + 2.0);
    }
    // Larger than 2.
    return 0.0;
}

/* This function is part of imresize. */
void weightsAndIndices(double   *W,                 // Output weights nOut x nKernel
                       int      *I,                 // Output indices nOut x nKernel
                       double   s,                  // Scale factor.
                       double   (*fKernel)(double), // Function handle to kernel.
                       int      nIn,                // Input dimension.
                       int      nOut,               // Output dimension.
                       double   sKernel,            // Scaled sKernel is a floating point.
                       int      nKernel) {          // nKernel size of the kernel.
    /*
scale   = nOut/nIn;
X       = (1:nOut)'; % Output indices.
U       = X/scale + 0.5 * (1 - 1/scale); % Input indices.
Left    = floor(U - nKernel/2); % Left pixel.
Indices = bsxfun(@plus, Left, 0:(nKernel+1)); % +2 left/right
Weights = kernel(bsxfun(@minus, U, Indices));
Weights = bsxfun(@rdivide, Weights, sum(Weights, 2)); % Normalize over row.
Indices = MIN(MAX(1, Indices), nIn); % Clamp indices to in range values.
kill    = find(~any(Weights, 1)); % Delete columns with all zeros.
if ~isempty(kill)
    Weights(:,kill) = [];
    Indices(:,kill) = [];
end
*/
    double scale, u, weight, sum;
    int iOut, iKernel, left, index;
    scale = ((double) nOut)/nIn;
    //nKernel = (int)sKernel;
    
    //printf("  Within weights: nKernel = %d and sKernel = %e.\n", nKernel, sKernel);
    
    for (iOut = 0; iOut < nOut; ++iOut) {
        u = ((double)(1+iOut))/scale + 0.5*(1.0 - 1.0/scale);
        left = (int) floor(u - ((double) sKernel)/2.0);
        sum = 0.0;
        // Calculat the index and the weight.
        for (iKernel = 0; iKernel < nKernel; ++iKernel) {
            index = left + (1 + iKernel);
            weight = (*fKernel)(s*(u-index));
            weight *= s;
            sum += weight;
            /*
            if ((iOut + iKernel*nOut)<0 || (iOut + iKernel*nOut)>=nKernel*nOut) {
                printf("Index is %d but should be >0 and <%d.\n", 
                        iOut+iKernel*nOut, nKernel*nOut);
            } else {
                W[iOut + iKernel*nOut] = weight;
                I[iOut + iKernel*nOut] = MIN(MAX(index, 1), nIn) - 1;
            }
            */
            W[iOut + iKernel*nOut] = weight;
            I[iOut + iKernel*nOut] = MIN(MAX(index, 1), nIn) - 1;
        }
        // Normalize the weight.
        for (iKernel = 0; iKernel < nKernel; ++iKernel) {
            /*
            if ((iOut + iKernel*nOut)<0 || (iOut + iKernel*nOut)>=nKernel*nOut) {
                printf("Index is %d but should be >0 and <%d.\n", 
                        iOut+iKernel*nOut, nKernel*nOut);
            } else {
                W[iOut + iKernel*nOut] /= sum;
            }
            */
            W[iOut + iKernel*nOut] /= sum;
        }
    }
}

/* This function is part of imresize. */
int doResize(double *F,         // Returndd values: nY x nXi / nYi x nX
             double *Z,         // Input values: nY x nX.
             double *W,         // Weights: nXi x nKernel / nYi x nKernel
             int    *I,         // Indices: nXi x nKernel / nYi x nKernel
             int    nX,         // Columns of input.
             int    nY,         // Rows of input.
             int    nXi,        // Columns of output.
             int    nYi,        // Rows of output.
             int    nKernel,    // Number of elements for interpolation kernel.
             int    iDim) {     // Index of dimension for interpolation.
    if (iDim==0) {
        /*
        nYi = size(W,1);
        nX = size(V,2);
        F = zeros(nYi,nX);
        for iX = 1:nX,
            for iYi = 1:nYi,
                F(iYi,iX) = sum(V(I(iYi,:),iX).*W(iYi,:)');
            end
        end         
         */        
        int iX, iYi, iK;
        double sum;
        for (iX = 0; iX < nX; ++iX) {
            for (iYi = 0; iYi < nYi; ++iYi) {
                sum = 0.0;
                for (iK = 0; iK < nKernel; ++iK) {
                    // Notice Z is nY x nX
                    // Notice I and W are nYi x nK
                    /*
                    if ((I[iYi + iK*nYi] + iX*nY) < 0 || (I[iYi + iK*nYi] + iX*nY)>(nY*nX-1)
                        || (iYi + iK*nYi)<0 || (iYi + iK*nYi)>(nYi*nKernel-1)) {
                        printf("Index %d for Z should be >0 and <%d.\n", I[iYi + iK*nYi] + iX*nY,nY*nX);
                        printf("Index %d for W should be >0 and <%d.\n", iYi + iK*nYi, nYi*nKernel);
                    } else {
                        sum += Z[I[iYi + iK*nYi] + iX*nY] * W[iYi + iK*nYi];
                    }
                    */
                    sum += Z[I[iYi + iK*nYi] + iX*nY] * W[iYi + iK*nYi];
                }
                F[iYi + iX*nYi] = sum;
            }
        }
        return 0;
    }
    if (iDim==1) {
        /*
        nXi = size(W,1);
        nY = size(V,1);
        F = zeros(nY,nXi);
        for iXi = 1:nXi,
            for iY = 1:nY,
                F(iY,iXi) = sum(V(iY,I(iXi,:)).*W(iXi,:));
            end
        end         
         */
        int iXi, iYi, iK;
        double sum;
        for (iXi = 0; iXi < nXi; ++iXi) {
            for (iYi = 0; iYi < nYi; ++iYi) {
                sum = 0.0;
                for (iK = 0; iK < nKernel; ++iK) {
                    // Notice Z is nYi x nX
                    // Notice I and W are nXi x nK
                    /*
                    if ((iYi + I[iXi + iK*nXi]*nYi) < 0 || (iYi + I[iXi + iK*nXi]*nYi)>(nYi*nX-1)
                        || (iXi + iK*nXi)<0 || (iXi + iK*nXi)>(nXi*nKernel-1)) {
                        printf("Index %d for Z should be >0 and <%d.\n", iYi + I[iXi + iK*nXi]*nYi,nYi*nX);
                        printf("Index %d for W should be >0 and <%d.\n", iXi + iK*nXi, nXi*nKernel);
                    } else {
                        sum += Z[iYi + I[iXi + iK*nXi]*nYi] * W[iXi + iK*nXi];
                    } 
                    */             
                    sum += Z[iYi + I[iXi + iK*nXi]*nYi] * W[iXi + iK*nXi];
                }
                F[iYi+iXi*nYi] = sum;
            }
        }
        return 0;
    }
    return -1;
}

/* Resize the image using an interpolation method. */
int imresize2(double    *F,             // 1 Returned matrix: nYi x nXi.
              double    *Z,             // 2 Input matrix: nY x nX.
              int       nX,             // 3 Columns of input.
              int       nY,             // 4 Rows of input.
              int       nXi,            // 5 Columns of output.
              int       nYi,            // 6 Rows of output.
              char*     interpType) {   // 7 Interpolation type.
    double (*fKernel)(double); // function handle
    int nKernel, nKernelX, nKernelY;
    double sKernelX, sKernelY, sX, sY;
    double *Wy, *Wx, *T; // weights, temporary.
    int *Iy, *Ix; // indices
    int antialiasing;
    nKernel = 0;
    sX = ((double)nXi)/nX;
    sY = ((double)nYi)/nY;
    antialiasing = 0;
    
    if (strcmp(interpType, "nearest")==0) {
        fKernel = &boxKernel;
        nKernel = 1;
        
    } else if (strcmp(interpType, "cubic")==0) {
        antialiasing = 1;
        fKernel = &cubicKernel;
        nKernel = 4;
        if (nY<3 || nX<3) {
            return -1;
        }
        
    } else {
        return -1;
    }
    
    sKernelY    = nKernel;
    sKernelX    = nKernel;
    nKernelY    = nKernel;
    nKernelX    = nKernel;
    
    //printf("Input values.\n");
    //printDoubleMatrix(Z,nX,nY);
    
    // scale the kernel by the factor.
    if (sY < 1 && antialiasing) {
        sKernelY    = nKernel/sY;
        nKernelY    = (int)sKernelY + 1;// antialising is only for cubic and there we need to add 1.
    } else {
        sY = 1.0;
    }
    
    // Work on y dimension.
    Wy = (double*) malloc(sizeof(double) * nYi * nKernelY);
    Iy = (int*) malloc(sizeof(int) * nYi * nKernelY);
    T = (double*) malloc(sizeof(double) * nYi * nX);
    
    weightsAndIndices(Wy, Iy, sY, fKernel, nY, nYi, sKernelY, nKernelY);
    //printf("Print weights and indices for y-dimension.\n");
    //printf("Weights = \n");
    //printDoubleMatrix(Wy, nKernel, nYi);
    //printf("Indices = \n");
    //printIntegerMatrix(Iy, nKernel, nYi);
    doResize(T, Z, Wy, Iy, nX, nY, nXi, nYi, nKernelY, 0);
    free(Wy);
    free(Iy);
    
    //printf("Interim result.\n");
    //printDoubleMatrix(T,nX,nYi);
    
    if (sX < 1 && antialiasing) {
        sKernelX    = nKernel/sX;
        nKernelX    = (int)sKernelX + 1; // antialising is only for cubic and there we need to add 1.
    } else {
        sX = 1.0;
    }
    
    // Work on x dimension.
    Wx = (double*) malloc(sizeof(double) * nXi * nKernelX);
    Ix = (int*) malloc(sizeof(int) * nXi * nKernelX);    
    weightsAndIndices(Wx, Ix, sX, fKernel, nX, nXi, sKernelX, nKernelX);
    //printf("Print weights and indices for x-dimension.\n");
    //printf("Weights = \n");
    //printDoubleMatrix(Wx, nKernel, nXi);
    //printf("Indices = \n");
    //printIntegerMatrix(Ix, nKernel, nXi);
    doResize(F, T, Wx, Ix, nX, nY, nXi, nYi, nKernelX, 1);
    
    free(Wx);
    free(Ix);
    free(T);
    return 0;
}

/* Nearest neighborhood interpolation for a 2D input image. */
int nearestInterp2(double   *F,     // 1 Returned matrix: nYi x nXi.
                   double   *X,     // 2 Horizontal inputs: nX x 1.
                   double   *Y,     // 3 Vertical inputs: nY x 1.
                   double   *Z,     // 4 Input values: nY x nX.
                   double   *Xi,    // 5 Horizontal interpolation: nXi x 1.
                   double   *Yi,    // 6 Vertical interpolation: nYi x 1.
                   int      nX,     // 7 Columns of input.
                   int      nY,     // 8 Rows of input.
                   int      nXi,    // 9 Columns of output.
                   int      nYi) {  // 10 Rows of output.
    /* Variables for auxiliary expressions. */
    double nan, u, v, sX, sY;
    /* Index variables */
    int iXi, iX, iYi, iY;        
    nan = mxGetNaN();
    
    sX = 1.0;
    sY = 1.0;
    
    if (nX>1 && nY>1) {
        sX = ((double) (nX-1)) / (X[nX-1] - X[0]);
        sY = ((double) (nY-1)) / (Y[nY-1] - Y[0]);
    }   
    
    for (iXi = 0; iXi < nXi; ++iXi) {
        u   = (Xi[iXi] - X[0]) * sX;
        iX  = (int) round(u);
        for (iYi = 0; iYi < nYi; ++iYi) {         
            v   = (Yi[iYi] - Y[0]) * sY;
            iY  = (int) round(v);
            if (iY < 0 || iY > (nY-1) || iX < 0 || iX > (nX-1)) {
                F[iYi + iXi*nYi] = nan;
            } else {
                F[iYi + iXi*nYi] = Z[iY + iX*nY];
            }
        }
    }
    return 0;
}

/* Cubic interpolation for a 2D input image. */
int cubicInterp2(double     *F,     // 1 Returned matrix: nYi x nXi.
                 double     *X,     // 2 Horizontal inputs: nY x nX.
                 double     *Y,     // 3 Vertical inputs: nY x nX.
                 double     *Z,     // 4 Input values: nY x nX.
                 double     *Xi,    // 5 Horizontal outputs: nYi x nXi.
                 double     *Yi,    // 6 Vertical inputs: nYi x nXi.
                 int        nX,     // 7 Columns of input.
                 int        nY,     // 8 Rows of input.
                 int        nXi,    // 9 Columns of output.
                 int        nYi) {  // 10 Rows of output.
    /* Temporary matrix variable for coefficients */
    double *C;
    /* Variables for auxiliary expressions. */
    double nan, s0, s1, s2, s3, t0, t1, t2, t3, s, t, x0, x1, y0, y1, temp0, temp1, temp2, temp3;
    double c00, c01, c02, c03, c10, c11, c12, c13, c20, c21, c22, c23, c30, c31, c32, c33;
    /* Index variables */
    int iXi, iX, iYi, iY, iiX, iiY;
    
    if (nY<3 || nX<3) {
        return -1;
    }
    
    nan	= mxGetNaN();
    
    // Pre-compute the coefficients for the cubic interpolation.
    C = (double*) malloc(sizeof(double) * (nY+2) * (nX+2)); // (nY+2) x (nX+2)

    // The four edges.
    for (iY = 0; iY < nY; ++iY) {
        // Left boundary.
        // C(1+iY,1) = 3*Z(iY,1) - 3*Z(iY,2) + Z(iY,3);
        C[1+iY + 0*(nY+2)]      = 3.0*Z[iY + 0*nY] - 3.0*Z[iY + 1*nY] + Z[iY + 2*nY];
        // Right boundary.
        // C(1+iY,nX+2) = 3*Z(iY,nX) - 3*Z(iY,nX-1) + Z(iY,nX-2);
        C[1+iY + (nX+1)*(nY+2)] = 3.0*Z[iY + (nX-1)*nY] - 3.0*Z[iY + (nX-2)*nY] + Z[iY + (nX-3)*nY];
    }
    for (iX = 0; iX < nX; ++iX) {
        // Upper boundary.
        // C(1,1+iX) = 3*Z(1,iX) - 3*Z(2,iX) + Z(3,iX);
        C[0 + (1+iX)*(nY+2)] = 3.0*Z[0 + iX*nY] - 3.0*Z[1 + iX*nY] + Z[2 + iX*nY];
        // Lower boundary.
        // C(nY+2,1+iX) = 3*Z(nY,iX) - 3*Z(nY-1,iX) + Z(nY-2,iX);
        C[nY+1 + (1+iX)*(nY+2)] = 3.0*Z[nY-1 + iX*nY] - 3.0*Z[nY-2 + iX*nY] + Z[nY-3 + iX*nY];
    }
    
    // The four courners.
    // C(-1,-1)      = 3*C(0,-1) - 3*C(1,-1) + C(2,-1) +1,+1
    C[0 + 0*(nY+2)] = 3.0*C[1 + 0*(nY+2)] - 3.0*C[2 + 0*(nY+1)] + C[3 + 0*(nY+1)];
    // C(N+1,-1)     = 3*C(N,-1) - 3*C(N-1,-1) + C(N-2,-1) +0,+1
    C[nY+1 + 0*(nY+2)] = 3.0*C[nY + 0*(nY+2)] - 3.0*C[nY-1 + 0*(nY+2)] + C[nY-2 + 0*(nY+2)];
    // C(-1,M+1)     = 3*C(0,M+1) - 3*C(1,M+1) + C(2,M+1) +1,+0
    C[0 + (nX+1)*(nY+2)] = 3.0*C[1 + (nX+1)*(nY+2)] - 3.0*C[2 + (nX+1)*(nY+2)] + C[3 + (nX+1)*(nY+2)];
    // C(N+1,M+1)    = 3*C(N,M+1) - 3*C(N-1,M+1) + C(N-2,M+1) +0,+0
    C[nY+1 + (nX+1)*(nY+2)] = 3.0*C[nY + (nX+1)*(nY+2)] - 3.0*C[nY-1 + (nX+1)*(nY+2)] + C[nY-2 + (nX+1)*(nY+2)];
    
    // Copy the remaning values into indices 1...nY and 1...nX.
    for (iX = 0; iX < nX; ++iX){
        for (iY = 0; iY < nY; ++iY) {
            C[iY+1 + (iX+1)*(nY+2)] = Z[iY + iX*nY];
        }
    }
    
    // End-points of input ranges.
    x0 = X[0 + 0*nY];
    x1 = X[nY-1 + (nX-1)*nY];
    y0 = Y[0 + 0*nY];
    y1 = Y[nY-1 + (nX-1)*nY];
    
    // Cubic interpolation.
    for (iXi = 0; iXi < nXi; ++iXi) {
        for (iYi = 0; iYi < nYi; ++iYi) {
            
            // Get the locations for the interpolation.
            s = (Xi[iYi + iXi*nYi] - x0) / (x1-x0) * (nX - 1);
            t = (Yi[iYi + iXi*nYi] - y0) / (y1-y0) * (nY - 1);
            //s = (Xi[iYi + iXi*nYi] - x0)*(nX - 1)/(x1 - x0);
            //t = (Yi[iYi + iXi*nYi] - y0)*(nY - 1)/(y1 - y0);
            
            // If the index it out of range set the value to NaN.
            if ( (s < 0) || (s > (nX-1)) || (t < 0) || (t > (nY-1)) ) {
                
                F[iYi + iXi*nYi] = nan;
                
            } else {
                iY = (int)floor(t);
                iX = (int)floor(s);
                s = s - iX;
                t = t - iY;
                
                // Handle the case when the index is the last.
                if ( iY == (nY-1) ) {
                    iiY = nY - 1;
                    t = t + 1.0;
                } else {
                    iiY = iY + 1;
                }
                
                // Handle the case when the index is the last.
                if ( iX == (nX-1) ) {
                    iiX = nX - 1;
                    s = s + 1.0;
                } else {
                    iiX = iX + 1;
                }
                
                // Compute the variables of the interpolation polyonmials.
                t0 = ((2.0-t)*t-1.0)*t;
                t1 = (3.0*t-5.0)*t*t+2.0;
                t2 = ((4.0-3.0*t)*t+1.0)*t;
                t3 = (t-1.0)*t*t;

                s0 = ((2.0-s)*s-1.0)*s;
                s1 = (3.0*s-5.0)*s*s+2.0;
                s2 = ((4.0-3.0*s)*s+1.0)*s;
                s3 = (s-1.0)*s*s;
                
                // Get the 16 coefficients.
                c00 = C[iiY-1 + (iiX-1)*(nY+2)];
                c10 = C[iiY+0 + (iiX-1)*(nY+2)];
                c20 = C[iiY+1 + (iiX-1)*(nY+2)];
                c30 = C[iiY+2 + (iiX-1)*(nY+2)];

                c01 = C[iiY-1 + (iiX+0)*(nY+2)];
                c11 = C[iiY+0 + (iiX+0)*(nY+2)];
                c21 = C[iiY+1 + (iiX+0)*(nY+2)];
                c31 = C[iiY+2 + (iiX+0)*(nY+2)];

                c02 = C[iiY-1 + (iiX+1)*(nY+2)];
                c12 = C[iiY+0 + (iiX+1)*(nY+2)];
                c22 = C[iiY+1 + (iiX+1)*(nY+2)];
                c32 = C[iiY+2 + (iiX+1)*(nY+2)];

                c03 = C[iiY-1 + (iiX+2)*(nY+2)];
                c13 = C[iiY+0 + (iiX+2)*(nY+2)];
                c23 = C[iiY+1 + (iiX+2)*(nY+2)];
                c33 = C[iiY+2 + (iiX+2)*(nY+2)];

                // Cubic interpolation for rows first.
                temp0 = t0*c00 + t1*c10 + t2*c20 + t3*c30;
                temp1 = t0*c01 + t1*c11 + t2*c21 + t3*c31;
                temp2 = t0*c02 + t1*c12 + t2*c22 + t3*c32;
                temp3 = t0*c03 + t1*c13 + t2*c23 + t3*c33;

                // Cubic interpolation for columns second.
                F[iYi + iXi*nYi] = (s0*temp0 + s1*temp1 + s2*temp2 + s3*temp3)/4.0;                
                
                /*
                // Cubic interpolation for rows first.
                F[iYi + iXi*nYi]  = s0*(t0*c00 + t1*c10 + t2*c20 + t3*c30);
                F[iYi + iXi*nYi] += s1*(t0*c01 + t1*c11 + t2*c21 + t3*c31);
                F[iYi + iXi*nYi] += s2*(t0*c02 + t1*c12 + t2*c22 + t3*c32);
                F[iYi + iXi*nYi] += s3*(t0*c03 + t1*c13 + t2*c23 + t3*c33);
                
                F[iYi + iXi*nYi] /= 4.0;
                 */
            }
        }
    }
    free(C);
    return 0;
}

int diffWarp2(double* Ix, // 1 Return value, length nY x nX
               double* Iy, // 2 Return value, length nY x nX
               double* It, // 3 Return value, length nY x nX
               double* I1, // 4 First input image, length nY x nX
               double* I2, // 5 Second input image, length nY x nX
               double* Dx, // 6 First component of differential to warp, length nY x nX
               double* Dy, // 7 Second component of differential to warp, length nY x nX
               int nX,     // 8 Number of horizontal dimensions
               int nY) {   // 9 Number of vertical dimensions
    int iX, iY, i, iExit;
    double *X, *Y, *Xi, *Yi, *XiM, *YiM, *XiP, *YiP, *IyM, *IxM;
    int *B;
    double xdx, ydy;
    //printf("Called warp2.\n");
    X   = (double*) malloc(sizeof(double) * nX * nY);
    Y   = (double*) malloc(sizeof(double) * nX * nY);
    Xi  = (double*) malloc(sizeof(double) * nX * nY);
    Yi  = (double*) malloc(sizeof(double) * nX * nY);
    XiM = (double*) malloc(sizeof(double) * nX * nY);
    YiM = (double*) malloc(sizeof(double) * nX * nY);
    XiP = (double*) malloc(sizeof(double) * nX * nY);
    YiP = (double*) malloc(sizeof(double) * nX * nY);
    IyM = (double*) malloc(sizeof(double) * nX * nY);
    IxM = (double*) malloc(sizeof(double) * nX * nY);
    B   = (int*) malloc(sizeof(int) * nX * nY);
    
    /*
    [nH nW] = size(I1);
    [Idy Idx] = ndgrid(1:nH, 1:nW);

    Idxx = Idx + Dx;
    Idyy = Idy + Dy;
    Boundary = (Idxx > nW-1) | (Idxx < 2) | (Idyy > nH-1) | (Idyy < 2);

    Idxx = MAX(1,MIN(nW,Idxx));
    Idxm = MAX(1,MIN(nW,Idxx-0.5));
    Idxp = MAX(1,MIN(nW,Idxx+0.5));

    Idyy = MAX(1,MIN(nH,Idyy));
    Idym = MAX(1,MIN(nH,Idyy-0.5));
    Idyp = MAX(1,MIN(nH,Idyy+0.5));
    */
    
    for (iY = 0; iY < nY; ++iY) {
        for (iX = 0; iX < nX; ++iX) {
            i = iY + iX*nY;
            xdx = 1 + iX;
            ydy = 1 + iY;
            X[i] = xdx;
            Y[i] = ydy;
            xdx += Dx[i];
            ydy += Dy[i];
            // Boundary = (Idxx > nW-1) | (Idxx < 2) | (Idyy > nH-1) | (Idyy < 2);
            if ( (xdx > (nX-1)) || (xdx < 2) || (ydy > (nY-1)) || (ydy < 2)) {
                B[i] = 1;
            } else {
                B[i] = 0;
            }
            xdx = MAX(1, MIN(nX, xdx));
            ydy = MAX(1, MIN(nY, ydy));
            
            Xi[i] = xdx;
            Yi[i] = ydy;
            
            XiM[i] = MAX(1, MIN(nX, xdx-0.5));
            YiM[i] = MAX(1, MIN(nY, ydy-0.5));
            
            XiP[i] = MAX(1, MIN(nX, xdx+0.5));
            YiP[i] = MAX(1, MIN(nY, ydy+0.5));            
        }
    }
    
    /*
    I2Warped = interp2(I2,Idxx,Idyy,'cubic');
    I2xWarped = interp2(I2,Idxp,Idyy,'cubic') - interp2(I2,Idxm,Idyy,'cubic');
    I2yWarped = interp2(I2,Idxx,Idyp,'cubic') - interp2(I2,Idxx,Idym,'cubic');
    
    % Use average to improve the accuracy.
    Ix = I2xWarped;
    Iy = I2yWarped;
    It = I2Warped  - I1;

    % Handle boundary.
    Ix(Boundary) = 0;
    Iy(Boundary) = 0;
    It(Boundary) = 0;
    */
    
    // I2
    iExit = cubicInterp2(It,    X,Y,I2,Xi,Yi,   nX,nY,nX,nY);
    // I2x
    iExit = cubicInterp2(Ix,    X,Y,I2,XiP,Yi,  nX,nY,nX,nY);
    iExit = cubicInterp2(IxM,   X,Y,I2,XiM,Yi,  nX,nY,nX,nY);
    // I2y
    iExit = cubicInterp2(Iy,    X,Y,I2,Xi,YiP,  nX,nY,nX,nY);
    iExit = cubicInterp2(IyM,   X,Y,I2,Xi,YiM,  nX,nY,nX,nY);
    
    for (iY = 0; iY < nY; ++iY) {
        for (iX = 0; iX < nX; ++iX) {
            i = iY + iX*nY;
            if (B[i] != 0) {
                It[i] = 0.0;
                Ix[i] = 0.0;
                Iy[i] = 0.0;
            } else {
                It[i] -= I1[i];
                Ix[i] -= IxM[i];
                Iy[i] -= IyM[i];
            }            
        }
    }
    
    free(B);
    free(IxM);
    free(IyM);
    free(YiP);
    free(XiP);
    free(YiM);
    free(XiM);
    free(Yi);
    free(Xi);
    free(X);    
    free(Y);
    
    return iExit;
}
