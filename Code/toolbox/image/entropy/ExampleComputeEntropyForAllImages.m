clc; clear all; close all;
% Example for the method 'computeEntropyForAllImages'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

imgDir      = '../Data/SleepingBag/Image/';
imgFile     = [imgDir, 'Img%05d.png'];
entropyDir  = [imgDir, 'Entropy/'];
entropyFile = [entropyDir, 'Entropy.mat'];

mkdir(entropyDir);
opt.ScaleOrSize = 0.25;
info        = computeEntropyForAllImages(imgFile, entropyFile, opt);
fprintf('Computed entropy for %d images each %d x %d pixels.\n',...
    info.nFrame,info.nX,info.nY);
fprintf('Computation took %2.2f minutes, %2.2f hours, or %2.2f days.\n',...
    info.excTimeInM,info.excTimeInH,info.excTimeInD);
