function e = entropy(Data, Bin)
% entropy
%   Data    - Input data.
%   Bin     - This is the binning of the data that is used when computing
%             the entropy.
%
% RETURNs
%   e       - The entropy value in bits.
%
% DESCRIPTION
%   Computes the entropy -sum(P x log2(P)) for P(i) being the relative 
%   occurrence of data in the interval given by Bin(i).
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.


P = histogram(Data, Bin);   % Computes the histogram.
P(P==0) = [];               % Removes zero entries.
P = P / (eps + sum(P));     % Normalize P so that sum(P) is 1.
e = -sum(P.*log2(P));       % Compute entropy.
