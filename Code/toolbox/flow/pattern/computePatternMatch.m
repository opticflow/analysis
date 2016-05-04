function [M, opt] = computePatternMatch(Dx, Dy, DxP, DyP, opt)
% computePatternMatch
%   Dx      - Horizontal component of the optic flow has dimensions: 
%             nY x nX.
%   Dy      - Vertical component of the optic flow has dimensions: 
%             nY x nX.
%   DxP     - Horizontal component of the flow pattern has dimensions: 
%             nY x nX x nP.
%   DyP     - Vertical component of the flow pattern has dimensions: 
%             nY x nX x nP.
%   opt     - Structure with fields:
%             * matchType - ['normInnerProduct' | 'normReLuInnerProduct', 'opponent'] This defines 
%                           the matching type as inner product or using an 
%                           opponent mechanism. The default is 
%                           'normInnerReLuProduct'.
% RETURNs
%   M       - Matching values have the dimensions: nP x 1. 
%   opt     - Structure all input fields and defaults that may have been 
%             set by the method.
%
% DESCRIPTION
%   Matches the optic flow 'Dx' and 'Dy' onto the motion patterns 'DxP' and
%   'DyP'. 
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.

if isfield(opt, 'matchType'),   matchType = opt.matchType;
else                            matchType = 'normReLuInnerProduct';
                                opt.matchType = matchType;
end

% Normalize the length of the flow vectors.
L   = eps + hypot(Dx, Dy);
Dx  = Dx./L;
Dy  = Dy./L;
L   = eps + hypot(DxP, DyP);
DxP = DxP./L;
DyP = DyP./L;
        
switch matchType
    case 'normInnerProduct'
        M = squeeze(mean(mean(bsxfun(@times, DxP, Dx) ...
                            + bsxfun(@times, DyP, Dy), 1), 2));
    case 'normReLuInnerProduct'
        M = squeeze(mean(mean(max(bsxfun(@times, DxP, Dx) ...
                                + bsxfun(@times, DyP, Dy),0), 1), 2));
    case 'opponent'
        % For this we need to know the patten type and pattern position.
        if ~isfield(opt,'PatternType'),
            error('Matlab:Parameter',...
                'For the match type %s the field ''PatternType'' is required!\n',...
                matchType);
        end
        PatternType = opt.PatternType;
        if ~isfield(opt,'PatternPosition'),
            error('Matlab:Parameter',...
                'For the match type %s the field ''PatternPosition'' is required!\n',...
                matchType);
        end
        PatternPosition = opt.PatternPosition;
        Tmp = squeeze(mean(mean(bsxfun(@times, DxP, Dx) ...
                            + bsxfun(@times, DyP, Dy), 1), 2));
                        
        [IndexPlus, IndexMinus] = findOpponentIndex(PatternType, PatternPosition);
        M       = zeros(size(DxP,3),1);
        MPlus   = Tmp(IndexPlus);
        MMinus  = Tmp(IndexMinus);
        
        M(IndexPlus)    = max( (MPlus-MMinus)./(2 + MPlus + MMinus), 0);
        M(IndexMinus)   = max( (MMinus-MPlus)./(2 + MMinus + MPlus), 0);        
    otherwise
        error('Matlab:Parameter', 'Unknown match type %s!\n', matchType);
end


function [IndexPlus, IndexMinus] = findOpponentIndex(PatternType, PatternPosition) 
    nPP = size(PatternPosition,1);
    if nPP > 1,
        error('Matlab:Parameter',...
            'Match type ''opponent'' does not support multiple positions!\n');
    end
    IndexPlus       = NaN(4,1);
    IndexMinus      = NaN(4,1);
    nPatternType    = length(PatternType);
    for iPatternType = 1:nPatternType,
        type = PatternType{iPatternType};
        switch lower(type)
            case 'exp'
                IndexPlus(1) = iPatternType;
            case 'con'
                IndexMinus(1) = iPatternType;
            case 'cw'
                IndexPlus(2) = iPatternType;
            case 'ccw'
                IndexMinus(2) = iPatternType;
            case 'left'
                IndexPlus(3) = iPatternType;
            case 'right'
                IndexMinus(3) = iPatternType;
            case 'up'
                IndexPlus(4) = iPatternType;
            case 'down'
                IndexMinus(4) = iPatternType;
            otherwise
                warning('Matlab:Parameter','Unkown pattern type %s.\n',type);
        end    
    end
    if any(isnan(IndexPlus)~=isnan(IndexMinus)),
        Index = [IndexMinus(isnan(IndexPlus)); IndexPlus(isnan(IndexMinus))];
        error('Matlab:Parameter',...
            'Opponents missing for pattern types: %s!\n',...
            strjoin(PatternType(Index),', '));
    end
    IndexPlus   = IndexPlus(~isnan(IndexPlus));
    IndexMinus  = IndexMinus(~isnan(IndexMinus));


function str = strjoin(C,delimiter)
    % In Matlab 2015b this is a Matlab function.
    nStr = length(C);
    str = C{1};
    for iStr = 2:nStr,
        str = [str, delimiter, C{iStr}];
    end
