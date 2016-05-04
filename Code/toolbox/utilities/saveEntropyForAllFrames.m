function saveEntropyForAllFrames(Entropy,IndexForFrame,Bin,outFile)
% saveEntropyForAllFrames
%   Entropy         - Matrix with the entropy per frame information. Each 
%                     row in this matrix corresponds to one frame index.
%   IndexForFrame   - Index of the frame that corresponds to each row entry
%                     in the entropy matrix.
%   Bin             - Bins used for the computation of the entropy.
%   outFile         - Output file with path for the entropy, e.g.
%                     'Entropy.mat'.
%
% RETURN
%   --
%
% DESCRIPTION
%   Saves the entropy from all frames in a Matlab file.
%

%   Florian Raudies, 01/19/2016, Palo Alto, CA.

save(outFile,'Entropy','IndexForFrame','Bin');