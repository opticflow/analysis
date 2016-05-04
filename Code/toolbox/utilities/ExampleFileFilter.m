clc; clear all; close all;
% Example for the method 'fileFilter'.
%   Florian Raudies, 01/19/2016, Palo Alto, CA.

dirPath = '../Data/SleepingBag/';
Videos  = fileFilter(dirPath, 'MP4');
nVideos = length(Videos);
fprintf('The folder %s contains the video files.\n', dirPath);
for iVideos = 1:nVideos, fprintf('\t%s.\n', Videos{iVideos}); end
