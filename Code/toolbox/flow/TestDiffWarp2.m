clc; clear all; close all;
%   Florian Raudies, 12/29/2015, Palo Alto, CA.

% Compile the c functions
mex -v diffWarp2.c imagelib.c

th      = eps*10^3;
NumY    = [1 3 4 15 22 35 340];
NumX    = [1 3 7 13 22 22 240];
nNumXY  = length(NumY);
nPassed = 0;
nFailed = 0;
nError  = 0;
for iNumXY = 1:nNumXY,
    nY = NumY(iNumXY);
    nX = NumX(iNumXY);
    fprintf('Testing image size: %d x %d.\n', nY, nX);
    I1 = rand(nY,nX);
    I2 = rand(nY,nX);
    Dx = randn(nY,nX);
    Dy = randn(nY,nX);
    try
        [IxIs, IyIs, ItIs] = diffWarp2(I1, I2, Dx, Dy);
        [IxShouldBe, IyShouldBe, ItShouldBe] = diffWarp2Matlab(I1, I2, Dx, Dy);
        differenceIx = max(max(abs(IxShouldBe-IxIs)));
        differenceIy = max(max(abs(IyShouldBe-IyIs)));
        differenceIt = max(max(abs(ItShouldBe-ItIs)));
        fprintf('  Maximum difference for Ix: %e < %e?\n', differenceIx, th);
        fprintf('  Maximum difference for Iy: %e < %e?\n', differenceIy, th);
        fprintf('  Maximum difference for It: %e < %e?\n', differenceIt, th);
        if (differenceIx<th && differenceIy<th && differenceIt<th),
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
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);

% Notice, that in this case encountering one error is correct. This error
% is caused by a too small input size.
assert(nFailed==0 && nError==1,'%d tests failed. Found %d errors.\n',...
    nFailed,nError);

% ALL PASSED 01/05/2016 FR