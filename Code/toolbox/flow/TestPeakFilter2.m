clc; clear all; close all;
%   Florian Raudies, 12/29/2015, Palo Alto, CA.

% Compile the c functions.
mex -v peakFilter2.c imagelib.c

% Setup and run the test cases.
th          = eps;
NumY        = [1 3 1 14 25 35 320];
NumX        = [1 1 4 5 22 45 240];
nNumXY      = length(NumY);
nPassed     = 0;
nFailed     = 0;
for iNumXY = 1:nNumXY,
    nY  = NumY(iNumXY);
    nX  = NumX(iNumXY);
    X   = randn(nY,nX);
    fprintf('Testing image size: %d x %d.\n', nY, nX);
    ShouldBe    = peakFilter2Matlab(X);
    Is          = peakFilter2(X);
    difference  = max(max(abs(ShouldBe-Is)));
    fprintf('  Maximum difference: %e < %e?\n', difference, th);

    if (difference<th),
        nPassed = nPassed + 1;
        fprintf('  Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('  Test FAILED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/07/2016 FR