function info = computePatternMatchForFlows(inFile, IndexFirstFrame, ...
    IndexLastFrame, outFile, opt)
% patternMatchForFlows
%   inFile          - Input file pattern, e.g. 'Flw%05d.flw'.
%   IndexFirstFrame - First optic flow field for segments.
%   IndexLastFrame  - Last optic flow field for segments.
%   outFile         - Output file pattern, e.g. 'Pat%05d.mat'.
%   opt             - Structure with fields:
%                     *	Fields from flowPattern and computePatternMatch.
%                     * verbose - [0 | 1]. If 1 prints progress
%                       information.
%
% RETURNs
%   info            - Structure with fields:
%                     * nFrame          - Number of computed flow patterns.
%                     * nPattern        - Number of patterns.
%                     * PatternType     - Type of flow patterns.
%                     * PatternPosition - Position of the flow patterns in 
%                                         the image plane.
%                     * nY              - Height of the frames in pixels.
%                     * nX              - Width of the frames in pixels.
%                     * excTimeInM      - Computation time in minutes.
%                     * excTimeInH      - Computation time in hours.
%                     * excTimeInD      - Computation time in days.
%
% DESCRIPTION
% 	Matches the optic flows from inFile into pattern space constructed with 
%   opts and saves the matching results in the outFile.
%

%   Florian Raudies, 02/11/2016, Palo Alto, CA.

if isfield(opt,'verbose'),  verbose = opt.verbose; opt = rmfield(opt,'verbose');
else                        verbose = 0;        end

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
nAllFrame = sum(NumFrame);

t0 = tic;

nSegment = length(IndexFirstFrame);

[Dx, ~]         = loadFlow(sprintf(inFile, IndexFirstFrame(1)));
[nY, nX]        = size(Dx);
[DxP, DyP, opt] = flowPattern(nX, nY, opt);
nPattern        = size(DxP, 3);
PatternType     = opt.PatternType;
PatternPosition = opt.PatternPosition;
Match           = zeros(nAllFrame, nPattern);
iMatch          = 1;

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
        [Dx, Dy] = loadFlow(sprintf(inFile,iFrame));
        M = computePatternMatch(Dx, Dy, DxP, DyP, opt);
        Match(iMatch,:) = M';
        iMatch = iMatch + 1;
%         savePatternMatch(Match, PatternType, PatternPosition, ...
%                          sprintf(outFile,iFrame));
    end
    
end
t = toc(t0);

savePatternMatch(Match, PatternType, PatternPosition, outFile);

[nY, nX]                = size(Dx);
info.nFrame             = sum(NumFrame);
info.nSegment           = nSegment;
info.nPattern           = nPattern;
info.PatternType        = PatternType;
info.PatternPosition    = PatternPosition;
info.nY                 = nY;
info.nX                 = nX;
info.excTimeInM         = t /60;
info.excTimeInH         = t /60 /60;
info.excTimeInD         = t /60 /60 /24;
