function [H, B] = loadHistogram(inFile)
% loadHistogram
%   inFile  - Input file name.
%
% RETURNS
%   H       - Histogram data.
%   B       - Bins for the histogram data.
%
% DESCRIPTION
%   Loads the histogram data and corresponding bins from a Matlab file.

%   Florian Raudies, 01/17/2016, Palo Alto, CA.

Vars    = load(inFile);
H       = Vars.H;
B       = Vars.B;