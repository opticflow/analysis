function Img = flowToImage(Dx, Dy)
% flowToImage
%   Dx  - Horizontal flow component.
%   Dy  - Vertical flow component.
%
% RETURN
%   Img - Color image, where hue represents flow direction and saturation
%         flow speed.

%   Florian Raudies, 01/10/2016, Palo Alto, CA.

% This method is a re-implementation of the code from Deqing Sun.
OUT_OF_RANGE    = 1e9;

% Set out of range flow to zero.
IndexUnkown     = (abs(Dx)> OUT_OF_RANGE) | (abs(Dy)> OUT_OF_RANGE) ;
Dx(IndexUnkown) = 0;
Dy(IndexUnkown) = 0;

% Compute the maximum flow length and scale by it.
R       = hypot(Dx, Dy);
maxR    = max(R(:));
Dx      = Dx/(maxR+eps);
Dy      = Dy/(maxR+eps);

% Compute the color image given the flow.
Img = flowToColor(Dx, Dy);
% Set the out of range values to 0 (black).
Img(repmat(IndexUnkown, [1 1 3])) = 0;


function Img = flowToColor(Dx, Dy)
    % ComputeColor color codes flow field Dx, Dy
    IndexNaN        = isnan(Dx) | isnan(Dy);
    Dx(IndexNaN)    = 0;
    Dy(IndexNaN)    = 0;
    [nY nX]         = size(Dx);
    R               = hypot(Dx, Dy);

    ColorMap            = perceptColorMap/255;
    [nColor nChannel]   = size(ColorMap);

    Phi                 = atan2(-Dy,-Dx)/pi; % mirror vectors around origin
    Phi2Col             = (Phi+1)/2 * (nColor-1) + 1; %-1...+1 -> 1...cNum
    Phi2ColIndex        = floor(Phi2Col);
    Phi2ColNextIndex    = Phi2ColIndex+1;
    Phi2ColNextIndex(Phi2ColNextIndex==nColor+1) = 1;
    Alpha = Phi2Col - Phi2ColIndex;
    Img = zeros(nY, nX, nChannel, 'uint8');
    Index = R <= 1;
    for iChannel = 1:nChannel,
        ColorMap4Channel = ColorMap(:,iChannel);
        % Interpolate between colors.
        ColorInterp = (1-Alpha).*ColorMap4Channel(Phi2ColIndex) ...
                    + Alpha.*ColorMap4Channel(Phi2ColNextIndex);
        ColorInterp(Index) = 1 - R(Index).*(1-ColorInterp(Index));
        ColorInterp(~Index) = ColorInterp(~Index)*0.75;
        Img(:,:,iChannel) = uint8(floor(255*ColorInterp.*(1-IndexNaN)));
    end

function ColorMap = perceptColorMap
    %   color encoding scheme
    %   adapted from the color circle idea described at
    %   http://members.shaw.ca/quadibloc/other/colint.htm
    nRY = 15;
    nYG = 6;
    nGC = 4;
    nCB = 11;
    nBM = 13;
    nMR = 6;
    nColor      = nRY + nYG + nGC + nCB + nBM + nMR;
    ColorMap    = zeros(nColor, 3); % r g b
    % RY
    ColorIndex              = 1:nRY;
    ColorMap(ColorIndex, 1) = 255;
    ColorMap(ColorIndex, 2) = floor(255*(0:nRY-1)/nRY)';
    % YG
    ColorIndex              = nRY + (1:nYG);
    ColorMap(ColorIndex, 1) = 255 - floor(255*(0:nYG-1)/nYG)';
    ColorMap(ColorIndex, 2) = 255;
    % GC
    ColorIndex              = nRY + nYG + (1:nGC);
    ColorMap(ColorIndex, 2) = 255;
    ColorMap(ColorIndex, 3) = floor(255*(0:nGC-1)/nGC)';
    % CB
    ColorIndex              = nRY + nYG + nGC + (1:nCB);
    ColorMap(ColorIndex, 2) = 255 - floor(255*(0:nCB-1)/nCB)';
    ColorMap(ColorIndex, 3) = 255;
    % BM
    ColorIndex              = nRY + nYG + nGC + nCB + (1:nBM);
    ColorMap(ColorIndex, 3) = 255;
    ColorMap(ColorIndex, 1) = floor(255*(0:nBM-1)/nBM)';
    %MR
    ColorIndex              = nRY + nYG + nGC + nCB + nBM + (1:nMR);
    ColorMap(ColorIndex, 3) = 255 - floor(255*(0:nMR-1)/nMR)';
    ColorMap(ColorIndex, 1) = 255;