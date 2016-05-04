function NumPattern = parsePatternType(OrderedPatternType)
    % parsePatternType
    %   OrderedPatternType  - An ordered list of pattern types.
    %
    % RETURNs
    %   NumPattern          - NumPattern is set to 1 if present.
    %
    % DESCRIPTION
    %   Note that this method assumes eight pattern types and the following
    %   association of index to pattern type.
    %   +--------------+-----+-----+----+-----+------+-------+----+------+
    %   | Index        |   1 |   2 |  3 |   4 |    5 |     6 |  7 |    8 |
    %   +--------------+-----+-----+----+-----+------+-------+----+------+
    %   | Pattern type | exp | con | cw | ccw | left | right | up | down |
    %   +--------------+-----+-----+----+-----+------+-------+----+------+
    %
    
    %   Florian Raudies, 01/18/2016, Palo Alto, CA.
    nPatternType    = length(OrderedPatternType);
    NumPattern      = zeros(8,1);
    for iPatternType = 1:nPatternType,
        type = OrderedPatternType{iPatternType};
        switch lower(type)
            case 'exp'
                NumPattern(1) = 1;
            case 'con'
                NumPattern(2) = 1;
            case 'cw'
                NumPattern(3) = 1;
            case 'ccw'
                NumPattern(4) = 1;
            case 'left'
                NumPattern(5) = 1;
            case 'right'
                NumPattern(6) = 1;
            case 'up'
                NumPattern(7) = 1;
            case 'down'
                NumPattern(8) = 1;
            otherwise
                warning('Matlab:Parameter','Unkown pattern type %s.\n',type);
        end    
    end
