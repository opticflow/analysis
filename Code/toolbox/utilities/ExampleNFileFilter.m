clc; clear all; close all;
% Example for the method 'fileFilter'.
%   Florian Raudies, 01/19/2016, Palo Alto, CA.

dirPath     = '../Data/SleepingBag/';
fileSuffix  = 'MP4';
nVideos     = nFileFilter(dirPath, fileSuffix);
fprintf('The folder %s contains %d video file(s) with file extension %s.\n', ...
    dirPath, nVideos, fileSuffix);
