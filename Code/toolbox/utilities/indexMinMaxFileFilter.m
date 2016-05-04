function [iMin iMax] = indexMinMaxFileFilter(dirPath, fileNamePattern)
% indexMinMaxFileFilter
%   dirPath             - Path to the directory that contains the files.
%   fileNamePattern     - Pattern of the file name, e.g. 'Img%05d.png'.
%
% RETURN
%   iMin                - Minimum index that matches the pattern. If none
%                         of the files matches iMin = intmax.
%   iMax                - Maximum index that matches the pattern. If none
%                         of the files matechs iMax = intmin.
%
% DESCRIPTION
%   Finds the minimum and maximum index of files following the naming
%   pattern 'fileNamePattern' in the directory 'dirPath'. This method does
%   NOT check that the indices appear consecutively.
%
%   For example: If the directory ~/myImages/ contains the files
%       Img00001.png, Img00002.png, Img00003.png, Img00008.png.
%
%   The the call
%       [iMin iMax] = indexMinMaxFileFilter('~/myImages/','Img%05d.png');
%
%   Returns
%       iMin = 1 and iMax = 8.
%

%   Florian Raudies, 01/17/2016, Palo Alto, CA.

DirListing  = dir(dirPath);
nDirListing = length(DirListing);
iMin        = intmax;
iMax        = intmin;
for iDirListing = 1:nDirListing,
    fileInfo    = DirListing(iDirListing);
    fileName    = fileInfo.name;
    index       = sscanf(fileName,fileNamePattern);
    if ~isempty(index),
        iMin = min(iMin, index);
        iMax = max(iMax, index);
    end
end