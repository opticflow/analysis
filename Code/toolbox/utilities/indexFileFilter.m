function IndexForSegment = indexFileFilter(dirPath, fileNamePattern)
% indexFileFilter
%   dirPath             - Path to the directory that contains the files.
%   fileNamePattern     - Pattern of the file name, e.g. 'Img%05d.png'.
%
% RETURN
%   IndexForSegment     - Start and end index for each segment. Has the
%                         dimensions: nSegment x 2. If there are no matches
%                         returns an empty matrix.
%
% DESCRIPTION
%   Finds all the segments of consecutive indices in the directory
%   'dirPath' that match the 'fileNamePattern'. 
%   Example: Assume the directory '~/MyImages/' has the files:
%       'Img00001.png', 'Img00003.png', 'Img00004.png', 'Img00005.png', 
%       'Img00006.png', 'Img00011.png', 'Img00012.png'.
%   The call 
%       IndexForSegment = indexFileFilter('~/MyImages/','Img%05d.png');
%   Gives the result
%       IndexForSegment = [1 1
%                          3 6
%                          11 12]
%

%   Florian Raudies, 01/17/2016, Palo Alto, CA.
DirListing  = dir(dirPath);
nDirListing = length(DirListing);
Index       = zeros(nDirListing,1);
nIndex      = 0;
for iDirListing = 1:nDirListing,
    fileInfo    = DirListing(iDirListing);
    fileName    = fileInfo.name;
    index       = sscanf(fileName,fileNamePattern);
    if ~isempty(index),
        nIndex          = nIndex + 1;
        Index(nIndex)   = index;
    end
end

if nIndex > 1,
    Index               = Index(1:nIndex);
    iFirst              = min(Index);
    iLast               = max(Index);
    Index               = sort(Index, 1, 'ascend');
    D                   = diff(Index)>1;
    IndexStartOfSegment = [iFirst; Index(circshift(D,1))];
    IndexEndOfSegment   = [Index(D); iLast];
    IndexForSegment     = [IndexStartOfSegment IndexEndOfSegment];
else
    IndexForSegment     = [];
end