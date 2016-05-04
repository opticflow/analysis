clc; clear all; close all;

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

th      = 10^10*eps; % tolerance threshold
dataDir = '../../Data/YosemiteWithClouds/';
Img1    = double(imread([dataDir,'Img00000.pgm']))/255;
Img2    = double(imread([dataDir,'Img00001.pgm']))/255;
opt     = struct();

[DxIs, DyIs] = computeFlow2(Img1, Img2, opt);
[DxShouldBe, DyShouldBe] = computeFlow2Matlab(Img1, Img2, opt);

differenceDx = max(max(abs(DxShouldBe-DxIs)));
fprintf('  Maximum Dx difference %e < %e?\n', differenceDx, th);

differenceDy = max(max(abs(DyShouldBe-DyIs)));
fprintf('  Maximum Dy difference %e < %e?\n', differenceDy, th);

if(differenceDx<th || differenceDy<th), 
    fprintf('  Test PASSED!\n');
else
    fprintf('  Test FAILED!\n');
end

ImgIs       = flowToImage(DxIs,DyIs);
ImgShouldBe = flowToImage(DxShouldBe,DyShouldBe);

figure('Position',[0 50 1400 500]);
subplot(1,2,1); imagesc(ImgIs); title('Optic flow is');
subplot(1,2,2); imagesc(ImgShouldBe); title('Optic flow should be');
