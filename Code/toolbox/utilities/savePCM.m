function savePCM(X, Y, outFile, machineFormat)
% savePCM
%   X               - First component to be saved.
%   Y               - Second component to be saved.
%   outFile         - Output filename.
%   machineFormat   - Machine format to write binary values.
%
% RETURN
%   --
%
% DESCRIPTION
%   Saves the two matrices 'X' and 'Y' as PCM file. The file format of a
%   PCM file is
%
%   Line 1 PC                  \
%   Line 2 width height         |->  ASCII TEXT
%   Line 3 scaleFactor         /
%   Line 4 X/Y interleaved ... ---> BINARY DATA 
%
%   To find information about 'machineFormat' type help fopen.
%   To load a pcm file see also LOADPCM.

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

X = X';
Y = Y';

sf              = max(hypot(X(:), Y(:)));   % Scaling factor.
Data            = ones(2*numel(X), 1);      % Interleaved data.
Data(1:2:end)   = X(:);                     % First component.
Data(2:2:end)   = Y(:);                     % Second component.

fh = fopen(outFile, 'w', machineFormat);

if fh==-1, error([message, ' ', inFile]); end

fprintf(fh, 'PC\n%d %d\n%f\n', size(X,1), size(X,2), sf);
fwrite(fh, Data(:), 'single', 0, machineFormat);
fclose(fh);
