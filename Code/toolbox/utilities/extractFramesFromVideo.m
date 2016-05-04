function [status, msg] = extractFramesFromVideo(inFile, outFile, opt)
% extractFramesFromVideo
%   inFile      - Video input file.
%   outFile     - Output file pattern to save the files in PNG format.
%                 For instance, outFile = 'Img%05.png'.
%   opt         - Structure with the field(s):
%                 * fps     - Frames per second.
%
% RETURN
%   status      - Return value from the ffmpeg, if 0 no error occured.
%   msg         - Output message from ffmpeg.
%
% DESCRIPTION
%   Calls ffmpeg to extract the image frames from the video file.
%

%   Florian Raudies, 01/16/2016, Palo Alto, CA.

cmdStr = sprintf('ffmpeg -i %s -f image2 -r %2.2f %s', inFile, opt.fps, outFile);

fprintf('Executing %s.\n', cmdStr);

[status, msg] = system(cmdStr);