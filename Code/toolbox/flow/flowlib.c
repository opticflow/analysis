#include "flowlib.h"
#include "imagelib.h"
#include "mex.h"
#include <math.h>
#include <string.h>

void tvL1PrimalDual2(double* Dx,    // 1 inplace modification, nY x nX
                     double* Dy,    // 2 inplace modification, nY x nX
                     double* Dt,    // 3 inplace modification, nY x nX
                     double* P,     // 4 inplace modification nP x nY x nX
                     double* I1,    // 5 First image, nY x nX.
                     double* I2,    // 6 Second image, nY x nX.
                     int nX,        // 7 Number of columns.
                     int nY,        // 8 Number of rows.
                     int nP,        // 9 Number of parameters.
                     double lambda, // 10 Parameter.
                     int nWarp,     // 11 Number of warps.
                     int nIter) {   // 12 Number of iterations.
    double *Dx0, *Dy0, *GradSq, *DxOld, *DyOld, *DtOld, *Ix, *Iy, *It;
    double ux, uy, vx, vy, wx, wy, rProject, divDx, divDy, divDt, rho, gradSq;
    int iWarp, iIter, iPixel, nPixel, nByte, i, iXP, iYP, iXM, iYM, iX, iY;
    
    //double *Ux, *Uy, *Vx, *Vy, *Wx, *Wy; // variables for debugging
    //double *DivDx, *DivDy, *DivDt;
    
    nPixel  = nY * nX;
    nByte   = sizeof(double) * nPixel;
    Dx0     = (double*) malloc(nByte);
    Dy0     = (double*) malloc(nByte);
    GradSq  = (double*) malloc(nByte);
    DxOld   = (double*) malloc(nByte);
    DyOld   = (double*) malloc(nByte);
    DtOld   = (double*) malloc(nByte);
    Ix      = (double*) malloc(nByte);
    Iy      = (double*) malloc(nByte);
    It      = (double*) malloc(nByte);
    
    // Variable for debugging.
    //Ux      = (double*) malloc(nByte);
    //Uy      = (double*) malloc(nByte);
    //Vx      = (double*) malloc(nByte);
    //Vy      = (double*) malloc(nByte);
    //Wx      = (double*) malloc(nByte);
    //Wy      = (double*) malloc(nByte);
    //DivDx   = (double*) malloc(nByte);
    //DivDy   = (double*) malloc(nByte);
    //DivDt   = (double*) malloc(nByte);
    
    // Save flow variables.
    // DxOld = Dx;
    // DyOld = Dy;
    // DtOld = Dt;
    memcpy(DxOld, Dx, nByte);
    memcpy(DyOld, Dy, nByte);
    memcpy(DtOld, Dt, nByte);
    
    for (iWarp = 0; iWarp < nWarp; ++iWarp) {
        // Dx0 = Dx;
        memcpy(Dx0, Dx, nByte); // copy from Dx to Dx0.
        // Dy0 = Dy;        
        memcpy(Dy0, Dy, nByte); // copy from Dy to Dy0.
        
        // Warp I2 -> I1.
        // [Ix, Iy, It] = warp(I1, I2, Dx0, Dy0);
        diffWarp2(Ix,Iy,It, I1,I2,Dx,Dy, nX,nY);
        // Compute the gradient.
        // GradSq = MAX(1e-09, Ix.^2 + Iy.^2 + GAMMA*GAMMA);
        for (iPixel = 0; iPixel < nPixel; ++iPixel) {
            GradSq[iPixel] = MAX(1.0e-9, 
                    Ix[iPixel]*Ix[iPixel] + Iy[iPixel]*Iy[iPixel] + GAMMA2);
        }
        
        // printf("GradSq = \n\n");
        // printDoubleMatrix(GradSq, nX, nY);
        
        for (iIter = 0; iIter < nIter; ++iIter) {
            // ************************************************************
            // SOLVE THE DUAL PROBLEM
            // ************************************************************
            for (iX = 0; iX < nX; ++iX) {
                for (iY = 0; iY < nY; ++iY) {
                    i = iY + iX*nY;
                    if (iY >= (nY-1)) {
                        iYP = (nY - 1) + iX*nY;
                    } else {
                        iYP = (iY + 1) + iX*nY;
                    }
                    if (iX >= (nX-1)) {
                        iXP = iY + (nX - 1)*nY;
                    } else {
                        iXP = iY + (iX + 1)*nY;
                    }
                    // u_x = dxPlus(DxOld);
                    ux = DxOld[iXP] - DxOld[i];
                    // u_y = dyPlus(DxOld);
                    uy = DxOld[iYP] - DxOld[i];
                    // v_x = dxPlus(DyOld);
                    vx = DyOld[iXP] - DyOld[i];
                    // v_y = dyPlus(DyOld);
                    vy = DyOld[iYP] - DyOld[i];
                    // w_x = dxPlus(DtOld);
                    wx = DtOld[iXP] - DtOld[i];
                    // w_y = dyPlus(DtOld);
                    wy = DtOld[iYP] - DtOld[i];
                    
                    // Debugging info.
                    //Ux[i] = ux;
                    //Uy[i] = uy;
                    //Vx[i] = vx;
                    //Vy[i] = vy;
                    //Wx[i] = wx;
                    //Wy[i] = wy;
                    
                    // iP + iY*nP + iX*nP*nY = iP + (iY+iX*nY)*nP = iP + i*nP
                    // P(:,:,1) = (P(:,:,1) + SIGMA*u_x)/(1 + SIGMA*EPS_XY);
                    P[0 + i*nP] = (P[0 + i*nP] + SIGMA*ux); // /(1+SIGMA*EPS_XY); // EPS_XY=0
                    // P(:,:,2) = (P(:,:,2) + SIGMA*u_y)/(1 + SIGMA*EPS_XY);
                    P[1 + i*nP] = (P[1 + i*nP] + SIGMA*uy); // /(1+SIGMA*EPS_XY);                    
                    // P(:,:,3) = (P(:,:,3) + SIGMA*v_x)/(1 + SIGMA*EPS_XY);
                    P[2 + i*nP] = (P[2 + i*nP] + SIGMA*vx); // /(1+SIGMA*EPS_XY);
                    // P(:,:,4) = (P(:,:,4) + SIGMA*v_y)/(1 + SIGMA*EPS_XY);
                    P[3 + i*nP] = (P[3 + i*nP] + SIGMA*vy); // /(1+SIGMA*EPS_XY);
                    // P(:,:,5) = (P(:,:,5) + SIGMA*w_x)/(1 + SIGMA*EPS_T);
                    P[4 + i*nP] = (P[4 + i*nP] + SIGMA*wx); // /(1+SIGMA*EPS_T); // EPS_T=0
                    // P(:,:,6) = (P(:,:,6) + SIGMA*w_y)/(1 + SIGMA*EPS_T);
                    P[5 + i*nP] = (P[5 + i*nP] + SIGMA*wy); // /(1+SIGMA*EPS_T);
                    // Reprojection to |pu| <= 1
                    // Reproject = MAX(1, sqrt(sum(P(:,:,1:4).^2,3)));
                    rProject = MAX(1.0, sqrt(P[0 + i*nP]*P[0 + i*nP]
                                           + P[1 + i*nP]*P[1 + i*nP]
                                           + P[2 + i*nP]*P[2 + i*nP]
                                           + P[3 + i*nP]*P[3 + i*nP]));
                    // P(:,:,1) = P(:,:,1)./Reproject;
                    P[0 + i*nP] /= rProject;
                    // P(:,:,2) = P(:,:,2)./Reproject;
                    P[1 + i*nP] /= rProject;
                    // P(:,:,3) = P(:,:,3)./Reproject;
                    P[2 + i*nP] /= rProject;
                    // P(:,:,4) = P(:,:,4)./Reproject;
                    P[3 + i*nP] /= rProject;
                    // Reproject = MAX(1, sqrt(sum(P(:,:,5:6).^2,3)));
                    rProject = MAX(1, sqrt(P[4 + i*nP]*P[4 + i*nP]
                                         + P[5 + i*nP]*P[5 + i*nP]));
                    // P(:,:,5) = P(:,:,5)./Reproject;
                    P[4 + i*nP] /= rProject;
                    // P(:,:,6) = P(:,:,6)./Reproject;
                    P[5 + i*nP] /= rProject;
                }
            }
            
            // ************************************************************
            // SOLVE THE PRIMAL PROBLEM
            // ************************************************************
            for (iX = 0; iX < nX; ++iX) {
                for (iY = 0; iY < nY; ++iY) {
                    i   = iY    + iX*nY;                             
                    iXM = iY    + (iX-1)*nY;
                    iYM = iY-1  + iX*nY;
                    
                    // dx
                    if (iX == 0) { // first
                        divDx = P[0 + i*nP];
                        divDy = P[2 + i*nP];
                        divDt = P[4 + i*nP];
                    } else if (iX == (nX-1)) { // last
                        divDx = -P[0 + iXM*nP];
                        divDy = -P[2 + iXM*nP];
                        divDt = -P[4 + iXM*nP];
                    } else {
                        divDx = (P[0 + i*nP] - P[0 + iXM*nP]);
                        divDy = (P[2 + i*nP] - P[2 + iXM*nP]);
                        divDt = (P[4 + i*nP] - P[4 + iXM*nP]);
                    }
                    
                    // dy
                    if (iY == 0) { // first
                        divDx += P[1 + i*nP];
                        divDy += P[3 + i*nP];
                        divDt += P[5 + i*nP];
                    } else if (iY == (nY-1)) { // last
                        divDx += -P[1 + iYM*nP];
                        divDy += -P[3 + iYM*nP];
                        divDt += -P[5 + iYM*nP];
                    } else {
                        divDx += (P[1 + i*nP] - P[1 + iYM*nP]);
                        divDy += (P[3 + i*nP] - P[3 + iYM*nP]);
                        divDt += (P[5 + i*nP] - P[5 + iYM*nP]);
                    }
                    
                    //DivDx[i] = divDx; // debug information
                    //DivDy[i] = divDy;
                    //DivDt[i] = divDt;
                    
                    // Store the old Dx, Dy, Dt into DxOld, DyOld, DtOld.
                    // DxOld = Dx;
                    DxOld[i] = Dx[i];
                    // DyOld = Dy;
                    DyOld[i] = Dy[i];
                    // DtOld = Dt;
                    DtOld[i] = Dt[i];
                    // Update Dx, Dy, Dt.
                    // Dx = Dx + TAU*(DivDx);                    
                    Dx[i] += TAU*divDx;
                    // Dy = Dy + TAU*(DivDy);
                    Dy[i] += TAU*divDy;
                    // Dt = Dt + TAU*(DivDt);
                    Dt[i] += TAU*divDt;
                    // Proxy for operator of Dx, Dy, Dt.
                    // Rho = It + (Dx-Dx0).*Ix + (Dy-Dy0).*Iy + GAMMA*Dt;
                    rho = It[i] + (Dx[i]-Dx0[i])*Ix[i] + (Dy[i]-Dy0[i])*Iy[i] + GAMMA*Dt[i];
                    gradSq = GradSq[i];                    
                    // Index1 = Rho      < - TAU*lambda*GradSq;
                    if (rho < -TAU*lambda*gradSq) {
                        // Dx(Index1) = Dx(Index1) + TAU*lambda*Ix(Index1);
                        Dx[i] += TAU*lambda*Ix[i];
                        // Dy(Index1) = Dy(Index1) + TAU*lambda*Iy(Index1);
                        Dy[i] += TAU*lambda*Iy[i];
                        // Dt(Index1) = Dt(Index1) + TAU*lambda*GAMMA;
                        Dt[i] += TAU*lambda*GAMMA;
                    //Index2 = Rho      >   TAU*lambda*GradSq;
                    } else if (rho > TAU*lambda*gradSq) {
                        // Dx(Index2) = Dx(Index2) - TAU*lambda*Ix(Index2);
                        Dx[i] -= TAU*lambda*Ix[i];
                        // Dy(Index2) = Dy(Index2) - TAU*lambda*Iy(Index2);
                        Dy[i] -= TAU*lambda*Iy[i];
                        // Dt(Index2) = Dt(Index2) - TAU*lambda*GAMMA;
                        Dt[i] -= TAU*lambda*GAMMA;
                    // Index3 = abs(Rho) <=  TAU*lambda*GradSq;
                    } else {
                        // Dx(Index3) = Dx(Index3) - Rho(Index3).*Ix(Index3)./GradSq(Index3);
                        Dx[i] -= rho*Ix[i]/gradSq;
                        // Dy(Index3) = Dy(Index3) - Rho(Index3).*Iy(Index3)./GradSq(Index3);
                        Dy[i] -= rho*Iy[i]/gradSq;
                        // Dt(Index3) = Dt(Index3) - Rho(Index3).*GAMMA./GradSq(Index3);
                        Dt[i] -= rho*GAMMA/gradSq;
                    }
                    // Update the old variables.
                    // DxOld = 2*Dx - DxOld;
                    DxOld[i] = 2.0*Dx[i] - DxOld[i];
                    // DyOld = 2*Dy - DyOld;
                    DyOld[i] = 2.0*Dy[i] - DyOld[i];
                    // DtOld = 2*Dt - DtOld;
                    DtOld[i] = 2.0*Dt[i] - DtOld[i];
                }
            }            
        }
        // Filter that smoothers strong outliers.
        // Dx = peakFilter(Dx);
        peakFilter2(Dx, nX, nY);
        // Dy = peakFilter(Dy);
        peakFilter2(Dy, nX, nY);
    }
    //printf("DivDx = \n\n");
    //printDoubleMatrix(DivDx, nX, nY);
    
    //printf("Ix = \n\n");
    //printDoubleMatrix(Ix, nX, nY);
    
    
    //free(Wx);
    //free(Wy);
    //free(Vx);
    //free(Vy);
    //free(Ux);
    //free(Uy);
    
    //free(DivDx);
    //free(DivDy);
    //free(DivDt);
    
    free(It);
    free(Iy);
    free(Ix);
    free(DtOld);
    free(DyOld);
    free(DxOld);
    free(GradSq);
    free(Dx0);
    free(Dy0);
}

struct Matrix2D {
    int nX;
    int nY;
    double *data;
};

void mallocMatrix2D(struct Matrix2D *m, int nX, int nY) {
    m->nX = nX;
    m->nY = nY;
    m->data = (double*) malloc(nY * nX * sizeof(double));
}

void freeMatrix2D(struct Matrix2D *m) {
    free(m->data);
}

struct Matrix3D {
    int nX;
    int nY;
    int nZ;
    double *data;
};

void mallocMatrix3D(struct Matrix3D *m, int nX, int nY, int nZ) {
    m->nX = nX;
    m->nY = nY;
    m->nZ = nZ;
    m->data = (double*) malloc(nZ * nY * nX * sizeof(double));    
}

void freeMatrix3D(struct Matrix3D *m) {
    free(m->data);
}


int estimateFlow2(double*    Dx,        // 1
                  double*    Dy,        // 2
                  double*    Img1,      // 3
                  double*    Img2,      // 4
                  int        nX,        // 5
                  int        nY,        // 6
                  int        nLevel,    // 7
                  double     sFactor,   // 8
                  int        nWarp,     // 9
                  int        nIter,     // 10
                  double     lambda) {  // 11
    // Compute the size of images within the pyramid.
    int iLevel, nAll, nYi, nXi, nP, iP, nMin, iData, nData;
    //double *Img1i, *Img2i, *Img1p, *Img2p, *Dt, *P, *DxTmp, *DyTmp, *DtTmp, *PTmp;
    //double *Dt, *P;
    double scale, sX, sY;
    //double *Img1iTmp; // for debugging.
    struct Matrix2D *images1, *images2, *dx, *dy, *dt;
    struct Matrix3D *p;
    
    int dim1P[3]    = {0, 0, 0};
    int dim2P[3]    = {0, 0, 0};
    int order1[3]   = {1, 2, 0};
    int order2[3]   = {2, 0, 1};
    
    nMin    = MIN(nX, nY);
    
    if (nMin < 16) {
        return -1;
    }
    
    nLevel  = MIN(nLevel, 1+(int)ceil(log(16.0/nMin)/log(sFactor)));
    scale   = sFactor;
    nAll    = 0;
    nP      = 6;
    
    images1 = (struct Matrix2D*) malloc(nLevel * sizeof(struct Matrix2D));
    images2 = (struct Matrix2D*) malloc(nLevel * sizeof(struct Matrix2D));
    dx      = (struct Matrix2D*) malloc(nLevel * sizeof(struct Matrix2D));
    dy      = (struct Matrix2D*) malloc(nLevel * sizeof(struct Matrix2D));
    dt      = (struct Matrix2D*) malloc(nLevel * sizeof(struct Matrix2D));
    p       = (struct Matrix3D*) malloc(nLevel * sizeof(struct Matrix3D));
    
    
    // Initialize the image pyramid.
    mallocMatrix2D(&images1[0], nX, nY);
    memcpy(images1[0].data, Img1, nY * nX * sizeof(double));
    
    mallocMatrix2D(&images2[0], nX, nY);
    memcpy(images2[0].data, Img2, nY * nX * sizeof(double));
    
    mallocMatrix2D(&dx[0], nX, nY);
    mallocMatrix2D(&dy[0], nX, nY);
    mallocMatrix2D(&dt[0], nX, nY);
    
    mallocMatrix3D(&p[0], nX, nY, nP);    
    
    // Initialize nXi and nYi for level 0 of the pyramid.
    nXi = nX;
    nYi = nY;
    
    for (iLevel = 1; iLevel < nLevel; ++iLevel) {
        nXi = round(nX*scale);
        nYi = round(nY*scale);
        mallocMatrix2D(&images1[iLevel], nXi, nYi);
        mallocMatrix2D(&images2[iLevel], nXi, nYi);
        
        imresize2(images1[iLevel].data,    // to
                  images1[iLevel-1].data,  // from
                  images1[iLevel-1].nX,    // from x-size
                  images1[iLevel-1].nY,    // from y-size
                  nXi, nYi, "cubic");      // to x/y-size
        
        imresize2(images2[iLevel].data,    // to
                  images2[iLevel-1].data,  // from
                  images2[iLevel-1].nX,    // from x-size
                  images2[iLevel-1].nY,    // from y-size
                  nXi, nYi, "cubic");      // to x/y-size
        
        scale *= sFactor;
        
        // Initialize the memory of the other fields.
        mallocMatrix2D(&dx[iLevel], nXi, nYi);
        mallocMatrix2D(&dy[iLevel], nXi, nYi);
        mallocMatrix2D(&dt[iLevel], nXi, nYi);
        mallocMatrix3D(&p[iLevel], nXi, nYi, nP);
    }
    
    /*
    for (iLevel = 0; iLevel < nLevel; ++iLevel) {
        printf("Size nX = %d, nY = %d, data = %p.\n",
                dx[iLevel].nX,
                dx[iLevel].nY,
                dx[iLevel].data);
    }    
    printf("Size nXi = %d, nYi = %d.\n", nXi, nYi);
    */
    
    // Initialize the esimates of optic flow.
    nData = nXi * nYi;
    for (iData = 0; iData < nData; ++iData) {
        dx[nLevel-1].data[iData] = 0.0;
        dy[nLevel-1].data[iData] = 0.0;
        dt[nLevel-1].data[iData] = 0.0;
    }    
    nData = nXi * nYi * nP;
    for (iData = 0; iData < nData; ++iData) {
        p[nLevel-1].data[iData] = 0.0;
    }
    
    //printf("images1[%d] = \n\n", nLevel-1);
    //printDoubleMatrix(images1[nLevel-1].data, nXi, nYi);
    
    tvL1PrimalDual2(dx[nLevel-1].data,      // 1 inplace modification, nY x nX
                    dy[nLevel-1].data,      // 2 inplace modification, nY x nX
                    dt[nLevel-1].data,      // 3 inplace modification, nY x nX
                    p[nLevel-1].data,       // 4 inplace modification nP x nY x nX
                    images1[nLevel-1].data, // 5 First image, nY x nX.
                    images2[nLevel-1].data, // 6 Second image, nY x nX.
                    nXi,                    // 7 Number of columns.
                    nYi,                    // 8 Number of rows.
                    nP,                     // 9 Number of parameters.
                    lambda,                 // 10 Parameter.
                    nWarp,                  // 11 Number of warps.
                    nIter);                 // 12 Number of iterations.
    
    //printf("Dx = \n\n");
    //printDoubleMatrix(dx[nLevel-1].data, nXi, nYi);
    
    
    for (iLevel = nLevel-2; iLevel >= 0; --iLevel) {
        nXi = dx[iLevel].nX;
        nYi = dy[iLevel].nY;
        
        //printf("Working on level %d with size nXi = %d and nYi = %d.\n", iLevel, nXi, nYi);
        
        // Map the solution to the next finer level.
        imresize2(  dx[iLevel].data, 
                    dx[iLevel+1].data, 
                    dx[iLevel+1].nX, 
                    dx[iLevel+1].nY, 
                    nXi, nYi, "nearest"); // This imresize is the problem.
        imresize2(  dy[iLevel].data, 
                    dy[iLevel+1].data, 
                    dy[iLevel+1].nX, 
                    dy[iLevel+1].nY, 
                    nXi, nYi, "nearest");
        imresize2(  dt[iLevel].data, 
                    dt[iLevel+1].data, 
                    dt[iLevel+1].nX, 
                    dt[iLevel+1].nY, 
                    nXi, nYi, "nearest");        
        //printf("Level %d.\n", iLevel);
        //printf("Dx = \n\n");
        //printDoubleMatrix(Dx, nXi, nYi);
        
        sY = ((double)nYi)/dx[iLevel+1].nY;
        sX = ((double)nXi)/dx[iLevel+1].nX;
        for (iData = 0; iData < nXi*nYi; ++iData) {
            dx[iLevel].data[iData] *= sX;
            dy[iLevel].data[iData] *= sY;
        }
        
        
        dim1P[0] = nP;      dim1P[1] = p[iLevel+1].nY;  dim1P[2] = p[iLevel+1].nX;
        dim2P[0] = nYi;     dim2P[1] = nXi;             dim2P[2] = nP;
        permuteN(p[iLevel+1].data, dim1P, order1, 3);
        for (iP = 0; iP < nP; ++iP) {
            imresize2(  p[iLevel].data + iP*nXi*nYi, 
                        p[iLevel+1].data + iP*p[iLevel+1].nX*p[iLevel+1].nY,
                        p[iLevel+1].nX, p[iLevel+1].nY,
                        nXi, nYi, "nearest");
        }
        permuteN(p[iLevel].data, dim2P, order2, 3);
        
        
        tvL1PrimalDual2(dx[iLevel].data,        // 1 inplace modification, nY x nX
                        dy[iLevel].data,        // 2 inplace modification, nY x nX
                        dt[iLevel].data,        // 3 inplace modification, nY x nX
                        p[iLevel].data,         // 4 inplace modification nP x nY x nX
                        images1[iLevel].data,   // 5 First image, nY x nX.
                        images2[iLevel].data,   // 6 Second image, nY x nX.
                        nXi,                    // 7 Number of columns.
                        nYi,                    // 8 Number of rows.
                        nP,                     // 9 Number of parameters.
                        lambda,                 // 10 Parameter.
                        nWarp,                  // 11 Number of warps.
                        nIter);                 // 12 Number of iterations.         
    }
    
    memcpy(Dx, dx[0].data, nX * nY * sizeof(double));
    memcpy(Dy, dy[0].data, nX * nY * sizeof(double));   
    
    // cleanup the images.
    for (iLevel = nLevel-1; iLevel >= 0; --iLevel) {
        freeMatrix3D(&p[iLevel]);
        freeMatrix2D(&dt[iLevel]);
        freeMatrix2D(&dy[iLevel]);
        freeMatrix2D(&dx[iLevel]);
        freeMatrix2D(&images2[iLevel]);
        freeMatrix2D(&images1[iLevel]);
    }
    free(p);
    free(dt);
    free(dy);
    free(dx);
    free(images2);
    free(images1);
    
    return 0;
}
