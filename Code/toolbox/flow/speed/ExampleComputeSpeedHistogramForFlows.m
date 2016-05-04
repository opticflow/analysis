clc; clear all; close all;
% Example for the method 'computeSpeedHistogramForFlows'.
%   Florian Raudies, 01/17/2016, Palo Alto, CA.

hstDir          = '../Data/SleepingBag/Histogram/';
hstFile         = [hstDir, 'Histogram.mat'];
flwDir          = '../Data/SleepingBag/Flow/';
flwFile         = [flwDir, 'Flw%05d.mat'];
nFrame          = nFileFilter(flwDir, 'mat');
mkdir(hstDir);
opt.aperture    = 'Circular';
opt.fps         = 59.94;
opt.hFoV        = 170/180*pi;
info = computeSpeedHistogramForFlows(flwFile, 1, nFrame, hstFile, opt);
fprintf('Computed histogram of flow speeds for %d frames each %d x %d pixels.\n',...
    info.nFrame,info.nX,info.nY);
fprintf('Computation took %2.2f minutes, %2.2f hours, or %2.2f days.\n',...
    info.excTimeInM,info.excTimeInH,info.excTimeInD);
