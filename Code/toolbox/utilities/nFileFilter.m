function nFile = nFileFilter(dirPath,fileSuffix)
% nFileFilter
%   dirPath     - Path for the input directory.
%   fileSuffix  - All files in the returned listing must end with this
%                 suffix.
% RETURN
%   nFile       - Number of files that end with fileSuffix in dirPath.
%

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

if ~exist(dirPath,'dir'),
    error('Matlab:IO', 'Directory %s does not exist!\n', dirPath);
end

nSuffix     = length(fileSuffix);
DirListing  = dir(dirPath);
nDirListing = length(DirListing);
nFile       = 0;
for iDirListing = 1:nDirListing,
    fileInfo = DirListing(iDirListing);
    fileName = fileInfo.name;
    if ~fileInfo.isdir && strcmp(fileName(end-nSuffix+1:end), fileSuffix),
        nFile = nFile + 1;
    end
end