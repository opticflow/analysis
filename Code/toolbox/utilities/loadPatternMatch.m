function [Match, PatternType, PatternPosition] = loadPatternMatch(inFile)
% loadPatternMatch
%   inFile          - Input file pattern, e.g. 'Pat%05d.mat'.
%
% RETURN
%   Match           - Matching result.
%   PatternType     - Flow pattern type is a cell array with strings.
%   PatternPostion  - Pattern positions.
%
% DESCRIPTION
%   Loads the pattern matching information from a Matlab file.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

Vars            = load(inFile);
Match           = Vars.Match;
PatternType     = Vars.PatternType;
PatternPosition = Vars.PatternPosition;
