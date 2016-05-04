clc; clear all; close all;
% Example for the method 'patternMatchForFlows'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

flwDir  = '../Data/SleepingBag/Flow/';
flwFile = [flwDir, 'Flw%05d.mat'];
patDir  = '../Data/SleepingBag/Pattern/';
patFile = [patDir, 'Pattern.mat'];
mkdir(patDir);
nFrame  = nFileFilter(flwDir, 'mat');
info    = computePatternMatchForFlows(flwFile, 1, nFrame, patFile, struct());
fprintf('Computed flow pattern matches for %d frames each %d x %d pixels.\n',...
    info.nFrame,info.nX,info.nY);
fprintf('Computation took %2.2f minutes, %2.2f hours, or %2.2f days.\n',...
    info.excTimeInM,info.excTimeInH,info.excTimeInD);
