clc; clear all; close all;
% Example for the usage of the method 'computeFlowForImages'.
%   Florian Raudies, 01/17/2016, Palo Alto, CA.

imgFile     = '../Data/SleepingBag/Image/Img%05d.png';
flwDir      = '../Data/SleepingBag/Flow/';
flwFile     = [flwDir, 'Flw%05d.mat'];
mkdir(flwDir);
opt.ScaleOrSize = 0.25;
opt.verbose     = 1;
info            = computeFlowForAllImages(imgFile, flwFile, opt);

fprintf('The computation of %d frames at size %d x %d pixels took:\n',...
    info.nFrame,info.nX,info.nY);
fprintf('  %2.2f minutes.\n',info.excTimeInM);
fprintf('  %2.2f hours.\n',info.excTimeInH);
fprintf('  %2.2f days.\n',info.excTimeInD);
