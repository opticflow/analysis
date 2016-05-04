function opt = computeEntropyForAllImages(inFile, outFile, opt)
% computeEntropyForAllImages
%   inFile          - Input file pattern for images, e.g. 'Img%05d.png'.
%   outFile         - Output file for the entropy of all frames, 
%                     e.g. 'Entropy.mat'.
%   opt             - Structure with fields:
%                     * nBin    - Number of bins to compute the entropy. 
%                                 Default nBin = 256.
%                     * Range   - [minValue, maxValue] Minimum and maximum 
%                                 value used when computing the entropy.
%                                 Default Range = [0 255].
%                     * verbose - [0 | 1] If 1 prints status information 
%                                 about the progress.
%
% RETURNs
%   info            - Structure with fields:
%                     * nFrame      - Number of computed flow patterns.
%                     * nSegment    - Number of segments.
%                     * Bin         - Bins used to compute the entropy.
%                     * nY          - Height of the frames in pixels.
%                     * nX          - Width of the frames in pixels.
%                     * excTimeInM  - Computation time in minutes.
%                     * excTimeInH  - Computation time in hours.
%                     * excTimeInD  - Computation time in days.
%
% DESCRIPTION
%   Computes the entropy in bits for images using their gray value format.
%   Images are loaded from the folder 'inFile'. The entropy is computed 
%   using the specified range and number of bins. The result is stored in 
%   a single output file.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

% Get the segments of indices.
[dirPath, fileName, fileExt] = fileparts(inFile);
fileNamePattern = [fileName, fileExt];
IndexForSegment = indexFileFilter(dirPath, fileNamePattern);
if isempty(IndexForSegment),
    error('Matlab:Parameter',...
        'Unable to find input image of the format %s.\',inFile);
end
IndexFirstFrame     = IndexForSegment(:, 1);
IndexLastFrame      = IndexForSegment(:, 2);
opt = computeEntropyForImages(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt);


