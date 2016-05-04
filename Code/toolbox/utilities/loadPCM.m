function [X, Y] = loadPCM(inFile, machineFormat)
% loadPCM
%   inFile          - Name of the input file.
%   machineFormat   - Machine format to load binary values.
%
% RETURN
%   X               - First component.
%   Y               - Second component.
%
% DESCRIPTION
%   Loads a two components 'X' and 'Y' from a PCM file.
%   For more information about the file format see also SAVEPCM.
%

%   Florian Raudies, 01/10/2016, Palo Alto, CA

[fh, message] = fopen(inFile, 'r', machineFormat);

if fh==-1, error([message, ' ', inFile]); end

fscanf(fh, '%s', 1); % read string in first line
% read until lineend % ASCII 10 => \n
c = fread(fh, 1, 'uchar'); while (c ~= 10), c = fread(fh, 1, 'uchar'); end
Num = fscanf(fh, '%d', 2);
c = fread(fh, 1, 'uchar'); while (c ~= 10), c = fread(fh, 1, 'uchar'); end
sf = fscanf(fh, '%f', 1); % Scaling factor but not used.
c = fread(fh, 1, 'uchar'); while (c ~= 10), c = fread(fh, 1, 'uchar'); end

[Data, nData] = fread(fh, inf, 'single', machineFormat);
fclose(fh);

if nData ~= 2*prod(Num(:)), 
    warning('MATLAB:IOError', 'pcm file %s is corrupted!',inFile); 
end

X = reshape( Data(1:2:end), Num(1), Num(2) )';
Y = reshape( Data(2:2:end), Num(1), Num(2) )';
