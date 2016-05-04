function opt = equalizeImageForAllImages(inFile, outFile, opt)
% equalizeImageForAllImages
%   inFile  - Input file pattern, e.g. 'Img%05d.png'.
%   outFile - Output file pattern, e.g.  'Eq/Img%05d.png'.
%   opt     - Structure with fields:
%             * verbose: [0 | 1]. If 1 prints status information for the 
%                        computation.
% RETURNs
%   info    - Structure with the information about the calculated images. 
%             Fields are:
%             * nFrame: Number of equalized image frames.
%             * nSegment: Number of segments.
%             * excTimeInM: Computation time in minutes.
%             * excTimeInH: Computation time in hours.
%             * excTimeInD: Computation time in days.
%

%   Florian Raudies, 04/24/2016, Palo Alto, CA.

if isfield(opt, 'verbose'),
    verbose     = opt.verbose; 
    opt         = rmfield(opt, 'verbose');
else
    verbose     = 0;
end

% Get the segments of indices.
[dirPath, fileName, fileExt] = fileparts(inFile);
fileNamePattern = [fileName, fileExt];
IndexForSegment = indexFileFilter(dirPath, fileNamePattern);
if isempty(IndexForSegment),
    error('Matlab:Parameter',...
        'Unable to find input image of the format %s.\',inFile);
end
IndexFirstFrame = IndexForSegment(:, 1);
IndexLastFrame  = IndexForSegment(:, 2);
nSegment        = length(IndexFirstFrame);
NumFrame        = IndexLastFrame - IndexFirstFrame + 1;
nAllFrame       = sum(NumFrame);
nBin            = 256;
H               = zeros(nBin,1);

t0 = tic;

if verbose,
    fprintf('Collecting image statistics.\n');
end

for iSegment = 1:nSegment,
    iFirstFrame = IndexFirstFrame(iSegment);
    iLastFrame  = IndexLastFrame(iSegment);    
    for iFrame = iFirstFrame : iLastFrame,
        ImgRGB = imread(sprintf(inFile, iFrame));
        ImgYCBCR = rgb2ycbcr(ImgRGB);
        ImgY = squeeze(ImgYCBCR(:,:,1));
        H = H + histogram(ImgY(:),linspace(0,nBin-1,nBin-1));
    end
end
H = H/nAllFrame;

if verbose,
    fprintf('Equalizing image statistics.\n');
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
        ImgRGB = imread(sprintf(inFile, iFrame));
        ImgRGB = histogramEqualize(ImgRGB, H);

        if verbose,
            fprintf(' Computing histogram %d of %d.\n',...
                iFrame-iFirstFrame, nFrame-1);
        end
        
        imwrite(ImgRGB, sprintf(outFile,iFrame));
    end
end

t = toc(t0);

opt.nFrame      = nAllFrame;
opt.nSegment    = nSegment;
opt.excTimeInM  = t /60;
opt.excTimeInH  = t /60 /60;
opt.excTimeInD  = t /60 /60 /24;