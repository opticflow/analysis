#ifndef imagelib_h
#define imagelib_h

#include <math.h>
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

// Define some constants used in tvL1PrimalDual2.
static const double TAU      = 3.535534e-001; // = 1.0/sqrt(8.0);
static const double SIGMA    = 3.535534e-001; // = 1.0/sqrt(8.0);
static const double EPS_XY   = 0.0;
static const double EPS_T    = 0.0;
static const double GAMMA    = 0.02;
static const double GAMMA2   = 0.02 * 0.02;

void tvL1PrimalDual2(double* Dx,    // 1 inplace modification, nY x nX
                     double* Dy,    // 2 inplace modification, nY x nX
                     double* Dt,    // 3 inplace modification, nY x nX
                     double* P,     // 4 inplace modification 6 x nY x nX
                     double* I1,    // 5 First image, nY x nX.
                     double* I2,    // 6 Second image, nY x nX.
                     int nX,        // 7 Number of columns.
                     int nY,        // 8 Number of rows.
                     int nP,        // 9 Number of parameters.
                     double lambda, // 10 Parameter.
                     int nWarp,     // 11 Number of warps.
                     int nIter);    // 12 Number of iterations.

int estimateFlow2(double*    Dx,     // 1
                  double*    Dy,     // 2
                  double*    Img1,   // 3
                  double*    Img2,   // 4
                  int        nX,     // 5
                  int        nY,     // 6
                  int        nLevel, // 7
                  double     sFactor,// 8
                  int        nWarp,  // 9
                  int        nIter,  // 10
                  double     lambda);// 11

#endif