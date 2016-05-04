function info = computeSpeedHistogramForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt)
% computeSpeedHistogramForFlows
%   inFile          - Pattern for the input file name, e.g. ‘Flw%05d.mat’, 
%                     used in sprintf to generate the filename for each 
%                     flow field.
%   IndexFirstFrame - The index of the first frame in the segments.
%   IndexLastFrame  - The index of the last frame in the segments.
%   outFile         - Pattern for the output file name, e.g. ‘Hst%05d.mat’. 
%                     Output files have the indices iFirstFrame iLastFrame
%                     per segment.
%   opt             - Structure with the fields:
%                     * aperture - 'None' (which is the default) or 
%                                   'Circular'.
%                     * verbose  - [0|1] If 1 prints information about the 
%                       progress 1 is the default.
%                     * fps      - Frames per second.
%                     * hFoV     - Horizontal field of view in RAD.
%
% RETURNs
%   info            - Structure with the information about the calculated 
%                     histograms. Fields are:
%                     * nFrame      - Number of computed flow speeds.
%                     * nSegment    - Number of segments.
%                     * nY          - Height of the frames in pixels.
%                     * nX          - Width of the frames in pixels.
%                     * excTimeInM  - Computation time in minues.
%                     * excTimeInH  - Computation time in hours.
%                     * excTimeInD  - Computation time in days.
% DESCRIPTION
%   Computes the flow speed and histogram thereof for optic flows specified 
%   through the inFile and indices.

%   Florian Raudies, 02/14/2016, Palo Alto, CA.

if isfield(opt,'verbose'),  verbose = opt.verbose; opt = rmfield(opt,'verbose');
else                        verbose = 0;        end

NumFrame = IndexLastFrame - IndexFirstFrame + 1;
nAllFrame = sum(NumFrame);

t0 = tic;

nSegment = length(IndexFirstFrame);

if ~exist(sprintf(inFile,IndexFirstFrame(1)),'file'),
    error('Matlab:IO',...
        'Unable to find input flows of the format %s.\',inFile);    
end
[dirOut,~,~] = fileparts(outFile);
if ~exist(dirOut, 'dir'),
    error('Matlab:IO',...
        'Output directory %s does not exist.\n',dirOut);
end

[Dx, Dy] = loadFlow(sprintf(inFile,IndexFirstFrame(1)));
[~, ~, B] = computeSpeedHistogram(Dx, Dy, opt);
nBin = length(B);
Hist = zeros(nAllFrame, nBin);
iHist = 1;

for iSegment = 1:nSegment,
    iFirstFrame = IndexFirstFrame(iSegment);
    iLastFrame  = IndexLastFrame(iSegment);
    nFrame      = NumFrame(iSegment);
    
    if verbose,
        fprintf('Working on segment %d of %d segments.\n', iSegment, nSegment);
        fprintf('The first index is %d and the last index is %d.\n', ...
            iFirstFrame, iLastFrame);
    end
    
    for iFrame = iFirstFrame : iLastFrame,
        if verbose,
            fprintf(' Computing speed histogram %d of %d.\n',...
                iFrame-iFirstFrame, nFrame-1);
        end
        [Dx, Dy] = loadFlow(sprintf(inFile,iFrame));
        [~, H, B] = computeSpeedHistogram(Dx, Dy, opt);
        %saveHistogram(H, B, sprintf(outFile,iFrame));
        Hist(iHist,:) = H';
        iHist = iHist + 1;
    end
    
end
t = toc(t0);

saveHistogram(Hist, B, outFile);

[nY nX]         = size(Dx);
info.nFrame     = sum(NumFrame);
info.nSegment   = nSegment;
info.nY         = nY;
info.nX         = nX;
info.excTimeInM = t /60;
info.excTimeInH = t /60 /60;
info.excTimeInD = t /60 /60 /24;
