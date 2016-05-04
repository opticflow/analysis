function DirNames = dirFilter(dirName, dirPrefix)
% dirFilter
%   dirName     - Path/name for the input directory.
%   filePrefix  - All directories in the returned listing start with this
%                 prefix.
% RETURN
%   DirNames    - Listing of filtered directory names with their full path.
%

%   Florian Raudies, 03/29/2016, Palo Alto, CA.

if ~exist(dirName, 'dir'),
    error('Matlab:IO', 'Directory %s does not exist!\n', dirName);
end

N_BUFFER    = 2^14; % 2^14 = 16384;
nPrefix     = length(dirPrefix);
DirListing  = dir(dirName);
nDirListing = length(DirListing);
DirNames    = cell(N_BUFFER,1);
iDirName    = 0;
for iDirListing = 1:nDirListing,
    fileInfo    = DirListing(iDirListing);
    name        = fileInfo.name;
    if fileInfo.isdir && ~strcmp(name, '.') && ~strcmp(name, '..'),
        if nPrefix==0 || strcmp(name(1:nPrefix), filePrefix),
            iDirName            = iDirName + 1;
            DirNames{iDirName}  = [dirName, '/', name];
        end
    end
end
DirNames = DirNames(1:iDirName);