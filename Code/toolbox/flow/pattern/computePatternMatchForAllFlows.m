function info = computePatternMatchForAllFlows(inFile, outFile, opt)
% computePatternMatchForAllFlows
%   inFile      - Input file pattern, e.g. 'Flw%05d.flw'.
%   outFile     - Output file pattern, e.g. 'Pat%05d.mat'.
%   opt         - Structure with fields:
%                 * Same as for motionPattern and computePatternMatch 
%                   combined.
%                 * verbose: [0 | 1]. If 1 prints status of computation.
% RETURNs
%   info        - Structure with fields:
%                 * nFrame          - Number of computed flow patterns.
%                 * nPattern        - Number of patterns.
%                 * PatternType     - Type of flow patterns.
%                 * PatternPosition - Position of the flow patterns in 
%                                     the image plane.
%                 * nY              - Height of the frames in pixels.
%                 * nX              - Width of the frames in pixels.
%                 * excTimeInM      - Computation time in minutes.
%                 * excTimeInH      - Computation time in hours.
%                 * excTimeInD      - Computation time in days.
%
% DESCRIPTION
% 	Matches all optic flows from inFile into pattern space constructed with 
%   opts and saves the matching results in the outFile.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

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
info = computePatternMatchForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt);
