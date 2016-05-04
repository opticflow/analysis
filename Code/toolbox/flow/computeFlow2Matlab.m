function [Dx Dy] = estimateFlow2Matlab(Img1, Img2, opt)
% estimateFlow2Matlab
%   Img1    - First image frame in range 0...1.
%   Img2    - Second image frame in range 0...1.
%   opt     - Structure with the following fields as options:
%             * nLevel  - Suggested number of levels in the image pyramid.
%             * sFactor - Scaling factor between pyramidal levels.
%             * nWarp   - Number of warping steps.
%             * nIter   - Number of iterations to solve primal and dual.
%             * lambda  - Smoothness factor.
%
% RETURN
%   Dx      - Horiztonal flow component.
%   Dy      - Vertical flow component.
%
% DESCRIPTION
%   Zach, C., Pock, T., and Bischof, H. (2007). A duality based approach
%   for realtime TV-L1 optical flow. In (Hamprecht, F.A., Schnörr, C., and 
%   Jähne, B. (eds.). DAGM 2007, LNCS 4713, pp.213--223.
%
%   Chambolle, A. and Pock, T. (2010). A first-order primal-dual algorithm 
%   with applications to imaging, Technical Report, Institute for Computer 
%   Graphics and Vision, Graz University of Technology.
%   

%   Florian Raudies, 01/09/2016, Palo Alto, CA.
if isfield(opt,'nLevel'),   nLevel  = opt.nLevel; 
else                        nLevel  = 1000;         end
if isfield(opt,'sFactor'),  sFactor = opt.sFactor; 
else                        sFactor = 0.9;          end
if isfield(opt,'nWarp'),    nWarp   = opt.nWarp; 
else                        nWarp   = 1;            end
if isfield(opt,'nIter'),    nIter   = opt.nIter; 
else                        nIter   = 50;           end
if isfield(opt,'lambda'),   lambda  = opt.lambda;
else                        lambda  = 50;           end
nDuals = 6; % Number of dual variables.
[nH, nW, nChnl] = size(Img1);
if nChnl~=1, warning('Matlab:IO','Only for gray-value images!'); end

% *************************************************************************
% Compute the size of images within the pyramid.
% *************************************************************************
nLevel  = min(nLevel, 1+ceil(log(16.0/min(nH, nW))/log(sFactor))); 
Scale   = sFactor.^(0:nLevel-1);
NumW    = round(nW*Scale);
NumH    = round(nH*Scale);

% *************************************************************************
% Define the image pyramid.
% *************************************************************************
I1      = cell(nLevel,1);
I2      = cell(nLevel,1);
I1{1}   = Img1;
I2{1}   = Img2;
for iLevel = 2:nLevel,
    I1{iLevel} = imresize(I1{iLevel-1}, ...
                          [NumH(iLevel) NumW(iLevel)], 'bicubic');
    I2{iLevel} = imresize(I2{iLevel-1}, ...
                          [NumH(iLevel) NumW(iLevel)], 'bicubic');
end

% *************************************************************************
% Compute the flow for each level in the pyramid.
% *************************************************************************
% Initialize
Dx  = zeros(NumH(nLevel), NumW(nLevel));
Dy  = zeros(NumH(nLevel), NumW(nLevel));
Dt  = zeros(NumH(nLevel), NumW(nLevel));
P   = zeros(nDuals, NumH(nLevel), NumW(nLevel));
% Solve the primal/dual for the first level.
[Dx, Dy, Dt, P] = tvL1PrimalDual2Matlab(I1{nLevel}, I2{nLevel}, ...
                                        Dx, Dy, Dt, P, lambda, nWarp, nIter);
    
% And for each subsequent level.
for iLevel = nLevel-1:-1:1;
    nH = NumH(iLevel);
    nW = NumW(iLevel); 
    % Map to next finer level.
    Dx = imresize(Dx,[nH nW], 'nearest')/ (NumW(iLevel+1)/nW);    
    Dy = imresize(Dy,[nH nW], 'nearest')/ (NumH(iLevel+1)/nH);
    Dt = imresize(Dt,[nH nW], 'nearest');
    % Change order of dimensions for P to resize.
    Pnew = zeros(nDuals, nH, nW);
    for iDual = 1:nDuals,
      Pnew(iDual,:,:) = imresize(squeeze(P(iDual,:,:)),[nH nW], 'nearest');
    end
    P = Pnew;
    [Dx, Dy, Dt, P] = tvL1PrimalDual2Matlab(I1{iLevel}, I2{iLevel}, Dx, Dy, Dt, ...
                                            P, lambda, nWarp, nIter);
end
