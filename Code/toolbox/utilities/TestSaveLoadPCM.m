clc; clear all; close all;
% This test excersises the save/load methods using the PCM file format.
%
%   Florian Raudies, 01/10/2016, Palo Alto, CA.
inOutFile   = '../../../Data/Tmp/TestData.pcm';
th          = 10*eps('single');
NumY        = [1 1 5 125 215 512];
NumX        = [1 6 8 100 300 512];
nNum        = length(NumY);
nFailed     = 0;
nPassed     = 0;
fprintf('Testing save/load method using a mat file.\n');
for iNum = 1:nNum,
    nY          = NumY(iNum);
    nX          = NumX(iNum);    
    XShouldBe   = randn(nY, nX);
    YShouldBe   = randn(nY, nX);
    
    fprintf(' Test image size %d x %d.\n', nY, nX);
    savePCM(XShouldBe, YShouldBe, inOutFile, 'l');
    [XIs, YIs] = loadPCM(inOutFile, 'l');

    differenceX = max(max(abs(XShouldBe-XIs)));
    fprintf(' Maximum X difference %e < %e?\n', differenceX, th);

    differenceY = max(max(abs(YShouldBe-YIs)));
    fprintf(' Maximum Y difference %e < %e?\n', differenceY, th);
    
    if (differenceX<th || differenceY<th),
        nPassed = nPassed + 1;
        fprintf('  Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('  Test FAILED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/12/2016 FR