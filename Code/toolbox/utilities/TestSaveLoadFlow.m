clc; clear all; close all;
% Test cases for saveFlow/loadFlow method which excersises the save/load
% mechanism using Matlab files and using PCM files.
%
%   Florian Raudies, 01/10/2016, Palo Alto, CA.
inOutFile   = '../../../Data/Tmp/TestFlow';
NumY        = [1 1 5 125 215 512];
NumX        = [1 6 8 100 300 512];
nNum        = length(NumY);
nFailed     = 0;
nPassed     = 0;
fprintf('Testing save/load method using a mat file.\n');
for iNum = 1:nNum,
    nY          = NumY(iNum);
    nX          = NumX(iNum);    
    DxShouldBe  = randn(nY, nX);
    DyShouldBe  = randn(nY, nX);
    fprintf(' Test image size %d x %d.\n', nY, nX);
    
    fprintf('  Testing save/load method using a mat file.\n');
    th = eps('double');
    
    saveFlow(DxShouldBe, DyShouldBe, inOutFile);
    [DxIs, DyIs] = loadFlow(inOutFile);

    differenceDx = max(max(abs(DxShouldBe-DxIs)));
    fprintf('   Maximum Dx difference %e < %e?\n', differenceDx, th);

    differenceDy = max(max(abs(DyShouldBe-DyIs)));
    fprintf('   Maximum Dy difference %e < %e?\n', differenceDy, th);

    if (differenceDx<th || differenceDy<th),
        nPassed = nPassed + 1;
        fprintf('   Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('   Test FAILED!\n');
    end
    
    
    fprintf('  Testing save/load method using a pcm file.\n');
    th = 10*eps('single');
    
    saveFlow(DxShouldBe, DyShouldBe, [inOutFile, '.pcm']);
    [DxIs, DyIs] = loadFlow([inOutFile, '.pcm']);

    differenceDx = max(max(abs(DxShouldBe-DxIs)));
    fprintf('   Maximum Dx difference %e < %e?\n', differenceDx, th);

    differenceDy = max(max(abs(DyShouldBe-DyIs)));
    fprintf('   Maximum Dy difference %e < %e?\n', differenceDy, th);
    
    if (differenceDx<th || differenceDy<th),
        nPassed = nPassed + 1;
        fprintf('   Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('   Test FAILED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/12/2016 FR