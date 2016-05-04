function e = jointEntropy(X, Y, BinX, BinY)
% jointEntropy
%   X       - First data source.
%   Y       - Second data source.
%   BinX    - Bins for first data source.
%   BinY    - Bins for second data source.
%
% RETURNs
%   e       - The joint entropy value in bits.
%
% DESCRIPTION
%   Computes the joint entropy for the first/second random variable as:
%       H(i,j) = |{BinY(i)<=y<BinY(i+1) /\ BinX(i)<=x<BinX(i+1) 
%                   : x e X, y e Y}|
%       P(i,j) = H(i,j)/sum_{i,j}{ P(i,j }
%       e = sum_{i,j}{ P(i,j) log2(P(i,j)) }
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.


P = jointHistogram(X,Y, BinX,BinY); % Computes the joint histogram.
P = P(:);                           % Row vector for faster processing.
P(P==0) = [];                       % Remove zero entries.
P = P / (eps + sum(P));             % Normalize P so that sum(P) is 1.
e = -sum(P.*log2(P));               % Entropy.
