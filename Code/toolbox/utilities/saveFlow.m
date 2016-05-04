function saveFlow(Dx, Dy, outFile)
% saveFlow
%   Dx      - Horizontal flow component in pixel/frame.
%   Dy      - Vertical flow component in pixel/frame.
%   outFile - The output file name.
%
% RETURN
%   --
%
% DESCRIPTION
%   Based on the file ending of outFile this method uses one of two formats
%   to save the flow field given by 'Dx' and 'Dy'. 
%   +---------------------------------------------------------------------+
%   | File Ending | Method used for saving                                |
%   +---------------------------------------------------------------------+
%   | 'mat' or '' | Matlab saves 'Dx' and 'Dy' as variables.              |
%   +---------------------------------------------------------------------+
%   | 'pcm'       | Saves the flow as pcm file.                           |
%   +---------------------------------------------------------------------+
%
%   To load a flow see also LOADFLOW.

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

[~, ~, fileSuffix] = fileparts(outFile);

if strcmp('.mat', fileSuffix) || isempty(fileSuffix),
    save(outFile, 'Dx', 'Dy');
elseif strcmp('.pcm', fileSuffix),
    savePCM(Dx, Dy, outFile, 'l');
else
    error('Matlab:IO', 'Unkown file format %s for flow.', fileSuffix);
end
