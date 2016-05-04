clc; clear all; close all;

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

NumY        = [60 120 240 480 960];
NumX        = [80 160 320 640 1280];
nNum        = length(NumX);
ElapsedTime = zeros(nNum,2);
Vel         = [3 2];
opt.nLevel  = 50;
opt.sFactor = 0.9;
opt.nWarp   = 1;
opt.nIter   = 50;
opt.lambda  = 50;

for iNum = 1:nNum,
    nY      = NumY(iNum);
    nX      = NumX(iNum);
    Img1    = rand(nY,nX);
    Img1    = imfilter(Img1, fspecial('gaussian',[9 9],9/4), 'same', 'replicate');
    Img2    = circshift(Img1, Vel);
    
    fprintf('Measuring performance for %d x %d resoltuion.\n',nX,nY);
    fprintf(' Timing c method.\n');
    t0 = tic;
    [DxIs, DyIs] = estimateFlow2(Img1, Img2, opt);
    ElapsedTime(iNum,1) = toc(t0);
    fprintf(' Timing Matlab method.\n');
    t0 = tic;
    [DxShouldBe, DyShouldBe] = estimateFlow2Matlab(Img1, Img2, opt);
    ElapsedTime(iNum,2) = toc(t0);
    fprintf(' Comparing results.\n');
    differenceDx = max(max(abs(DxShouldBe-DxIs)));
    differenceDy = max(max(abs(DyShouldBe-DyIs)));
    fprintf(' Dx difference = %e.\n', differenceDx);
    fprintf(' Dy difference = %e.\n', differenceDy);
end
SpeedUp = ElapsedTime(:,2)./ElapsedTime(:,1);

ElapsedTime'
SpeedUp'

save('PerfEstiamteFlow2','ElapsedTime','SpeedUp');
