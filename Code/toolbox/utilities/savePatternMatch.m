function savePatternMatch(Match, PatternType, PatternPosition, outFile)
% savePatternMatch
%   Match           - The matching values for each flow pattern.
%   PatternType     - Cell array with pattern types as strings.
%   PatternPosition - Positions for patterns.
%   outFile         - Output file pattern e.g. 'Pat%05d.mat'.
%
% RETURNs
%   --
%
% DESCRIPTION
%   Saves the pattern matching information into a Matlab file.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

save(outFile, 'Match', 'PatternType', 'PatternPosition');