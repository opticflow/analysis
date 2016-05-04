clc; clear all; close all;
% Example for the method 'computeEntropyForImage'.
%   Florian Raudies, 01/24/2016, Palo Alto, CA.

imgFile     = sprintf('../Data/SleepingBag/Image/Img%05d.png',1);
Img         = rgb2gray(imread(imgFile));
opt.nBin    = 256;
nCase       = 4;

figure;
for iCase = 1:nCase,
    subplot(2,2,iCase);
    opt.ScaleOrSize = 1/4^(iCase-1);
    [e, opt] = computeEntropyForImage(Img, opt);
    imshow(imresize(Img,opt.ScaleOrSize));
    title(sprintf('%s\nfor size %d x %d pixels\nand the entropy of %2.2f bits.',...
        imgFile, opt.nY, opt.nX, e));
end
