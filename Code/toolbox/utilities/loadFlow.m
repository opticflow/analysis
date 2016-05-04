function [Dx, Dy] = loadFlow(inFile)
% loadFlow
%   inFile  - Filename of the input file.
%
% RETURN
%   Dx      - Horizontal flow component in pixel/frame.
%   Dy      - Vertical flow component in pixel/frame.
%
% DESCRIPTION
%   For supported file formats see also SAVEFLOW.

%   Florian Raudies, 01/10/2016, Palo Alto, CA.
[~, ~, fileSuffix] = fileparts(inFile);
if strcmp('.mat', fileSuffix) || isempty(fileSuffix),
    Vars = load(inFile);
    if ~isfield(Vars,'Dx') || ~isfield(Vars,'Dy'),
        error('Matlab:IO','Could not find fields Dx/Dy in mat file %s',inFile);
    end
    Dx = Vars.Dx;
    Dy = Vars.Dy;
elseif strcmp('.pcm', fileSuffix),
    [Dx, Dy] = loadPCM(inFile, 'l');
else
    error('Matlab:IO', 'Unkown file format %s for flow.', fileSuffix);
end
