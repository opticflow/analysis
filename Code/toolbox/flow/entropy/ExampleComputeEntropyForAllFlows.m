clc; clear all; close all;
% Example for the method 'computeEntropyForAllFlows'.
%   Florian Raudies, 01/19/2016, Palo Alto, CA.

flwDir          = '../Data/SleepingBag/Flow/';
flwFile         = [flwDir, 'Flw%05d.mat'];
entropyDir      = [flwDir, 'Entropy/'];
entropyFile     = [entropyDir, 'Entropy.mat'];
mkdir(entropyDir);
info = computeEntropyForAllFlows(flwFile, entropyFile, struct());
fprintf('Computed entropy for flow for %d frames each %d x %d pixels.\n',...
    info.nFrame,info.nX,info.nY);
fprintf('Computation took %2.2f minutes, %2.2f hours, or %2.2f days.\n',...
    info.excTimeInM,info.excTimeInH,info.excTimeInD);
