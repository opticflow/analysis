function [DxP, DyP, opt] = flowPattern(nX, nY, opt)
% flowPattern
%   nX  - Number of pixels in the horizontal dimension.
%   nY  - Number of pixels in the vertical dimension.
%   opt - Structure with fields:
%         * PatternType = {'exp', 'con', 'cw', 'ccw', 'left', 'right', 
%                          'up', 'down'}
%           These are abbreviations for the following:
%               'exp'   - An expansion flow pattern.
%               'con'   - An contraction flow pattern.
%               'cw'    - A clockwise rotational flow pattern.
%               'ccw'   - A counterclockwise rotational flow pattern.
%               'left'  - A leftward pointing, laminar flow pattern.
%               'right' - A rightward pointing, laminar flow pattern.
%               'up'    - An upward pointing, laminar flow pattern.
%               'down'  - A downward pointing, laminar flow pattern.
%           Laminar flow patterns are characterized by having only one 
%           direction for the motion vectors in the image plane. Notice 
%           that only the first four patterns depend on the position in the 
%           image plane.
%         * PatternPosition = [0 0] Position of the flow pattern in 
%           vertical and horizontal direction with respect to the center of 
%           the image screen in percentage of the entire size of the image 
%           screen. Thus, pattern positions inside the image screen are in 
%           the range -0.5 and 0.5 or -s and s, for s = 0.5*nY/nX.
%
% RETURNs
%   DxP - Horizontal flow component of the flow pattern with the three 
%         dimensions: nY x nX x nP, where ‘nP’ is the number of patterns. 
%         In the example the number of motion patterns is eight, nP = 8.
%         The speed is measured in units of pixels/frame.
%   DyP - Vertical flow component of the flow pattern with the dimensions: 
%         nY x nX x nP. The speed is measured in units of pixels/frame.
%   opt - Same structure as input with default values set.
%
% DESCRIPTION
%   Defines the space of flow patterns assuming that the y-axis points 
%   downward and the x-axis points to the right.
%   ATTENTION: This method brings the pattern type into the canonical order
%       {'exp', 'con', 'cw', 'ccw', 'left', 'right', 'up', 'down'} 
%   leaving out any patterns that may have not been specified.

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

if isfield(opt,'PatternType'),  PatternType = orderPatternType(opt.PatternType);
else                            PatternType = {'exp','con','cw','ccw',...
                                               'left','right','up','down'};
end
if isfield(opt,'PatternPosition'),  PatternPosition = opt.PatternPosition;
else                                PatternPosition = [0 0];
                                    opt.PatternPosition = PatternPosition;
end
opt.PatternType = PatternType;

nPP         = size(PatternPosition,1);
NumPattern  = parsePatternType(PatternType);
nPosDep     = nPP*sum(NumPattern(1:4)); % Number of position-dependent patterns
nPosIndep   = sum(NumPattern(5:8)); % Number of position-independent patterns
nP          = nPosDep + nPosIndep;
DxP         = zeros(nY,nX,nP);
DyP         = zeros(nY,nX,nP);
[Y, X]      = ndgrid(1:nY,1:nX);
Y           = (Y-nY/2);
X           = (X-nX/2);
Z           = zeros(nY,nX);
% First work on the position independent patterns.
iP = nPosDep;
if NumPattern(5) > 0, % left
    iP = iP + 1;
    DxP(:,:,iP) = -1;
    DyP(:,:,iP) = Z;
end
if NumPattern(6) > 0, % right
    iP = iP + 1;
    DxP(:,:,iP) = +1;
    DyP(:,:,iP) = Z;
end
if NumPattern(7) > 0, % up
    iP = iP + 1;
    DxP(:,:,iP) = Z;
    DyP(:,:,iP) = -1;
end
if NumPattern(8) > 0, % down
    iP = iP + 1;
    DxP(:,:,iP) = Z;
    DyP(:,:,iP) = +1;
end
Y       = repmat(Y, [1 1 nPP]);
X       = repmat(X, [1 1 nPP]);
XPos    = shiftdim(PatternPosition(:,1)*nX, -2);
YPos    = shiftdim(PatternPosition(:,2)*nY, -2);
iP      = 0;
if NumPattern(1) > 0, % exp
    DxP(:,:,iP+(1:nPP)) = bsxfun(@minus, X, XPos);
    DyP(:,:,iP+(1:nPP)) = bsxfun(@minus, Y, YPos);
    iP = iP + nPP;
end
if NumPattern(2) > 0, % con
    DxP(:,:,iP+(1:nPP)) = -bsxfun(@minus, X, XPos);
    DyP(:,:,iP+(1:nPP)) = -bsxfun(@minus, Y, YPos);
    iP = iP + nPP;
end
if NumPattern(3) > 0, % cw
    DxP(:,:,iP+(1:nPP)) = -bsxfun(@minus, Y, YPos);
    DyP(:,:,iP+(1:nPP)) = +bsxfun(@minus, X, XPos);
    iP = iP + nPP;
end
if NumPattern(4) > 0, % ccw
    DxP(:,:,iP+(1:nPP)) = +bsxfun(@minus, Y, YPos);
    DyP(:,:,iP+(1:nPP)) = -bsxfun(@minus, X, XPos);    
end

