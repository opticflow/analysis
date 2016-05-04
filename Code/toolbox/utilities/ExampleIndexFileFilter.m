clc; clear all; close all;
% Example on how to use the method: 'indexFileFilter'.
%   Florian Raudies, 01/17/2016, Palo Alto, CA.

dirPath         = '../Data/SleepingBag/Image/';
fileNamePattern = 'Img%05d.png';
IndexForSegment = indexFileFilter(dirPath, fileNamePattern)