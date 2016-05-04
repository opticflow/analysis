function info = computeEntropyForAllFlows(inFile, outFile, opt)
% computeEntropyForAllFlows
%   inFile              - Input file pattern for flow, e.g. 'Flw%05d.mat'.
%   outFile             - Output file for the entropy of all frames, 
%                         e.g. 'Entropy.mat'.
%   opt                 - Structure with fields:
%                         * All those from computeEntropyForFlow.
%                         * verbose = [0 | 1] If 1 prints status 
%                           information about the progress of the 
%                           computation.
% RETURNs
% 	info                - Structure fields:
%                         * nFrame      - Number of computed flow patterns.
%                         *	nSegment    - Number of segments.
%                         * BinY        - Binning used for 'Dy'.
%                         * BinX        - Binning used for 'Dx'.
%                         * nY          - Height of the frames in pixels.
%                         * nX          - Width of the frames in pixels.
%                         * excTimeInM  - Computation time in minutes.
%                         * excTimeInH  - Computation time in hours.
%                         * excTimeInD  - Computation time in days.
%
% DESCRIPTION
%   Computes the entropy in bits (base two) for the flows in the folder 
%   'inFile'. The result is stored in one output file with the name 
%   'outFile'.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.

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
info = computeEntropyForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt);
