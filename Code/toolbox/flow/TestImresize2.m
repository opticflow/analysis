clc; clear all; close all;
%   Florian Raudies, 01/07/2016, Palo Alto, CA.

% Compile the c function.
mex -v imresize2.c imagelib.c

% Setup and run the test cases.
th          = 10^3*eps;
NumInY      = [1 3 1 14 25 35 320];
NumInX      = [1 1 4 5 22 45 240];
NumOutY     = [5 12 55 251];
NumOutX     = [2 12 60 300];
InterpType  = {'cubic', 'nearest'};
nNumInXY    = length(NumInY);
nNumOutXY   = length(NumOutY);
nInterpType = length(InterpType);
nPassed     = 0;
nFailed     = 0;
nError      = 0;
for iNumInXY = 1:nNumInXY,
    nInY    = NumInY(iNumInXY);
    nInX    = NumInX(iNumInXY);
    Data    = randn(nInY,nInX);
    fprintf('Testing input size: %d x %d.\n', nInY, nInX);
    for iNumOutXY = 1:nNumOutXY,
        nOutY = NumOutY(iNumOutXY);
        nOutX = NumOutX(iNumOutXY);
        I = [nOutY nOutX];
        fprintf('Testing output size: %d x %d.\n', nOutY, nOutX);
        for iInterpType = 1:nInterpType,
            interpType  = InterpType{iInterpType};
            fprintf('  Testing interpolation type: %s.\n', interpType);
            
            try
                Is = imresize2(Data,I,interpType);
                ShouldBe = imresize(Data,I,interpType);
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
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0 && nError==12,'%d tests failed and %d errors occured.\n',nFailed,nError);

% ALL PASSED 01/07/2016 FR