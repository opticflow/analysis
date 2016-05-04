function info = computeFlowForImages(inFile, IndexFirstFrame, IndexLastFrame, ...
    outFile, opt)
% computeFlowForImages
%   inFile          - Input file.
%   IndexFirstFrame - Index of the first image frame.
%   IndexLastFrame  - Index of the last image frame (inclusive).
%   outFile         - Pattern of the output file. E.g. 'Flw%05d.mat'.
%   opt             - Structure with fields:
%                     * ScaleOrSize - Rescale the image by this factor or
%                                     resize the image to the size 
%                                     [row column].
%                     * verbose     - Print status updates about the 
%                                     progress of the computation.
%
% RETURN
%   info            - Structure with the information about the computed 
%                     flow. Fields are:
%                     * nFrame - Number of computed optic flow fields.
%                     * nY - Height of the frames in pixels.
%                     * nX - Width of the frames in pixels.
%                     * nSegment - Number of segments. A segment is defined 
%                                  through consecutive indices.
%                     * excTimeM - Time of execution in minutes.
%                     * excTimeH - Time of execution in hours.
%                     * excTimeD - Time of execution in days.
%
% DESCRIPTION
%   Compute flow for images given by inFile file pattern from indices
%   iFirstFrame to iLastFrame (inclusive) and save the flows in the folder
%   outFile.
%
%   See also computeFlow2, computeFlowForAllImages, indexFileFilter.

%   Florian Raudies, 01/24/2016, Palo Alto, CA.

if isfield(opt, 'ScaleOrSize'),
    ScaleOrSize = opt.ScaleOrSize; 
    opt         = rmfield(opt, 'ScaleOrSize');
else
    ScaleOrSize = 1;
end
if isfield(opt, 'verbose'),
    verbose     = opt.verbose; 
    opt         = rmfield(opt, 'verbose');
else
    verbose     = 0;
end

NumFrame = IndexLastFrame - IndexFirstFrame + 1;

if length(ScaleOrSize)==1 && ScaleOrSize(1)>1,
    warning('Matlab:Parameter',...
        'sRatio = %2.2f which is greater 1. Images are upscaled!\n', sRatio);
end
if any(NumFrame<2),
    iSegment = find(NumFrame<2,1,'first');
    warning('Matlab:Parameter',...
        'Segment %d has %d frames but requires at least %d frames.\n',...
        iSegment,NumFrame(iSegment),2);
end
if ~exist(sprintf(inFile,IndexFirstFrame(1)),'file'),
    error('Matlab:IO',...
        'Unable to find input images of the format %s.\',inFile);    
end
[dirOut,~,~] = fileparts(outFile);
if ~exist(dirOut, 'dir'),
    error('Matlab:IO',...
        'Output directory %s does not exist.\n',dirOut);
end


t0 = tic;

nSegment    = length(IndexFirstFrame);
doRescale   = length(ScaleOrSize) > 1 || ScaleOrSize(1) ~= 1;

for iSegment = 1:nSegment,
    iFirstFrame = IndexFirstFrame(iSegment);
    iLastFrame  = IndexLastFrame(iSegment);
    
    if verbose,
        fprintf('Working on segment %d of %d segments.\n', iSegment, nSegment);
        fprintf('The first index is %d and the last index is %d.\n', ...
            iFirstFrame, iLastFrame);
    end

    Img1 = double(rgb2gray(imread(sprintf(inFile, iFirstFrame))))/255;
    if doRescale,
        Img1 = imresize(Img1, ScaleOrSize);
    end
    
    nFrame = NumFrame(iSegment);

    for iFrame = iFirstFrame+1 : iLastFrame,
        if verbose,
            fprintf(' Computing flow for image %d of %d images.\n',...
                iFrame-iFirstFrame, nFrame-1);
        end
        Img2 = double(rgb2gray(imread(sprintf(inFile, iFrame))))/255;
        if doRescale,
            Img2 = imresize(Img2, ScaleOrSize);
        end
        [Dx, Dy] = computeFlow2(Img1, Img2, opt);
        saveFlow(Dx, Dy, sprintf(outFile, iFrame-1));
        % Update the image.
        Img2 = Img1;
    end
    
end
t = toc(t0);

[nY nX]         = size(Img1);
info.nFrame     = sum(NumFrame);
info.nSegment   = nSegment;
info.nY         = nY;
info.nX         = nX;
info.excTimeInM = t /60;
info.excTimeInH = t /60 /60;
info.excTimeInD = t /60 /60 /24;
