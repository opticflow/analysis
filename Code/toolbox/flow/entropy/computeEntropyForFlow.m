function [E, opt] = computeEntropyForFlow(Dx, Dy, opt)
% computeEntropyForFlow
%   Dx      - Horizontal flow component in pixel/frame.
%   Dy      - Vertical flow component in pixel/frame.
%   opt     - Structure with fields:
%             * nBinX   - Number of bins to compute the entropy for Dx.
%             *	RangeX  - Range = [minValue, maxValue] Minimum and maximum 
%                         value used when computing the mutual information 
%                         for Dx.
%             * nBinY   - Number of bins to compute the entropy for Dy.
%             * RangeY  - Range = [minValue, maxValue] Minimum and maximum
%                         value used when computing the mutual information
%                         for Dy.
% RETURNs
%   E       - Entropy in bits for 'Dx', 'Dy', and the joint entropy of 'Dx' 
%             and 'Dy'. The entropy E has the dimensions: 3 x 1.
%   opt     - Structure with all options, especially the default values for 
%             parameters.
%
% DESCRIPTION
%   Computes the entropy in bits of each flow component separately and the 
%   joint entropy for both flow components.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.

if isfield(opt,'nBinX'),    nBinX   = opt.nBinX;
else                        nBinX   = 11;                       end
if isfield(opt,'RangeX'),   RangeX  = opt.RangeX;
else                        RangeX  = [min(Dx(:)) max(Dx(:))];  end
if isfield(opt,'nBinY'),    nBinY   = opt.nBinY;
else                        nBinY   = 11;                       end
if isfield(opt,'RangeY'),   RangeY  = opt.RangeY;
else                        RangeY  = [min(Dy(:)) max(Dy(:))];  end

opt.BinX = linspace(RangeX(1), RangeX(2), nBinX);
opt.BinY = linspace(RangeY(1), RangeY(2), nBinY);

E    = zeros(3,1);
E(1) = entropy(Dx(:), opt.BinX);
E(2) = entropy(Dy(:), opt.BinY);
E(3) = jointEntropy(Dx(:), Dy(:), opt.BinX, opt.BinY);
