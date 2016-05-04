clc; clear all; close all;
%   Florian Raudies, 12/29/2015, Palo Alto, CA.

% Compile the c function.
mex -v imfilter2.c imagelib.c

% Setup and run the test cases.
th          = 10^3*eps;
NumY        = [1 3 1 14 25 35 320];
NumX        = [1 1 4 5 22 45 240];
NumKy       = [1 2 3 5 15];
NumKx       = [1 1 2 4 13];
Boundary    = {'circular', 'replicate', 'same'};
nNumXY      = length(NumY);
nNumKXY     = length(NumKy);
nBoundary   = length(Boundary);
nPassed     = 0;
nFailed     = 0;
for iNumXY = 1:nNumXY,
    nY  = NumY(iNumXY);
    nX  = NumX(iNumXY);
    X   = randn(nY,nX);
    fprintf('Testing image size: %d x %d.\n', nY, nX);
    for iNumKXY = 1:nNumKXY,
        nKy = NumKy(iNumKXY);
        nKx = NumKx(iNumKXY);
        K   = randn(nKy,nKx);
        fprintf('  Testing kernel size: %d x %d.\n', nKy, nKx);
        for iBoundary = 1:nBoundary,
            boundary = Boundary{iBoundary};
            fprintf('    Testing boundary condition: %s.\n', boundary);
            ShouldBe    = imfilter(X,K,boundary);
            Is          = imfilter2(X,K,boundary);
            difference  = max(max(abs(ShouldBe-Is)));
            fprintf('      Maximum difference: %e < %e?\n', difference, th);
            
            if (difference<th),
                nPassed = nPassed + 1;
                fprintf('      Test PASSED!\n');
            else
                nFailed = nFailed + 1;
                fprintf('      Test FAILED!\n');
            end
        end
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/07/2016 FR