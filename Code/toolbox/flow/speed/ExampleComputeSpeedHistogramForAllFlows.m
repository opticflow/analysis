clc; clear all; close all;
% Example for the method 'computeSpeedHistogramForFlows'.
%   Florian Raudies, 02/11/2016, Palo Alto, CA.

hstDir          = '../Data/SleepingBag/Histogram/';
hstFile         = [hstDir, 'Histogram.mat'];
flwFile         = '../Data/SleepingBag/Flow/Flw%05d.mat';
mkdir(hstDir);
opt.aperture    = 'Circular';
opt.verbose     = 1;
opt.fps         = 59.94;
opt.hFoV        = 170/180*pi;
info = computeSpeedHistogramForAllFlows(flwFile, hstFile, opt);
fprintf('Computed histogram of flow speeds for %d frames each %d x %d pixels.\n',...
    info.nFrame,info.nX,info.nY);
fprintf('Computation took %2.2f minutes, %2.2f hours, or %2.2f days.\n',...
    info.excTimeInM,info.excTimeInH,info.excTimeInD);
