clc; clear all; close all;
% Example for the usage of the method 'computeFlowForImages'.
%   Florian Raudies, 01/17/2016, Palo Alto, CA.

imgDir      = '../Data/SleepingBag/Image/';
flwDir      = '../Data/SleepingBag/Flow/';
imgFile     = [imgDir, 'Img%05d.png'];
flwFile     = [flwDir, 'Flw%05d.mat'];
nFrame      = nFileFilter(imgDir, 'png');
mkdir(flwDir);
opt.ScaleOrSize = 0.25;
opt.verbose = 1;
info        = computeFlowForImages(imgFile, 1, nFrame, flwFile, opt);

fprintf('The computation of %d frames at size %d x %d pixels took:\n',...
    info.nFrame,info.nX,info.nY);
fprintf('  %2.2f minutes.\n',info.excTimeInM);
fprintf('  %2.2f hours.\n',info.excTimeInH);
fprintf('  %2.2f days.\n',info.excTimeInD);
