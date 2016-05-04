function F = imresize2Matlab(Z,I,type)
antialias = 0;

if strcmp(type,'cubic'),
    kernel = @cubic;
    nKernel = 4;
    antialias = 1;
elseif strcmp(type,'nearest'),
    kernel = @box;
    nKernel = 1;
else
    error('Matlab:IO','Parameter type unkown.');
end
Scale = I./size(Z);

nDim = 2;
F = Z;
for iDim = 1:nDim,
    scale = Scale(iDim);
    if scale<1 && antialias,
        k = @(x) scale * kernel(scale * x);
        s = nKernel / scale;
        n = floor(s) + 1;
    else
        k = kernel;
        s = nKernel;
        n = nKernel;
    end
    %[Weights, Indices] = weightsAndIndices(size(Z,iDim), I(iDim), kernel, nKernel);
    [Weights, Indices] = weightsAndIndices(size(Z,iDim), I(iDim), k, s, n);
    F = doResize(F,Weights,Indices,iDim);
end

function F = doResize(V,W,I,iDim)

if iDim==1,
    nYi = size(W,1);
    nX = size(V,2);
    F = zeros(nYi,nX);
    for iX = 1:nX,
        for iYi = 1:nYi,
            F(iYi,iX) = sum(V(I(iYi,:),iX).*W(iYi,:)');
        end
    end
else
    nXi = size(W,1);
    nY = size(V,1);
    F = zeros(nY,nXi);
    for iXi = 1:nXi,
        for iY = 1:nY,
            F(iY,iXi) = sum(V(iY,I(iXi,:)).*W(iXi,:));
        end
    end
end

function [Weights,Indices] = weightsAndIndices(nIn,nOut,kernel,sKernel,nKernel)
scale   = nOut/nIn;
X       = (1:nOut)'; % Output indices.
U       = X/scale + 0.5 * (1 - 1/scale); % Input indices.
Left    = floor(U - sKernel/2); % Left pixel.
Indices = bsxfun(@plus, Left, 1:nKernel);
Weights = kernel(bsxfun(@minus, U, Indices));
Weights = bsxfun(@rdivide, Weights, sum(Weights, 2)); % Normalize over row.
Indices = min(max(1, Indices), nIn); % Clamp indices to in range values.
% kill    = find(~any(Weights, 1)); % Delete columns with all zeros.
% if ~isempty(kill)
%     Weights(:,kill) = [];
%     Indices(:,kill) = [];
% end

function F = cubic(X)
Absx    = abs(X);
Absx2   = Absx.^2;
Absx3   = Absx.^3;
F       = (1.5*Absx3 - 2.5*Absx2 + 1) .* (Absx <= 1) ...
        + (-0.5*Absx3 + 2.5*Absx2 - 4*Absx + 2) .* ((1 < Absx) & (Absx <= 2));
            
function F = box(X)
F = (-0.5 <= X) & (X < 0.5);
