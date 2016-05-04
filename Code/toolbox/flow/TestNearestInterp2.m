clc; clear all; close all;

%   Florian Raudies, 01/05/2015, Palo Alto, CA.

% Compile the c function.
mex -v nearestInterp2.c imagelib.c

% Setup and run the test cases.
th          = 10^3*eps;
NumInY      = [1 3 1 14 25 35 320];
NumInX      = [1 1 4 5 22 45 240];
NumOutY     = [5 12 55 251];
NumOutX     = [2 12 60 300];
nNumInXY    = length(NumInY);
nNumOutXY   = length(NumOutY);
nPassed     = 0;
nFailed     = 0;
nError      = 0;
for iNumInXY = 1:nNumInXY,
    nInY    = NumInY(iNumInXY);
    nInX    = NumInX(iNumInXY);
    Y       = linspace(-1,1,nInY)';
    X       = linspace(-1,1,nInX)';
    Data    = randn(nInY,nInX);
    fprintf('Testing input size: %d x %d.\n', nInY, nInX);
    for iNumOutXY = 1:nNumOutXY,
        nOutY = NumOutY(iNumOutXY);
        nOutX = NumOutX(iNumOutXY);
        Yi = linspace(-1.1,1.1,nOutY)';
        Xi = linspace(-1,1,nOutX)';
        fprintf('Testing output size: %d x %d.\n', nOutY, nOutX);
        
        try
            Is = nearestInterp2(X,Y,Data,Xi,Yi);
            [Yi,Xi] = ndgrid(Yi,Xi);
            ShouldBe = interp2(X,Y,Data,Xi,Yi,'nearest');

            difference  = max(max(abs(ShouldBe-Is)));
            fprintf('    Maximum difference: %e < %e?\n', difference, th);

            if (difference<th),
                nPassed = nPassed + 1;
                fprintf('    Test PASSED!\n');
            else
                nFailed = nFailed + 1;
                fprintf('    Test FAILED!\n');
            end
        catch err
            nError = nError + 1;
            fprintf('Error: %s\nContinue testing.\n', err.message);            
        end
    end    
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/05/2016 FR