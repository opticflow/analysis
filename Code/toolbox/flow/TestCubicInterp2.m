clc; clear all; close all;

%   Florian Raudies, 01/05/2015, Palo Alto, CA.

% Compile the c function.
mex -v cubicInterp2.c imagelib.c

% Setup and run the test cases.
th          = 10^4*eps;
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
    [Y, X]  = ndgrid(linspace(-1,1,nInY), linspace(-1,1,nInX));    
    Data    = randn(nInY,nInX);
    fprintf('Testing input size: %d x %d.\n', nInY, nInX);
    for iNumOutXY = 1:nNumOutXY,
        nOutY       = NumOutY(iNumOutXY);
        nOutX       = NumOutX(iNumOutXY);
        [Yi, Xi]    = ndgrid(linspace(-1.1,1.1,nOutY), linspace(-1,1,nOutX));
        Xi          = Xi + randn(size(Xi));
        Yi          = Yi + randn(size(Yi));

        fprintf('Testing output size: %d x %d.\n', nOutY, nOutX);
        
        try
            Is          = cubicInterp2(X,Y,Data,Xi,Yi);
            ShouldBe    = interp2(X,Y,Data,Xi,Yi,'cubic');
            Difference  = abs(ShouldBe-Is);
            [~, index]  = max(Difference(:));
            [iRow iCol] = ind2sub([nOutY nOutX],index);
            difference  = max(max(abs(ShouldBe-Is)));
            
            % If all values are NaN than the difference is 0.
            if all(all(isnan(ShouldBe))) && all(all(isnan(Is))), 
                difference = 0;
            end
            
            fprintf('    Maximum difference: %e < %e?\n', difference, th);
            fprintf('    At row = %d and column = %d.\n', iRow, iCol);

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

% Notice, that in this case encountering one error is correct. This error
% is caused by a too small input size.
assert(nFailed==0 && nError==12,'%d tests failed. Found %d errors.\n',...
    nFailed,nError);

% ALL PASSED 01/05/2016 FR