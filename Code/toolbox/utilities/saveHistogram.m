function saveHistogram(H, B, fileName)
% saveHistogram
%   H   - Histogram data.
%   B   - Bins for the histogram.
%
% RETURNs
%   --
% DESCRIPTION
%   Uses the Matlab save method to save 'H' and 'B'.

%   Florian Raudies, 01/17/2016, Palo Alto, CA.

save(fileName, 'H', 'B');