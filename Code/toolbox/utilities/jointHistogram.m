function [H, Bx, By] = jointHistogram(X, Y, BinX, BinY)
% jointHistogram
%   X       - First data source.
%   Y       - Second data source.
%   BinX    - Bins for first data source.
%   BinY    - Bins for second data source.
%
% RETURNs
%   H       - The joint histogram data with dimensions: 
%             (nBinY+1) x (nBinX+1)
%   Bx      - Bins for first data source.
%   By      - Bins for second data source.
%
% DESCRIPTION
%   Computes the joint histogram for the first/second data source:
%       H(i,j) = |{BinY(i)<=y<BinY(i+1) /\ BinX(i)<=x<BinX(i+1) 
%                   : x e X, y e Y}|
%   This coutns the occurrences  of data within the interval of the two 
%   bins. In total H has |X x Y| data entries or nX x nY data entries.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.
nBinX       = length(BinX);
nBinY       = length(BinY);
[Hx, Bx]    = histogram(X, BinX);
[Hy, By]    = histogram(Y, BinY);
H           = repmat(Hx',[nBinY+1 1]) .* repmat(Hy,[1 nBinX+1]);
