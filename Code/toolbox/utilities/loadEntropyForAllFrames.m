function [Entropy, IndexForFrame, Bin] = loadEntropyForAllFrames(inFile)
% loadEntropyForAllFrames
%   inFile          - Input file name with path, e.g. 'Entropy.mat'.
%
% RETURNs
%   Entropy         - The entropy matrix, where each row corresponds to one
%                     frame with the index from 'IndexForFrame'.
%   IndexForFrame   - Index of the frame that corresponds to the row in the
%                     entropy matrix.
%   Bin             - The bins used to compute the entropy. Notice, if
%                     there were multiple variables (as in the case of 
%                     optic flow) each row corresponds to the bins for a
%                     variable.
% DESCRIPTION
%   Loads the entropy from a Matlab file.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.

Vars            = load(inFile);
Entropy         = Vars.Entropy;
IndexForFrame   = Vars.IndexForFrame;
Bin             = Vars.Bin;