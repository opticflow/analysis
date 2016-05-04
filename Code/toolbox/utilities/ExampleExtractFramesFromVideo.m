clc; clear all; close all;
% Tests the extraction of frames from a video file exercising the method
% extractFramesFromVideo.
%   Florian Raudies, 01/16/2016, Palo Alto, CA.

maxStorage  = 2; % GBy
videoFile   = '../Data/SleepingBag/SleepingBag.MP4';
outDir      = '../Data/SleepingBag/Image/';
mkdir(outDir); % Ensure that the output directory exists.
imgFile     = [outDir, 'Img%05d.png'];
videoInfo   = getVideoInfo(videoFile);
fps         = videoInfo.getFramesPerSecond();
duration    = videoInfo.getDuration();
R           = videoInfo.getResolution();
nFrame      = floor(duration*fps);
isStorage   = ceil(4 * prod(R) * nFrame /2^10 /2^10 /2^10); % GBy
fprintf('The required storage is %d GBy.\n',isStorage);
assert(isStorage<=maxStorage, ...
    'Storage is %d GBy but the user set the maximum %d GBy.\n',...
    isStorage, maxStorage);
opt.fps     = fps;
[status, msg] = extractFramesFromVideo(videoFile, imgFile, opt);
if status,
    fprintf('Extracted %d frames from %s successfully.\n',nFrame,videoFile);
end
