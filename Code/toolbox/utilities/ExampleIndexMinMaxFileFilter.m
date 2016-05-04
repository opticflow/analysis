clc; clear all; close all;
% Example for the method 'indexMinMaxFileFilter'.
%   Florian Raudies, 01/19/2016, Palo Alto, CA.

dirPath         = '../Data/SleepingBag/Image/';
fileNamePattern = 'Img%05d.png';
[iMin, iMax]    = indexMinMaxFileFilter(dirPath, fileNamePattern);
fprintf('Minimum %d and maximum %d file index for images in folder %s.\n', ...
    iMin, iMax, dirPath);
