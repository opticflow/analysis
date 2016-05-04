function info = computeEntropyForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt)
% computeEntropyForFlows
%   inFile              - Input file pattern for flows, e.g. 'Flw%05d.mat'.
%   IndexFirstFrame     - First frame of the flow fields for segments.
%   IndexLastFrame      - Last frame of the flow fields for segments.
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
%   Computes the entropy in bits (base two) for the index defined flows in 
%   the folder 'inFile'. The result is stored in one output file with the 
%   name 'outFile'.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.


if isfield(opt,'verbose'),  verbose = opt.verbose; opt = rmfield(opt,'verbose');
else                        verbose = 0;        end

NumFrame = IndexLastFrame - IndexFirstFrame + 1;

t0 = tic;

nSegment        = length(IndexFirstFrame);
nAllFrame       = sum(NumFrame);
Entropy         = zeros(nAllFrame, 3);
IndexForFrame   = zeros(nAllFrame, 1);
iData           = 1;

if ~exist(sprintf(inFile,IndexFirstFrame(1)),'file'),
    error('Matlab:IO',...
        'Unable to find input flows of the format %s.\',inFile);    
end
[dirOut,~,~] = fileparts(outFile);
if ~exist(dirOut, 'dir'),
    error('Matlab:IO',...
        'Output directory %s does not exist.\n',dirOut);
end

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
            fprintf(' Computing entropy for flow %d of %d.\n',...
                iFrame-iFirstFrame, nFrame-1);
        end
        [Dx, Dy] = loadFlow(sprintf(inFile,iFrame));
        [Entropy(iData,:), opt] = computeEntropyForFlow(Dx, Dy, opt);
        IndexForFrame(iData)    = iFrame;
        iData                   = iData + 1;
    end
    
end
t = toc(t0);

saveEntropyForAllFrames(Entropy, IndexForFrame, [opt.BinY; opt.BinX], outFile);

[nY nX]         = size(Dx);
info.nFrame     = nAllFrame;
info.nSegment   = nSegment;
info.BinY       = opt.BinY;
info.BinX       = opt.BinX;
info.nY         = nY;
info.nX         = nX;
info.excTimeInM = t /60;
info.excTimeInH = t /60 /60;
info.excTimeInD = t /60 /60 /24;
