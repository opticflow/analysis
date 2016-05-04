function opt = computeEntropyForImages(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt)
% computeEntropyForImages
%   inFile          - Input file pattern for images, e.g. 'Img%05d.png'.
%   IndexFirstFrame - First frame of the images for segments.
%   IndexLastFrame  - Last frame of the images for segments.
%   outFile         - Output file for the entropy of all frames, 
%                     e.g. 'Entropy.mat'.
%   opt             - Structure with fields:
%                     * ScaleOrSize - Rescale the image by this factor or
%                                     resize the image to the size
%                                     [row column].
%                     * nBin        - Number of bins to compute the 
%                                     entropy. Default nBin = 256.
%                     * Range       - [minValue, maxValue] Minimum and 
%                                     maximum value used when computing the 
%                                     entropy. Default Range = [0 255].
%                     * verbose     - [0 | 1] If 1 prints status 
%                                     information about the progress.
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
if isfield(opt,'verbose'),      verbose = opt.verbose;
else                            verbose = 0;                        end
if ~isfield(opt,'nBin'),        opt.nBin = 256;                     end
if ~isfield(opt,'Range'),       opt.Range = [0 255];                end

if ~exist(sprintf(inFile,IndexFirstFrame(1)),'file'),
    error('Matlab:IO',...
        'Unable to find flows of the format %s.\',inFile);
end
[dirOut,~,~] = fileparts(outFile);
if ~exist(dirOut, 'dir'),
    error('Matlab:IO',...
        'Output directory %s does not exist.\n',dirOut);
end

NumFrame = IndexLastFrame - IndexFirstFrame + 1;

t0 = tic;

nSegment        = length(IndexFirstFrame);
nAllFrame       = sum(NumFrame);
Entropy         = zeros(nAllFrame, 1);
IndexForFrame   = zeros(nAllFrame, 1);
iData           = 1;
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
            fprintf(' Computing pattern match %d of %d.\n',...
                iFrame-iFirstFrame, nFrame-1);
        end
        
        Img = rgb2gray(imread(sprintf(inFile, iFrame)));
        
        [Entropy(iData), opt]   = computeEntropyForImage(Img, opt);
        IndexForFrame(iData)    = iFrame;
        iData                   = iData + 1;
    end
    
end
t = toc(t0);

saveEntropyForAllFrames(Entropy, IndexForFrame, opt.Bin, outFile);

% Note that nY, nX, nBin, Range, ... are set by 'computeEntropyForImage'.
opt.nFrame      = nAllFrame;
opt.nSegment    = nSegment;
opt.excTimeInM  = t /60;
opt.excTimeInH  = t /60 /60;
opt.excTimeInD  = t /60 /60 /24;
