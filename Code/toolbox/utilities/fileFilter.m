function FileNames = fileFilter(dirPath, fileSuffix)
% fileFilter
%   dirPath     - Path for the input directory.
%   fileSuffix  - All files in the returned listing must end with this
%                 suffix.
% RETURN
%   FileNames   - Listing of filtered file names with their full path.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.

if ~exist(dirPath, 'dir'),
    error('Matlab:IO', 'Directory %s does not exist!\n', dirPath);
end

N_BUFFER    = 2^14; % 2^14 = 16384;
nSuffix     = length(fileSuffix);
DirListing  = dir(dirPath);
nDirListing = length(DirListing);
FileNames   = cell(N_BUFFER,1);
iFileName   = 0;
for iDirListing = 1:nDirListing,
    fileInfo = DirListing(iDirListing);
    fileName = fileInfo.name;
    if ~fileInfo.isdir && strcmp(fileName(end-nSuffix+1:end), fileSuffix),
        iFileName               = iFileName + 1;
        FileNames{iFileName}    = [dirPath, fileName];
    end
end
FileNames = FileNames(1:iFileName);
