function FileNames = fileFilterForDirectories(dirPath, fileSuffix)
% fileFilterForDirectories
%   dirPath     - Path for the input directory.
%   fileSuffix  - All files in the returned listing end with this suffix.
% RETURN
%   FileNames   - Listing of filtered file names with their full path.
%

%   Florian Raudies, 03/28/2016, Palo Alto, CA.

if ~exist(dirPath, 'dir'),
    error('Matlab:IO', 'Directory %s does not exist!\n', dirPath);
end

N_MAX_DEPTH = 15;
N_BUFFER    = 2^14; % 2^14 = 16384;
FileNames   = cell(N_BUFFER,1);
[FileNames, iFile] = files(dirPath, fileSuffix, FileNames, ...
    1, N_BUFFER, 1, N_MAX_DEPTH);
FileNames = FileNames(1:(iFile-1));

function [FileNames, iFile] = files(dirPath, fileSuffix, ...
    FileNames, iFile, nMaxFile, nLevel, nMaxLevel)
if nLevel >= nMaxLevel,
    error('Matlab:IO', 'Reached maximum recursion depth of %d!', nLevel);
end

nSuffix     = length(fileSuffix);
DirListing  = dir(dirPath);
nDirListing = length(DirListing);
for iDirListing = 1:nDirListing,
    fileInfo = DirListing(iDirListing);
    fileName = fileInfo.name;
    if fileInfo.isdir,
        if ~strcmp(fileName,'.') && ~strcmp(fileName,'..'),
            [FileNames, iFile] = files([dirPath,'/',fileName], fileSuffix, ...
                                FileNames, iFile, nMaxFile, nLevel+1, nMaxLevel);
        end
    elseif strcmpi(fileName(end-nSuffix+1:end), fileSuffix),
        if iFile >= nMaxFile,
            error('Matlab:IO', 'Reached maximum number of %d of files!', nMaxFile);
        end
        FileNames{iFile}    = [dirPath, '/', fileName];
        iFile               = iFile + 1;
    end
    
end
