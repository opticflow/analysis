function info = computeFlowForAllImages(inFile, outFile, opt)
% computeFlowForAllImages
%   inFile      - Input file pattern for images, e.g. 'Img%05d.png'.
%   outFile     - Output file pattern for flows, e.g. 'Flw%05d.mat'.
%   opt         - Structure with fields:
%               * Same fields as for computeFlowForImages.
% RETURN
%   info        - Structure with the information about the computed flow. 
%                 Fields are:
%                 * nFrame - Number of frames that flow was computed for.
%                 * nSegment - Number of segments. A segment is defined 
%                              through consecutive indices of images, e.g. 
%                              the sequence:
%                               1, 2, 3, 6, 7, 8, 55, 56, 57, 58, 59, 60
%                              has three segments of consecutive indices 
%                               1-3, 6-8, and 55-60.
%                 * nY - Height of the frames in pixels.
%                 * nX - Width of the frames in pixels.
%                 * excTimeM - Time of execution in minutes.
%                 * excTimeH - Time of execution in hours.
%                 * excTimeD - Time of execution in days.
%

%   Florian Raudies, 01/17/2016, Palo Alto, CA.

% Get the segments of indices.
[dirPath, fileName, fileExt] = fileparts(inFile);
fileNamePattern = [fileName, fileExt];
IndexForSegment = indexFileFilter(dirPath, fileNamePattern);
if isempty(IndexForSegment),
    error('Matlab:Parameter',...
        'Unable to find input images of the format %s.\',inFile);
end
IndexFirstFrame     = IndexForSegment(:, 1);
IndexLastFrame      = IndexForSegment(:, 2);
info = computeFlowForImages(inFile, IndexFirstFrame, IndexLastFrame, ...
                            outFile, opt);
