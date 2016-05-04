clc; clear all; close all
% Example for the usage of 'getVideoInfo' and all classes used within.
%   Florian Raudies, 01/16/2016, Palo Alto, CA.
%
fileName    = '../Data/SleepingBag/SleepingBag.MP4';
videoInfo   = getVideoInfo(fileName);
fileName    = videoInfo.getFileName();          % filename
duration    = videoInfo.getDuration();          % sec
fps         = videoInfo.getFramesPerSecond();   % fps
R           = videoInfo.getResolution();        % width x height in pixels

fprintf('The video %s has the:\n', fileName);
fprintf(' - resolution [%d x %d]\n', R(1), R(2));
fprintf(' - duration %2.5f sec\n', duration);
fprintf(' - fps %2.3f frames/second\n', fps);
