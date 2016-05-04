clc; clear all; close all;
%   Florian Raudies, 01/09/2016, Palo Alto, CA.

% Compile the c functions.
mex -v tvL1PrimalDual2.c flowlib.c imagelib.c

% Define threshold, image size, velocity, and image pair.
th      = 10^9*eps;
nY      = 7;
nX      = 5;
nP      = 6;
I1      = rand(nY,nX);
I2      = rand(nY,nX);
Dx      = randn(nY,nX);
Dy      = randn(nY,nX);
Dt      = randn(nY,nX);
P       = randn(nP,nY,nX);
lambda  = 1;
nWarp   = 5;
nIter   = 50;

fprintf('Testing tvL1PrimalDual2.\n');
fprintf(' Calculate in c.\n');
[DxIs, DyIs, DtIs, PIs] = tvL1PrimalDual2(I1, I2, Dx, Dy, Dt, P, ...
                                          lambda, nWarp, nIter);
fprintf(' Calculate in Matlab.\n');
[DxShouldBe, DyShouldBe, DtShouldBe, PShouldBe] = tvL1PrimalDual2Matlab( ...
    I1, I2, Dx, Dy, Dt, P, lambda, nWarp, nIter);

differenceDx = max(max(abs(DxShouldBe-DxIs)));
fprintf(' The difference for Dx in tvL1PrimalDual2 is %e.\n', differenceDx);

differenceDy = max(max(abs(DyShouldBe-DyIs)));
fprintf(' The difference for Dy in tvL1PrimalDual2 is %e.\n', differenceDy);

differenceDt = max(max(abs(DtShouldBe-DtIs)));
fprintf(' The difference for Dt in tvL1PrimalDual2 is %e.\n', differenceDt);

assert(differenceDx<th || differenceDy<th || differenceDt<th, 'Test FAILED!');
fprintf('  Test PASSED!\n');
