function OrderedPatternType = orderPatternType(PatternType)
    % orderPatternType
    %   PatternType     - Types of patterns. A scrambled or incomplete list
    %                     of pattern types.
    %
    % RETURNs
    %   OrderedPatternType  - Pattern types in canonical order.
    %
    % DESCRIPTION
    %   The canonical order for pattern types is defined by:
    %       'exp' > 'con' > 'cw' > 'ccw' > 'left' > 'right' > 'up' > 'down'
    %   Any of these patterns may be missing, but they always appear in the
    %   above order.
    %
    
    %   Florian Raudies, 01/18/2016, Palo Alto, CA.
    
    OrderedPatternType = {'exp', 'con', 'cw', 'ccw', ...
                          'left', 'right', 'up', 'down'};
    IndexDelete     = NaN(8,1);
    nPatternType    = length(PatternType);
    for iPatternType = 1:nPatternType,
        type = PatternType{iPatternType};
        switch lower(type)
            case 'exp'
                IndexDelete(1) = 1;
            case 'con'
                IndexDelete(2) = 1;
            case 'cw'
                IndexDelete(3) = 1;
            case 'ccw'
                IndexDelete(4) = 1;
            case 'left'
                IndexDelete(5) = 1;
            case 'right'
                IndexDelete(6) = 1;
            case 'up'
                IndexDelete(7) = 1;
            case 'down'
                IndexDelete(8) = 1;
        end
    end
    OrderedPatternType(isnan(IndexDelete)) = [];
