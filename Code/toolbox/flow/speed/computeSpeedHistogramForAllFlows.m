function info = computeSpeedHistogramForAllFlows(inFile, outFile, opt)
% computeSpeedHistogramForAllFlows
%   inFile  - Pattern for the input file name, e.g. ‘Flw%05d.mat’.
%   outFile - Pattern for the output file name, e.g. ‘Hst%05d.mat’.
%   opt     - Structure with the fields:
%             * aperture - ‘None’ (which is the default) or ‘Circular’.
%             * verbose  - [0 | 1] If 1 prints additional information about
%               the progress of the computation. Default 0.
%             * fps      - Frames per second.
%             * hFoV     - Horizontal field of view in RAD.
%
% RETURNs
%   info    - Structure with the information about the calculated flow 
%             speed. Fields are:
%             * nFrame: Number of computed flow speeds.
%             * nSegment: Number of segments.
%             * nY: Height of the frames in pixels.
%             * nX: Width of the frames in pixels.
%             * excTimeInM: Computation time in minutes.
%             * excTimeInH: Computation time in hours.
%             * excTimeInD: Computation time in days.
%
% DESCRIPTION
%   Computes the histogram of flow speeds for optic flows of one directory.

%   Florian Raudies, 02/14/2016, Palo Alto, CA.

% Get the segments of indices.
[dirPath, fileName, fileExt] = fileparts(inFile);
fileNamePattern = [fileName, fileExt];
IndexForSegment = indexFileFilter(dirPath, fileNamePattern);
if isempty(IndexForSegment),
    error('Matlab:Parameter',...
        'Unable to find input flows of the format %s.\',inFile);
end
IndexFirstFrame     = IndexForSegment(:, 1);
IndexLastFrame      = IndexForSegment(:, 2);
info = computeSpeedHistogramForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt);
